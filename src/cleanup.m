function [] = cleanup()
    global PatricksConfForECEFourThirtyFiveProject;
    saveConf();
    clear PatricksConfForECEFourThirtyFiveProject;
    rmpath([pwd, '/src']);
end

