function trialAll = CorrProcess(epocs, varargin)
    orderAll = epocs.ordr.data;
    trialOnsetTime = epocs.ordr.onset * 1000; % ms
    
    n = length(orderAll);
    temp = cell(n, 1);
    trialAll = struct('trialNum', temp, ...
                      'soundOnsetSeq', temp, ...
                      'order', temp);

    for tIndex = 1:n
        trialAll(tIndex).trialNum = tIndex;
        trialAll(tIndex).soundOnsetSeq = trialOnsetTime(tIndex);
        trialAll(tIndex).order = orderAll(tIndex);
    end

    % Abort the first trial
    trialAll(1) = [];

    return;
end