function trialAll = CTScreeningProcess(epocs, varargin)
    attAll = epocs.atts.data;
    freqAll = epocs.freq.data;
    trialOnsetTime = epocs.atts.onset * 1000; % ms
    
    n = length(attAll);
    temp = cell(n, 1);
    trialAll = struct('trialNum', temp, ...
                      'soundOnsetSeq', temp, ...
                      'att', temp, ...
                      'freq', temp);

    for tIndex = 1:n
        trialAll(tIndex).trialNum = tIndex;
        trialAll(tIndex).soundOnsetSeq = trialOnsetTime(tIndex);
        trialAll(tIndex).att = attAll(tIndex);
        trialAll(tIndex).freq = freqAll(tIndex);
    end

    return;
end