function [] = AutoLungSegmentation(imageName,n)
    %images are assumed to be in images directory on the base path.
    src_path = [pwd,'/src'];
    addpath(src_path);
    c = onCleanup(@cleanup);
    loadConf();
    setConf('baseDir',pwd);
    if ~readConf('preProc')
        PreProcessFiles();
        db = BuildRadonDB();
        setConf('preProc', true);
        saveConf();
    end
    % image must be opneable with imread
    % My sample is 1-20 of both classes Ie JPCNN010.tif and JPCLN015.tif
    I = loadImage(imageName);
    db = loadDB();
    %Selecting top 5 matching images
    topn = selectTopN(I,5,db);
    topn = loadDBImages(topn);    
    
            
                
end

