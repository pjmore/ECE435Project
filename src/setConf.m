function [] = setConf(key, val)
     exep = MException('SetConf:BadKey','Key does not exist in global config');
    global PatricksConfForECEFourThirtyFiveProject;
    if isfield(PatricksConfForECEFourThirtyFiveProject,key)
        PatricksConfForECEFourThirtyFiveProject.(key) = val;
    else
       throw(exep)
    end
end

