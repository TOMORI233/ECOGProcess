function trialAll = ActiveProcess_clickTrainWM(epocs, choiceWin, soundDuration)
narginchk(1, 3);

<<<<<<< HEAD
    if nargin < 2
        choiceWin = [0, 600];
        soundDuration = 0;
    end
    if nargin < 3
        soundDuration = 0;
    end
    choiceWinDev = choiceWin + soundDuration;
    %% Information extraction

   
=======
if nargin < 2
    choiceWin = [0, 600];
    soundDuration = 0;
end
if nargin < 3
    soundDuration = 0;
end
choiceWin = choiceWin + soundDuration;
%% Information extraction
% fixation 20220520 Block-1


% change irreg dev ordr for easy plot
%     epocs.ordr.data(epocs.ordr.data == 7) = 12;
%     epocs.ordr.data(epocs.ordr.data == 8) = 18;
%     epocs.ordr.data(epocs.ordr.data == 9) = 24;
%     epocs.ordr.data(epocs.ordr.data == 10) = 30;
>>>>>>> 29653e8ceb2f088327817ec0ce18d2e0ac0f68b9

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
    if ~isempty(firstPush)
        % DEV: Whether push in choice window
        if strcmp(trialAll(tIndex, 1).oddballType, "DEV")
<<<<<<< HEAD
            
            if firstPush >= trialAll(tIndex, 1).soundOnsetSeq(end) + choiceWinDev(1) && firstPush <= trialAll(tIndex, 1).soundOnsetSeq(end) + choiceWinDev(2)
=======

            if firstPush >= trialAll(tIndex, 1).soundOnsetSeq(end) + choiceWin(1) && firstPush <= trialAll(tIndex, 1).soundOnsetSeq(end) + choiceWin(2)
>>>>>>> 29653e8ceb2f088327817ec0ce18d2e0ac0f68b9
                pushInWinFlag = true;
                trialAll(tIndex, 1).firstPush = firstPush;
            else
                pushInWinFlag = false;
<<<<<<< HEAD
    
                if firstPush > trialAll(tIndex, 1).soundOnsetSeq(end) + choiceWinDev(2)
=======

                if firstPush > trialAll(tIndex, 1).soundOnsetSeq(end) + choiceWin(2)
>>>>>>> 29653e8ceb2f088327817ec0ce18d2e0ac0f68b9
                    trialAll(tIndex, 1).firstPush = [];
                end

            end

        else % STD

            if firstPush >= trialAll(tIndex, 1).soundOnsetSeq(end) && firstPush <= trialAll(tIndex, 1).soundOnsetSeq(end) + choiceWin(2)
                pushInWinFlag = true;
                trialAll(tIndex, 1).firstPush = firstPush;
            else
                pushInWinFlag = false;
<<<<<<< HEAD
    
                if firstPush > trialAll(tIndex, 1).soundOnsetSeq(end) +  choiceWin(2)
=======

                if firstPush > trialAll(tIndex, 1).soundOnsetSeq(end) +  + choiceWin(2)
>>>>>>> 29653e8ceb2f088327817ec0ce18d2e0ac0f68b9
                    trialAll(tIndex, 1).firstPush = [];
                end

            end

        end
    else
        pushInWinFlag = false;
        trialAll(tIndex, 1).firstPush = [];
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
