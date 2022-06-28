clear; clc; close all;
%% Parameter settings
BLOCKPATH = 'E:\ECoG\xiaoxiao\xx20220622\Block-7';

params.posIndex = 1;
params.processFcn = @CTScreeningProcess;

%% Processing
[trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH, params);
fs0 = ECOGDataset.fs;

%% Plot
window = [0, 500];
freqAll = unique([trialAll.freq])';
chData = struct('chMean', cell(length(freqAll), 1));

for fIndex = 1:length(freqAll)
    trials = trialAll([trialAll.freq] == freqAll(fIndex));
    [~, chMean, ~] = selectEcog(ECOGDataset, trials, "trial onset", window);
    chData(fIndex).chMean = chMean;
end

FigWave = plotRawWaveMulti(chData, window, "CT Screening");
scaleAxes(FigWave,'y',[],[-50 50]);
%% check repetition frequency band
window = [-1000, 5000];
trials = trialAll(10:end-10);
[~, chMean, ~] = selectEcog(ECOGDataset, trials, "trial onset", window);
Fig = plotTFA(chMean, fs0, 300, window);
scaleAxes(Fig,'y',[],[0 10]);
scaleAxes(Fig,'c',[],[0 5]);