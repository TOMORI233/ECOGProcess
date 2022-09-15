clear; clc; close all;

%% Parameter setting
params.posIndex = 1; % 1-AC, 2-PFC
params.choiceWin = [100, 600];
params.processFcn = @ActiveProcess_7_10Freq;

fs = 500; % Hz, for downsampling

%% Processing
MATPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\CC\7-10Freq Passive\cc20220520\cc20220520_AC.mat';
% ROOTPATH = "D:\Education\Lab\Projects\ECOG\Figures\7-10Freq\";
temp = string(split(MATPATH, '\'));
DateStr = temp(end - 1);
[trialAll, ECOGDataset] = ECOGPreprocess(MATPATH, params);
fs0 = ECOGDataset.fs;

devFreqAll = [trialAll.devFreq];
stdFreqAll = cellfun(@(x) x(1), {trialAll.freqSeq});
dRatioAll = roundn(devFreqAll ./ stdFreqAll, -2);
dRatio = unique(dRatioAll);
dRatio(dRatio == 0) = [];

%% Prediction
[~, chMean, ~, window] = joinSTD(trialAll, ECOGDataset);
FigP(1) = plotRawWave(chMean, [], window);
drawnow;
FigP(2) = plotTFA(chMean, fs0, fs, window);
drawnow;

%% Prediction error
window = [-2000, 2000]; % ms

for dIndex = 1:length(dRatio)
    trials = trialAll(dRatioAll == dRatio(dIndex));
    [~, chMean, chStd] = selectEcog(ECOGDataset, trials, "dev onset", window);
    FigPE1(dIndex) = plotRawWave(chMean, chStd, window, ['dRatio=', num2str(dRatio(dIndex)), '(N=', num2str(length(trials)), ')']);
    drawnow;
    FigPE2(dIndex) = plotTFA(chMean, fs0, fs, window, ['dRatio=', num2str(dRatio(dIndex)), '(N=', num2str(length(trials)), ')']);
    drawnow;
end

% Scale
scaleAxes([FigPE1, FigPE2], "x", [-500, 1000]);
scaleAxes([FigP(1), FigPE1], "y", [-80, 80]);
scaleAxes([FigP(2), FigPE2], "c", [], [0, 20]);

%% Layout
plotLayout([FigP(1), FigPE1], posIndex);