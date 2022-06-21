clear; clc; close all;
%% Parameter setting
params.posIndex = 1; % 1-AC, 2-PFC
params.choiceWin = [0, 800];
params.processFcn = @ActiveProcess_LTST;

fs = 500; % Hz, for downsampling

%% Processing
% MATPATH = 'E:\ECoG\MAT Data\CC\LTST Active\cc20220606\cc20220606_AC.mat';
BLOCKPATH = 'G:\ECoG\chouchou\cc20220612\Block-1';

[trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH, params, 1);
% fs0 = ECOGDataset.fs;

%% Behavior
constIdx = logical(mod(ceil([trialAll.trialNum] / 20), 2));
randIdx = ~logical(mod(ceil([trialAll.trialNum] / 20), 2));
trialsConst = trialAll(constIdx);
trialsRand = trialAll(randIdx);
[FigBehavior, mAxe] = plotBehaviorOnly(trialsConst, "r", "Constant");
[FigBehavior, mAxe] = plotBehaviorOnly(trialsRand, "b", "Random", FigBehavior, mAxe);
drawnow;

%% Prediction
window = [-2500, 6000]; % ms

% Constant
[chMeanConst, ~] = joinSTD(trialsConst([trialsConst.correct] == true), ECOGDataset, window);
FigP_Wave_Const = plotRawWave(chMeanConst, [], window, "Constant std");
drawnow;
FigP_TFA_Const = plotTFA(double(chMeanConst), fs0, fs, window, "Constant std");
drawnow;

% Random
[chMeanRand, ~] = joinSTD(trialsRand([trialsRand.correct] == true), ECOGDataset, window);
FigP_Wave_Rand = plotRawWave(chMeanRand, [], window, "Random std");
drawnow;
FigP_TFA_Rand = plotTFA(chMeanRand, fs0, fs, window, "Random std");
drawnow;

% Difference
FigP_Wave_Diff = plotRawWave(chMeanConst - chMeanRand, [], window, "Constant - Random");
FigP_TFA_Diff = plotTFACompare(chMeanConst, chMeanRand, fs0, fs, window, "Constant - Random");

% Scale
scaleAxes([FigP_Wave_Const, FigP_Wave_Rand, FigP_Wave_Diff], "y", [], [-80, 80], "max");
scaleAxes([FigP_TFA_Const, FigP_TFA_Rand], "c", [], [0, 20]);
scaleAxes(FigP_TFA_Diff, "c", [], [-10, 10], "max");

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
    [~, chMeanConst, chStd] = selectEcog(ECOGDataset, trials, "dev onset", window);
    FigPE_Wave_Const(dIndex) = plotRawWave(chMeanConst, chStd, window, strcat("Constant dRatio = ", num2str(dRatio(dIndex))));
    drawnow;
    FigPE_TFA_Const(dIndex) = plotTFA(chMeanConst, fs0, fs, window, strcat("Constant dRatio = ", num2str(dRatio(dIndex))));
    drawnow;

    % Random
    trials = trialAll(randIdx & dRatioAll == dRatio(dIndex) & [trialAll.correct] == true);
    [~, chMeanRand, chStd] = selectEcog(ECOGDataset, trials, "dev onset", window);
    FigPE_Wave_Rand(dIndex) = plotRawWave(chMeanRand, chStd, window, strcat("Random dRatio = ", num2str(dRatio(dIndex))));
    drawnow;
    FigPE_TFA_Rand(dIndex) = plotTFA(chMeanRand, fs0, fs, window, strcat("Random dRatio = ", num2str(dRatio(dIndex))));
    drawnow;

    % Difference
    FigPE_Wave_Diff(dIndex) = plotRawWave(chMeanConst - chMeanRand, [], window, strcat("Const-Rand dRatio = ", num2str(dRatio(dIndex))));
    drawnow;
    FigPE_TFA_Diff(dIndex) = plotTFACompare(chMeanConst, chMeanRand, fs0, fs, window, strcat("Const-Rand | dRatio=", num2str(dRatio(dIndex))));
    drawnow;
