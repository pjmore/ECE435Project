files = dir('*.gif');
for i = 1:length(files)
    name = files(i).name;
    I = imread(name);
    imwrite(I,strcat(name(1:length(name) - 4),'.tif'));
    delete(name);
end