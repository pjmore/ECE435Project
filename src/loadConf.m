function [] = loadConf()
    exep = MException('loadConf:BadFile','Config does not have proper number of fields');
    global PatricksConfForECEFourThirtyFiveProject;
    PatricksConfForECEFourThirtyFiveProject = load('conf.mat');
    PatricksConfForECEFourThirtyFiveProject = PatricksConfForECEFourThirtyFiveProject.conf;
    if numel(fieldnames(PatricksConfForECEFourThirtyFiveProject)) ~= 3
        throw(exep)
    end
end