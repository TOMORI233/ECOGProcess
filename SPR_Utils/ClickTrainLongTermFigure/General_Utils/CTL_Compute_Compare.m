function temp = CTL_Compute_Compare(AmpLatency, selCh, devType, monkeyStr)
narginchk(3, 4);
evalStr = "temp = reshape([";
% mean
for dIndex = 1 : length(devType)
    strTemp = strcat("AmpLatency(", num2str(dIndex), ").mean(selCh)';");
    if ~isempty(AmpLatency(dIndex).mean)
        evalStr = strcat(evalStr, strTemp);
    end
end
% se
for dIndex = 1 : length(devType)
    strTemp = strcat("AmpLatency(", num2str(dIndex), ").se(selCh)';");
    if ~isempty(AmpLatency(dIndex).mean)
        evalStr = strcat(evalStr, strTemp);
    end
end
evalStr = char(evalStr);
evalStr = strcat(string(evalStr(1 : end-1)), "],", num2str(length(devType)), ",[]);");
eval(evalStr);
end

