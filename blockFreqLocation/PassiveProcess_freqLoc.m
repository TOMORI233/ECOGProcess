function trialAll = PassiveProcess_freqLoc(epocs)
    %% Information extraction
    % fixation 20220520 Block-2
    for index = 1:length(unique(epocs.swee.data))
        idx = find(epocs.swee.data == index);
        epocs.num0.data(idx) = (1:length(idx))';
    end

    trialOnsetIndex = find(epocs.num0.data == 1);
    soundOnsetTimeAll = epocs.num0.onset * 1000; % ms
    freqAll = epocs.freq.data; % ms

    trialAll = struct('trialNum', temp, ...
                      'soundOnsetSeq', temp, ...
                      'devOnset', temp, ...
                      'freqSeq', temp, ...
                      'devFreq', temp, ...
                      'interrupt', temp, ...
                      'oddballType', temp, ...
                      'stdNum', temp, ...
                      'firstPush', temp, ...
                      'correct', temp);

    %% All trials
    % Absolute time, abort the last trial
    for tIndex = 1:length(trialOnsetIndex) - 1
        trialAll(tIndex, 1).trialNum = tIndex;
        %% Sequence
        soundOnsetIndex = trialOnsetIndex(tIndex):(trialOnsetIndex(tIndex + 1) - 1);

        trialAll(tIndex, 1).soundOnsetSeq = soundOnsetTimeAll(soundOnsetIndex);
        trialAll(tIndex, 1).devOnset = trialAll(tIndex, 1).soundOnsetSeq(end);
        trialAll(tIndex, 1).freqSeq = freqAll(soundOnsetIndex);

        if trialAll(tIndex, 1).freqSeq(end) == trialAll(tIndex, 1).freqSeq(1)
            trialAll(tIndex, 1).oddballType = "STD";
        else
            trialAll(tIndex, 1).oddballType = "DEV";
        end

        trialAll(tIndex, 1).devFreq = trialAll(tIndex, 1).freqSeq(end);
        trialAll(tIndex, 1).stdNum = length(trialAll(tIndex, 1).freqSeq) - 1;

        trialAll(tIndex, 1).firstPush = [];
        trialAll(tIndex, 1).waterOnsetTime = [];
    end

    return;
end
