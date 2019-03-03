function [db] = loadDB()
    oldFolder = cd(strcat(readConf('baseDir'),'/db'));
    db = load('db.mat');
    db = db.db;
    cd(oldFolder);
end

