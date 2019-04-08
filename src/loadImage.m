function [I] = loadImage(imgName)
    oldFolder = cd(strcat(readConf('baseDir'),'/images'));
    I = imread(imgName);
    cd(oldFolder);
end

