function [] = PreProcessFiles()
mydir = strcat(readConf('baseDir'),"db\Pictures\Pre");
files = dir(mydir);
dirFlags = ~[files.isdir];
pics = files(dirFlags);
parfor i=1:length(pics)
    loadconf();
    OTS(strcat(mydir,"\",pics(i).name));
end
end