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
    I = loadImage('JPCLN001.tif');
    db = loadDB();
    downsize = 128;
    %Selecting top 5 matching images
    topn = selectTopN(I,5,db);
    topn = loadDBImages(topn);
    probMask = zeros(size(I));
    I = imresize(I,[downsize downsize]);
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
    Masks = zeros(downsize,downsize,length(topn));
    parfor i = 1:length(topn)
        [U,V] = cSIFT_FLOW_mex(SIFTImg,topn(i).SIFT,1,[1 0.5 1],30,20,int32(10));
        topn(i).U = U;
        topn(i).V = V;
        fprintf(1,'\b.\n');
    end
    for i =1:length(topn)
        mask = loadMask(topn(i).name);
        imresize(mask,[downsize downsize]);
        mask = warpMask(topn(i).U,topn(i).V,mask);
        Masks(:,:,i) = mask;
        topn(i).Mask = mask;
    end
    probMask = sum(Masks,3);
    probMask = probMask./max(probMask,[],'all');
    stepTwo = false;
    sound(y,1/2*Fs);
end
if stepThree == true
   "not done yet" 
   %SegImg = SegmentImage(I,probMask);
   sound(y,1/2*Fs);
end