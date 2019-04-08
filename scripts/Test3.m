if ~exist('stepOne','var')
    stepOne = true;
end
if ~exist('stepTwo','var')
    stepTwo = true;
end
if ~exist('stepThree','var')
    stepThree = true;
end
load chirp;
if stepOne == true
    loadConf();
    imageName = 'JPCLN001.tif';
    I = loadImage(imageName);
    db = loadDB();
    downsize = 64;
    %Selecting top 5 matching images
    topn = selectTopN(I,5,db);
    topn = loadDBImages(topn);
    I = imresize(I,[downsize downsize]);
    probMask = zeros(size(I));
    [Fx, Fy] = gradient(double(I));
    theta = atan2(Fx,Fy);
    SIFTImg = winFunc(theta,[16,16],@SiftDescript);
    for i = 1:length(topn)
        i
        topn(i).Img = imresize(topn(i).Img,[downsize downsize]);
        [dbFx, dbFy] = gradient(double(topn(i).Img));
        thetadb = atan2(dbFx,dbFy);
        topn(i).SIFT = winFunc(thetadb,[16,16],@SiftDescript);
    end
    stepOne = false;
end

if stepTwo == true
    fprintf("starting step two");
    Masks = zeros(downsize,downsize,length(topn));
    for i = 1:length(topn)
        [U,V] = cSIFT_FLOW_mex(SIFTImg,topn(i).SIFT,1,[1 0.5 1],30,20,int32(10));
        mask = loadMask(topn(i).name);
        mask = imresize(mask,[downsize downsize]);
        mask = warpMask(U,V,mask);
        Masks(:,:,i) = double(mask);
        topn(i).U = U;
        topn(i).V = V;
        topn(i).Mask = mask;
        probMask  = probMask + mask;
        i
    end
    probMask = probMask./max(probMask,[],'all');
    stepTwo = false;
    sound(y,1/2*Fs);
end
if stepThree == true
    SegImg = logical(SegmentImage(I,probMask,1,0.5,1));
    GroundTruth = logical(imresize(loadMask(imageName)));
    Jac = jaccard(SegImg, GroundTruth);
    imshowpair(SegImg, GroundTruth)
    sound(y,1/2*Fs);
end