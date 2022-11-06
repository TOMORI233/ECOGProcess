function trialAll = PassiveProcess_clickTrainContinuous(epocs, choiceWin, soundDuration)
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
trialOnsetIndex = 1:length(epocs.ordr.data);
trialOnsetTimeAll = epocs.ordr.onset(trialOnsetIndex) * 1000; % ms
soundOnsetTimeAll = epocs.ordr.onset * 1000; % ms
ordrAll = epocs.ordr.data; % Hz

n = length(trialOnsetIndex);
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
for tIndex = 1:length(trialOnsetIndex)
    trialAll(tIndex, 1).trialNum = tIndex;
    %% Sequence
    if tIndex < length(trialOnsetIndex)
    soundOnsetIndex = trialOnsetIndex(tIndex):(trialOnsetIndex(tIndex + 1) - 1);
    else
         soundOnsetIndex = trialOnsetIndex(tIndex):length(epocs.ordr.data);
    end
    trialAll(tIndex, 1).soundOnsetSeq = soundOnsetTimeAll(soundOnsetIndex);
    trialAll(tIndex, 1).devOnset = trialAll(tIndex, 1).soundOnsetSeq(end);
    trialAll(tIndex, 1).ordrSeq = ordrAll(soundOnsetIndex);
    trialAll(tIndex, 1).stdOrdr = trialAll(tIndex, 1).ordrSeq(1);
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
