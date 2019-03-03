function [topNdb] = loadDBImages(topNdb)
    N = length(topNdb);
    oldFolder = cd([readConf('baseDir') '\db\Pictures\Post']);
    for i = 1:N
        topNdb(i).Img = imread(topNdb(i).name);
    end
    cd(oldFolder);
end

