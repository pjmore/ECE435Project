function [] = saveConf()
global PatricksConfForECEFourThirtyFiveProject;
conf = PatricksConfForECEFourThirtyFiveProject;
save('conf.mat', 'conf');
end

