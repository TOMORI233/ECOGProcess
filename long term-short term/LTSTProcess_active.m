%% Data loading
clear; clc; close all;
BLOCKPATH = 'E:\ECoG\TDT Data\chouchou\cc20220521\Block-1';
posIndex = 1; % 1-AC, 2-PFC
posStr = ["LAuC", "LPFC"];

temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs'});
epocs = temp.epocs;

temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'streams'}, 'STORE', posStr(posIndex));
streams = temp.streams;

ECOGDataset = streams.(posStr(posIndex));
fs0 = ECOGDataset.fs;

%% Params settings
choiceWin = [0, 800]; % ms
fs = 300; % Hz, for downsampling

%% Processing
trialAll = ActiveProcess_LTST(epocs, choiceWin);

%% Behavior
constIdx = logical(mod(ceil([trialAll.trialNum] / 20), 2));
randIdx = ~logical(mod(ceil([trialAll.trialNum] / 20), 2));
trialsConst = trialAll(constIdx);
trialsRand = trialAll(randIdx);
[Fig, mAxe] = plotBehaviorOnly(trialsConst, "b", "Constant");
[Fig, mAxe] = plotBehaviorOnly(trialsRand, "r", "Random", Fig, mAxe);

%% STD
window = [-2500, 6000]; % ms

% Constant
[chMean, chStd] = joinSTD(trialsConst, ECOGDataset, window);
FigSTD_Wave_Const = plotRawWave(chMean, chStd, window, "Constant std");
drawnow;
FigSTD_TFA_Const = plotTimeFreqAnalysis(double(chMean), fs0, fs, window, "Constant std");
drawnow;

% Random
[chMean, chStd] = joinSTD(trialsRand, ECOGDataset, window);
FigSTD_Wave_Rand = plotRawWave(chMean, chStd, window, "Random std");
drawnow;
FigSTD_TFA_Rand = plotTimeFreqAnalysis(double(chMean), fs0, fs, window, "Random std");
drawnow;

% Scale
scaleAxes([FigSTD_Wave_Const, FigSTD_Wave_Rand], "y", [-80, 80]);
scaleAxes([FigSTD_TFA_Const, FigSTD_TFA_Rand], "c");
plotLayout([FigSTD_Wave_Const, FigSTD_Wave_Rand, FigSTD_TFA_Const, FigSTD_TFA_Rand], posIndex);

%% DEV
window = [-1500, 2000];
devFreqAll = [trialAll.devFreq];
stdFreqAll = cellfun(@(x) x(1), {trialAll.freqSeq});
dRatioAll = roundn(devFreqAll ./ stdFreqAll, -2);
dRatio = unique(dRatioAll);
dRatio(dRatio == 0) = [];

for dIndex = 1:length(dRatio)
    % Constant
    trials = trialAll(constIdx & dRatioAll == dRatio(dIndex) & [trialAll.correct] == true);
    [~, chMean, chStd] = selectEcog(ECOGDataset, trials, "dev onset", window);
    FigDEV_Wave_Const(dIndex) = plotRawWave(chMean, chStd, window, strcat("Constant dRatio = ", num2str(dRatio(dIndex))));
    drawnow;
    FigDEV_TFA_Const(dIndex) = plotTimeFreqAnalysis(chMean, fs0, fs, window, strcat("Constant dRatio = ", num2str(dRatio(dIndex))));
    drawnow;

    % Random
    trials = trialAll(randIdx & dRatioAll == dRatio(dIndex) & [trialAll.correct] == true);
    [~, chMean, chStd] = selectEcog(ECOGDataset, trials, "dev onset", window);
    FigDEV_Wave_Rand(dIndex) = plotRawWave(chMean, chStd, window, strcat("Random dRatio = ", num2str(dRatio(dIndex))));
    drawnow;
    FigDEV_TFA_Rand(dIndex) = plotTimeFreqAnalysis(chMean, fs0, fs, window, strcat("Random dRatio = ", num2str(dRatio(dIndex))));
    drawnow;
end

% Scale
scaleAxes([FigDEV_Wave_Const, FigDEV_TFA_Const, FigDEV_Wave_Rand, FigDEV_TFA_Rand], "x", [-300, 1000]);
scaleAxes([FigDEV_Wave_Const, FigDEV_Wave_Rand], "y", [-80, 80]);
scaleAxes([FigDEV_TFA_Const, FigDEV_TFA_Rand], "y");
scaleAxes([FigDEV_TFA_Const, FigDEV_TFA_Rand], "c");
plotLayout([FigDEV_Wave_Const, FigDEV_TFA_Const, FigDEV_Wave_Rand, FigDEV_TFA_Rand], posIndex);