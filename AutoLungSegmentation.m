function [SegImg,Jac] = AutoLungSegmentation(image,n,lenEdge,test)
    % Project requires some non trivial setup. All paths given are relative
    % to the base directory which contains this function.
%      The base directory must also contain the following sub directories
%     - db
%     - images
%     - src

    % Adding source file to Matlab's path, it is removed when the cleanup
    % function is called
    src_path = [pwd,'/src'];
    addpath(src_path);
    c = onCleanup(@cleanup);
    %Loading config. The config is stored in a global variable which is
    %named PatricksConfForECEFourThirtyFiveProject
    % Contains some information about the absolute location of the working
    % directory as well as whether the images have been converted from a
    % raw binary format to a matlab compatable one
    loadConf();
    setConf('baseDir',pwd);
    if ~readConf('preProc')
        PreProcessFiles();
        db = buildRadondb(); %#ok<NASGU>
        setConf('preProc', true);
        saveConf();
    end
    % image must be opneable with imread
    % My sample is 1-20 of both classes Ie JPCNN010.tif and JPCLN015.tif
    % Function will accept either a matrix or the name of a image in the
    % images sub-dir
    if ischar(image) 
        I = loadImage(image);
    else
        I = image;
    end
    %Load the precomputed partial radon transfroms of the database images
    %in db/Pictures/Post
    db = loadDB();
    %Selecting top 5 matching images
    topn = selectTopN(I,n,db);
    topn = loadDBImages(topn);
    %downsample the images to make the Loopy-belief propagation
    %computationally viable
    I = imresize(I,[lenEdge lenEdge]);
    probMask = zeros(size(I));
    [Fx, Fy] = gradient(double(I));
    %Compute orientation matrix
    theta = atan2(Fx,Fy);
    %Calculate the SiftDescritor in a 16 by 16 neighborhood. winFunc
    %applies the function SiftDescript as a sliding window. I did this
    %because matlab does not have a function that supports vector returns
    %from windowed functions. This is fairly slow even on smaller images
    SIFTImg = winFunc(theta,[16,16],@SiftDescript);
    for i = 1:length(topn)
        %Resize the database images
        topn(i).Img = imresize(topn(i).Img,[lenEdge lenEdge]);
        [dbFx, dbFy] = gradient(double(topn(i).Img));
        dbtheta = atan2(dbFx,dbFy);
        SIFTdbImg = winFunc(dbtheta,[16,16],@SiftDescript); 
        % Calulate the SIFT-Flow displacement vectors U and V
        [U,V] = cSIFT_FLOW_mex(SIFTImg,SIFTdbImg,1,[1 0.5 1],30,20,int32(20));
        %Load masks contained in db/Masks
        mask = loadMask(topn(i).name);
        mask = imresize(mask, [lenEdge lenEdge]);
        %warps the mask using the SIFT-FLOW displacement vectors
        mask = warpMask(U,V,mask);
        probMask = probMask+mask;
        fprintf("Completed SIFT-Flow on %i out of %i database images\n",i,length(topn))
    end
    %normalize the sum of the masks
    probMask = probMask./max(probMask,[],'all');
    
    SegImg = logical(round(SegmentImage(I,probMask,1,0.5,1)));
    if test == true && ischar(image)
        GroundTruth = logical(round(imresize(loadMask(image),[lenEdge lenEdge])));
        Jac = jaccard(SegImg, GroundTruth);
        imshowpair(SegImg, GroundTruth);
    end
end

