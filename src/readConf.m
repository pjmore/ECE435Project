function val = readConf(key)
    exep = MException('SetConf:BadKey','Key does not exist in global config');
    global PatricksConfForECEFourThirtyFiveProject;
    if isfield(PatricksConfForECEFourThirtyFiveProject,key)
         val = PatricksConfForECEFourThirtyFiveProject.(key);
    else
       throw(exep)
    end
end