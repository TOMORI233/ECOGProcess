clear; clc; close all;
%% Parameter settings
BLOCKPATH = 'G:\ECoG\chouchou\cc20220530\Block-3';

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

plotRawWaveMulti(chData, window, "CT Screening");

%% check repetition frequency band
window = [-1000, 5000];
trials = trialAll(10:end-10);
[trialsECOG, chMean, ~] = selectEcog(ECOGDataset, trials, "trial onset", window);
Fig2 = plotTFA(chMean, fs0, 300, window);
Fig = plotTFA2(trialsECOG, fs0, 300, window);
scaleAxes(Fig,'y',[],[0 10]);
scaleAxes(Fig,'c',[],[0 5]);