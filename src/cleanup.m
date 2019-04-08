function [] = cleanup()
    %% performs cleanup on the project exit. Saves change to the config and
    % removes the src folder from the path
    global PatricksConfForECEFourThirtyFiveProject;
    saveConf();
    clear PatricksConfForECEFourThirtyFiveProject;
    rmpath([pwd, '/src']);
end

