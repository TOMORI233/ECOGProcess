function trialAll = ActiveProcess_clickTrain(epocs, choiceWin, soundDuration)
    narginchk(1, 3);

    if nargin < 2
        choiceWin = [0, 600];
        soundDuration = 0;
    end
    if nargin < 3
        soundDuration = 0;
    end
    choiceWinDev = choiceWin + soundDuration;
    %% Information extraction

   

    trialOnsetIndex = find(epocs.num0.data == 1);
    trialOnsetTimeAll = epocs.num0.onset(trialOnsetIndex) * 1000; % ms
    soundOnsetTimeAll = epocs.num0.onset * 1000; % ms
    if isfield(epocs,'erro')
        errorPushTimeAll = epocs.erro.onset(epocs.erro.data ~= 0) * 1000; % ms
    else
        errorPushTimeAll = [];
    end
    pushTimeAll = epocs.push.onset * 1000; % ms
    ordrAll = epocs.ordr.data; % Hz

    n = length(trialOnsetIndex) - 1;
    temp = cell(n, 1);
    trialAll = struct('trialNum', temp, ...
                      'soundOnsetSeq', temp, ...
                      'devOnset', temp, ...
                      'ordrSeq', temp, ...
                      'stdOrdr',temp, ...
                      'devOrdr', temp, ...
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
        trialAll(tIndex, 1).ordrSeq = ordrAll(soundOnsetIndex);
        trialAll(tIndex, 1).stdOrdr = trialAll(tIndex, 1).ordrSeq(1);

        %% Interrupt or not
        if ~isempty(find(errorPushTimeAll >= trialAll(tIndex, 1).soundOnsetSeq(end) & errorPushTimeAll < trialOnsetTimeAll(tIndex + 1), 1))
            trialAll(tIndex, 1).interrupt = true;
            trialAll(tIndex, 1).oddballType = "INTERRUPT";

            if trialAll(tIndex, 1).ordrSeq(end) ~= trialAll(tIndex, 1).ordrSeq(1)
                trialAll(tIndex, 1).devOrdr = trialAll(tIndex, 1).ordrSeq(end);
                trialAll(tIndex, 1).stdNum = length(trialAll(tIndex, 1).soundOnsetSeq) - 1;
            else
                trialAll(tIndex, 1).devOrdr = 0;
                trialAll(tIndex, 1).stdNum = length(trialAll(tIndex, 1).soundOnsetSeq);
            end

        else
            trialAll(tIndex, 1).interrupt = false;

            if trialAll(tIndex, 1).ordrSeq(end) == trialAll(tIndex, 1).ordrSeq(1)
                trialAll(tIndex, 1).oddballType = "STD";
            else
                trialAll(tIndex, 1).oddballType = "DEV";
            end
            trialAll(tIndex, 1).devOrdr = trialAll(tIndex, 1).ordrSeq(end);
            trialAll(tIndex, 1).stdNum = length(trialAll(tIndex, 1).ordrSeq) - 1;
        end

        %% Correct or not
        % Find first push time of this trial
        firstPush = pushTimeAll(find(pushTimeAll >= trialAll(tIndex, 1).soundOnsetSeq(end) & pushTimeAll <= trialOnsetTimeAll(tIndex + 1, 1), 1));

        % DEV: Whether push in choice window
        if strcmp(trialAll(tIndex, 1).oddballType, "DEV")
            
            if firstPush >= trialAll(tIndex, 1).soundOnsetSeq(end) + choiceWinDev(1) && firstPush <= trialAll(tIndex, 1).soundOnsetSeq(end) + choiceWinDev(2)
                pushInWinFlag = true;
                trialAll(tIndex, 1).firstPush = firstPush;
            else
                pushInWinFlag = false;
    
                if firstPush > trialAll(tIndex, 1).soundOnsetSeq(end) + choiceWinDev(2)
                    trialAll(tIndex, 1).firstPush = [];
                end
    
            end
        
        else % STD

            if firstPush >= trialAll(tIndex, 1).soundOnsetSeq(end) && firstPush <= trialAll(tIndex, 1).soundOnsetSeq(end) + choiceWin(2)
                pushInWinFlag = true;
                trialAll(tIndex, 1).firstPush = firstPush;
            else
                pushInWinFlag = false;
    
                if firstPush > trialAll(tIndex, 1).soundOnsetSeq(end) +  choiceWin(2)
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

    return;
end
