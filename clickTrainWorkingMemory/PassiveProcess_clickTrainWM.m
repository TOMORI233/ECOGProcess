function trialAll = PassiveProcess_clickTrainWM(epocs, choiceWin, soundDuration)
narginchk(1, 3);

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

trialOnsetIndex = find(epocs.num0.data == 1);
trialOnsetTimeAll = epocs.num0.onset(trialOnsetIndex) * 1000; % ms
soundOnsetTimeAll = epocs.num0.onset * 1000; % ms

ordrAll = epocs.ordr.data; % Hz

n = length(trialOnsetIndex) - 1;
temp = cell(n, 1);
trialAll = struct('trialNum', temp, ...
    'soundOnsetSeq', temp, ...
    'devOnset', temp, ...
    'ordrSeq', temp, ...
    'stdOrdr',temp, ...
    'devOrdr', temp, ...
    'oddballType', temp, ...
    'stdNum', temp);

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

        if trialAll(tIndex, 1).ordrSeq(end) == trialAll(tIndex, 1).ordrSeq(1)
            trialAll(tIndex, 1).oddballType = "STD";
        else
            trialAll(tIndex, 1).oddballType = "DEV";
        end
        trialAll(tIndex, 1).devOrdr = trialAll(tIndex, 1).ordrSeq(end);
        trialAll(tIndex, 1).stdNum = length(trialAll(tIndex, 1).ordrSeq) - 1;



end

return;
end
