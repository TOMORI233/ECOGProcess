function trialAll = CorrProcess(epocs, varargin)
    orderAll = epocs.ordr.data;
    trialOnsetTime = epocs.order.onset * 1000; % ms
    
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

    return;
end