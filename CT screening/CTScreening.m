clear; clc; close all;
%% Parameter settings
% BLOCKPATH = 'E:\ECoG\xiaoxiao\xx20220622\Block-7';
BLOCKPATH = 'E:\ECoG\TDT Data\cc\cc20220530\Block-3';

params.posIndex = 1;
params.processFcn = @CTScreeningProcess;

colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

%% Processing
[trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH, params);
fs0 = ECOGDataset.fs;

%% Plot
window = [0, 500];
freqAll = sort(unique([trialAll.freq]), 'descend')';
chData = [];

for fIndex = 1:5
    trials = trialAll([trialAll.freq] == freqAll(fIndex));
    [~, chMean, ~] = selectEcog(ECOGDataset, trials, "trial onset", window);
    chData(fIndex).chMean = chMean;
    chData(fIndex).color = colors{fIndex};
end

FigWave = plotRawWaveMulti(chData, window, "CT Screening");
scaleAxes(FigWave,'y',[],[-50 50]);
%% check repetition frequency band
% window = [-1000, 5000];
% trials = trialAll(10:end-10);
% [trialsECOG, chMean, ~] = selectEcog(ECOGDataset, trials, "trial onset", window);
% Fig2 = plotTFA(chMean, fs0, 300, window);
% Fig = plotTFA2(trialsECOG, fs0, 300, window);
% scaleAxes(Fig,'y',[],[0 10]);
% scaleAxes(Fig,'c',[],[0 5]);