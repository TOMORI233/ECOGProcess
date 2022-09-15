function trialAll = ActiveProcess_7_10Freq(epocs, choiceWin)
    narginchk(1, 2);

    if nargin < 2
        choiceWin = [0, 600];
    end

    %% Information extraction

%     % fixation 20220520 Block-1
%     for index = 1:length(unique(epocs.swee.data))
%         idx = find(epocs.swee.data == index);
%         epocs.num0.data(idx) = (1:length(idx))';
%     end

    trialOnsetIndex = find(epocs.num0.data == 1);
    trialOnsetTimeAll = epocs.num0.onset(trialOnsetIndex) * 1000; % ms
    soundOnsetTimeAll = epocs.num0.onset * 1000; % ms
    errorPushTimeAll = epocs.erro.onset(epocs.erro.data ~= 0) * 1000; % ms
    pushTimeAll = epocs.push.onset * 1000; % ms
    freqAll = epocs.freq.data; % Hz

    n = length(trialOnsetIndex) - 1;
    temp = cell(n, 1);
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

        %% Interrupt or not
        if ~isempty(find(errorPushTimeAll >= trialAll(tIndex, 1).soundOnsetSeq(end) & errorPushTimeAll < trialOnsetTimeAll(tIndex + 1), 1))
            trialAll(tIndex, 1).interrupt = true;
            trialAll(tIndex, 1).oddballType = "INTERRUPT";

            if trialAll(tIndex, 1).freqSeq(end) ~= trialAll(tIndex, 1).freqSeq(1)
                trialAll(tIndex, 1).devFreq = trialAll(tIndex, 1).freqSeq(end);
                trialAll(tIndex, 1).stdNum = length(trialAll(tIndex, 1).soundOnsetSeq) - 1;
            else
                trialAll(tIndex, 1).devFreq = 0;
                trialAll(tIndex, 1).stdNum = length(trialAll(tIndex, 1).soundOnsetSeq);
            end

        else
            trialAll(tIndex, 1).interrupt = false;

            if trialAll(tIndex, 1).freqSeq(end) == trialAll(tIndex, 1).freqSeq(1)
                trialAll(tIndex, 1).oddballType = "STD";
            else
                trialAll(tIndex, 1).oddballType = "DEV";
            end

            trialAll(tIndex, 1).devFreq = trialAll(tIndex, 1).freqSeq(end);
            trialAll(tIndex, 1).stdNum = length(trialAll(tIndex, 1).freqSeq) - 1;
        end

        %% Correct or not
        % Find first push time of this trial
        firstPush = pushTimeAll(find(pushTimeAll >= trialAll(tIndex, 1).soundOnsetSeq(end) & pushTimeAll <= trialOnsetTimeAll(tIndex + 1, 1), 1));

        if isempty(firstPush)
            trialAll(tIndex, 1).correct = false;
            continue;
        end

        % DEV: Whether push in choice window
        if strcmp(trialAll(tIndex, 1).oddballType, "DEV")
            
            if firstPush >= trialAll(tIndex, 1).soundOnsetSeq(end) + choiceWin(1) && firstPush <= trialAll(tIndex, 1).soundOnsetSeq(end) + choiceWin(2)
                pushInWinFlag = true;
                trialAll(tIndex, 1).firstPush = firstPush;
            else
                pushInWinFlag = false;
    
                if firstPush > trialAll(tIndex, 1).soundOnsetSeq(end) + choiceWin(2)
                    trialAll(tIndex, 1).firstPush = [];
                end
    
            end
        
        else % STD

            if firstPush >= trialAll(tIndex, 1).soundOnsetSeq(end) && firstPush <= trialAll(tIndex, 1).soundOnsetSeq(end) + choiceWin(2)
                pushInWinFlag = true;
                trialAll(tIndex, 1).firstPush = firstPush;
            else
                pushInWinFlag = false;
    
                if firstPush > trialAll(tIndex, 1).soundOnsetSeq(end) + choiceWin(2)
                    trialAll(tIndex, 1).firstPush = [];
                end
    
            end
            
        end

        % DEV: push in choice window; STD: no push in choice window
        if ~trialAll(tIndex, 1).interrupt && ((strcmp(trialAll(tIndex, 1).oddballType, "DEV") && pushInWinFlag) || (strcmp(trialAll(tIndex, 1).oddballType, "STD") && ~pushInWinFlag))
            trialAll(tIndex, 1).correct = true;

            if strcmp(trialAll(tIndex, 1).oddballType, "STD")
                trialAll(tIndex, 1).firstPush = [];
            end

        else
            trialAll(tIndex, 1).correct = false;
        end

    end

    % Abort the first trial
    trialAll(1) = [];

    return;
end
