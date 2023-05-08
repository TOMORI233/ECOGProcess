function [dRatioAll, dRatio] = computeDevRatio(trialAll)
    devFreqAll = [trialAll.devFreq];
    stdFreqAll = cellfun(@(x) x(1), {trialAll.freqSeq});
    dRatioAll = roundn(devFreqAll ./ stdFreqAll, -2);
    dRatio = unique(dRatioAll);
    dRatio(dRatio == 0) = [];
    return;
end