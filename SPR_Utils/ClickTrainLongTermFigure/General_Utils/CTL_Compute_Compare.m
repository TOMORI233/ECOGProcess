function temp = CTL_Compute_Compare(AmpLatency, selCh, devType, monkeyStr)
evalStr = "temp = reshape([";
% mean
    for dIndex = 1 : length(devType)
        strTemp = strcat("AmpLatency(", num2str(dIndex), ").(strcat(monkeyStr, ""_mean""))(selCh)';");
        evalStr = strcat(evalStr, strTemp);
    end
 % se
    for dIndex = 1 : length(devType)
        strTemp = strcat("AmpLatency(", num2str(dIndex), ").(strcat(monkeyStr, ""_se""))(selCh)';");
        evalStr = strcat(evalStr, strTemp);
    end
    evalStr = char(evalStr);
    evalStr = strcat(string(evalStr(1 : end-1)), "],", num2str(length(devType)), ",[]);");
    eval(evalStr);
end

