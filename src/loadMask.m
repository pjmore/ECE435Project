function [I] = loadMask(imgName)
    oldFolder = cd(strcat(readConf('baseDir'),'/db/Masks'));
    I = imread(imgName);
    cd(oldFolder);
end