end

% Scale
scaleAxes([FigPE_Wave_Const, FigPE_TFA_Const, FigPE_Wave_Rand, FigPE_TFA_Rand, FigPE_Wave_Diff, FigPE_TFA_Diff], "x", [-500, 1000]);
scaleAxes([FigPE_Wave_Const, FigPE_Wave_Rand, FigPE_Wave_Diff], "y", [], [-80, 80], "max");
scaleAxes([FigPE_TFA_Const, FigPE_TFA_Rand], "c", [], [0, 20]);
scaleAxes(FigPE_TFA_Diff, "c", [], [-20, 20], "max");

%% Layout
plotLayout([FigP_Wave_Const, FigP_Wave_Rand, FigP_Wave_Diff, FigPE_Wave_Const, FigPE_Wave_Rand, FigPE_Wave_Diff], posIndex);

%% Save
AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);
temp = string(split(BLOCKPATH, '\'));
DateStr = temp(end - 1);
ROOTPATH = "D:\Education\Lab\monkey\ECOG\Figures\long term-short term\";
BPATH = strcat(ROOTPATH, DateStr, "\Behavior\");
PEPATH = strcat(ROOTPATH, DateStr, "\Prediction error\");
PPATH = strcat(ROOTPATH, DateStr, "\Prediction\");
mkdir(BPATH);
mkdir(PPATH);
mkdir(PEPATH);

print(FigBehavior, strcat(BPATH, "Behavior_", DateStr), "-djpeg", "-r200");
print(FigP_Wave_Const, strcat(PPATH, AREANAME, "_Prediction_Raw_Const_", DateStr), "-djpeg", "-r200");
print(FigP_Wave_Rand, strcat(PPATH, AREANAME, "_Prediction_Raw_Rand_", DateStr), "-djpeg", "-r200");
print(FigP_TFA_Const, strcat(PPATH, AREANAME, "_Prediction_TFA_Const_", DateStr), "-djpeg", "-r200");
print(FigP_TFA_Rand, strcat(PPATH, AREANAME, "_Prediction_TFA_Rand_", DateStr), "-djpeg", "-r200");
print(FigP_Wave_Diff, strcat(PPATH, AREANAME, "_Prediction_Raw_Diff_", DateStr), "-djpeg", "-r200");
print(FigP_TFA_Diff, strcat(PPATH, AREANAME, "_Prediction_TFA_Diff_", DateStr), "-djpeg", "-r200");

for dIndex = 1:length(FigPE_Wave_Const)
    print(FigPE_Wave_Const(dIndex), strcat(PEPATH, AREANAME, "_PE_Raw_Const_", num2str(dIndex), "_", DateStr), "-djpeg", "-r200");
    print(FigPE_TFA_Const(dIndex), strcat(PEPATH, AREANAME, "_PE_TFA_Const_", num2str(dIndex), "_", DateStr), "-djpeg", "-r200");
    print(FigPE_Wave_Rand(dIndex), strcat(PEPATH, AREANAME, "_PE_Raw_Rand_", num2str(dIndex), "_", DateStr), "-djpeg", "-r200");
    print(FigPE_TFA_Rand(dIndex), strcat(PEPATH, AREANAME, "_PE_TFA_Rand_", num2str(dIndex), "_", DateStr), "-djpeg", "-r200");
    print(FigPE_Wave_Diff(dIndex), strcat(PEPATH, AREANAME, "_PE_Raw_Diff_", num2str(dIndex), "_", DateStr), "-djpeg", "-r200");
    print(FigPE_TFA_Diff(dIndex), strcat(PEPATH, AREANAME, "_PE_TFA_Diff_", num2str(dIndex), "_", DateStr), "-djpeg", "-r200");
end