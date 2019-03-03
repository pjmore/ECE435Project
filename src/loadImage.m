function [I] = loadImage(imgName)
    oldFolder = cd(strcat(readConf('baseDir'),'/images'));
    I = imread(imageName);
    cd(oldFolder);
end

