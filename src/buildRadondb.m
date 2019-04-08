function [db] = buildRadondb()
%% builds the Radon transfrom profiles needed to select the best fit
mydir = strcat(readConf('baseDir'),"\db\Pictures\Post");
files = dir(mydir);
dirFlags = ~[files.isdir];
pics = files(dirFlags);
oldFolder = cd(mydir);
c = onCleanup(@()cd(oldFolder));

%% Calculates the partial radon transform over all of the images in the imags/Post
for i=length(pics):-1:1
    I = imread(pics(i).name);
    db(i).name = pics(i).name;
    [db(i).X db(i).Y] = radonTrans(I);
end
cd(oldFolder);
oldFolder = cd(strcat(readConf('baseDir'),"\db"));
save('db.mat','db');
cd(oldFolder);
end

