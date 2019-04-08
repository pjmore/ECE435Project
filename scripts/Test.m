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
    downsize = 64;
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
        dbtheta = atan2(dbFx,dbFy);
        topn(i).SIFT = winFunc(dbtheta,[16,16],@SiftDescript);
    end
    stepOne = false;
    sound(y,1/2*Fs);
end

if stepTwo == true
    for i = 1:3
        if i==1
            SIFTFlow = SIFT_FLOW(SIFTImg,topn(i).SIFT,1,[1,0.5,1],50,30);
        else
            SIFTFlow.Reset(SIFTdbImg);
        end
t        [U,V] = SIFTFlow.Run(10);
        mask = loadMask(topn(i).name);
        imresize(mask,[downsize downsize]);
        mask = warpMask(U,V,mask);
        probMask = probMask+mask;
        topn(i).U = U;
        topn(i).V = V;
        topn(i).Mask = mask;
    end
    probMask = probMask./max(probMask,[],'all');
    stepTwo = false;
    sound(y,1/2*Fs);
end
if stepThree == true
    "not done yet"
    %SegImg = SegmentImage(I,probMask);
    sound(y,1/2*Fs);
end