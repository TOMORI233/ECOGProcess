clear; clc; close all;
%% Parameter setting
params.posIndex = 1; % 1-AC, 2-PFC
params.choiceWin = [100, 800];
params.processFcn = @ActiveProcess_WhatWhen;

fs = 500; % Hz, for downsampling

%% Processing
MATPATH = 'E:\ECoG\MAT Data\CC\WhatWhen Active\cc20220619\cc20220619_AC.mat';
[trialAll, ECOGDataset] = ECOGPreprocess(MATPATH, params);
fs0 = ECOGDataset.fs;

%% Behavior
constIdx = logical(mod(ceil([trialAll.trialNum] / 20), 2));
randIdx = ~logical(mod(ceil([trialAll.trialNum] / 20), 2));
trialsConst = trialAll(constIdx);
trialsRand = trialAll(randIdx);
[FigBehavior, mAxe] = plotBehaviorOnly(trialsConst, "r", "Constant ISI");
[FigBehavior, mAxe] = plotBehaviorOnly(trialsRand, "b", "Random ISI", FigBehavior, mAxe);
drawnow;

%% MMN
window = [-2000, 2000];
% constant
trialsConstC = trialsConst([trialsConst.correct] == true & [trialsConst.oddballType] == "DEV");
trialsConstW = trialsConst([trialsConst.correct] == false & [trialsConst.interrupt] == false & [trialsConst.oddballType] == "DEV");
[resultDEVC, chMeanDEVC, ~] = selectEcog(ECOGDataset, trialsConstC, "dev onset", window);
[resultSTDC, chMeanSTDC, ~] = selectEcog(ECOGDataset, trialsConstC, "last std", window);
[resultDEVW, chMeanDEVW, ~] = selectEcog(ECOGDataset, trialsConstW, "dev onset", window);
[resultSTDW, chMeanSTDW, ~] = selectEcog(ECOGDataset, trialsConstW, "last std", window);
chMeanC = cell2mat(cellfun(@mean, changeCellRowNum(resultDEVC - resultSTDC), "UniformOutput", false));
chMeanW = cell2mat(cellfun(@mean, changeCellRowNum(resultDEVW - resultSTDW), "UniformOutput", false));
Fig1(1) = plotRawWave(chMeanC, [], window, "ConstC:DEV-last STD");
Fig1(2) = plotRawWave(chMeanW, [], window, "ConstW:DEV-last STD");
Fig2(1) = plotTFACompare(chMeanDEVC, chMeanSTDC, fs0, fs, window, "ConstC:DEV-last STD");
Fig2(2) = plotTFACompare(chMeanDEVW, chMeanSTDW, fs0, fs, window, "ConstW:DEV-last STD");
scaleAxes([Fig1, Fig2], "x", [0, 500]);
scaleAxes(Fig1, "y", [], [-60, 60], "max");
scaleAxes(Fig2, "c", [], [-20, 20]);

% random
trialsRandC = trialsRand([trialsRand.correct] == true & [trialsRand.oddballType] == "DEV");
trialsRandW = trialsRand([trialsRand.correct] == false & [trialsRand.interrupt] == false & [trialsRand.oddballType] == "DEV");
[resultDEVC, chMeanDEVC, ~] = selectEcog(ECOGDataset, trialsRandC, "dev onset", window);
[resultSTDC, chMeanSTDC, ~] = selectEcog(ECOGDataset, trialsRandC, "last std", window);
[resultDEVW, chMeanDEVW, ~] = selectEcog(ECOGDataset, trialsRandW, "dev onset", window);
[resultSTDW, chMeanSTDW, ~] = selectEcog(ECOGDataset, trialsRandW, "last std", window);
chMeanC = cell2mat(cellfun(@mean, changeCellRowNum(resultDEVC - resultSTDC), "UniformOutput", false));
chMeanW = cell2mat(cellfun(@mean, changeCellRowNum(resultDEVW - resultSTDW), "UniformOutput", false));
Fig3(1) = plotRawWave(chMeanC, [], window, "RandC:DEV-last STD");
Fig3(2) = plotRawWave(chMeanW, [], window, "RandW:DEV-last STD");
Fig4(1) = plotTFACompare(chMeanDEVC, chMeanSTDC, fs0, fs, window, "RandC:DEV-last STD");
Fig4(2) = plotTFACompare(chMeanDEVW, chMeanSTDW, fs0, fs, window, "RandW:DEV-last STD");
scaleAxes([Fig3, Fig4], "x", [0, 500]);
scaleAxes(Fig3, "y", [], [-60, 60], "max");
scaleAxes(Fig4, "c", [], [-20, 20]);

%% DEV
window = [-2000, 2000];
[~, chMeanConst, chStdConst] = selectEcog(ECOGDataset, trialsConstC, "dev onset", window);
[~, chMeanRand, chStdRand] = selectEcog(ECOGDataset, trialsRandC, "dev onset", window);
Fig5(1) = plotRawWave(chMeanConst, chStdConst, window, "Const ISI");
Fig5(2) = plotRawWave(chMeanRand, chStdRand, window, "Rand ISI");
Fig6(1) = plotTFA(chMeanConst, fs0, fs, window, "Const ISI");
Fig6(2) = plotTFA(chMeanRand, fs0, fs, window, "Rand ISI");
scaleAxes([Fig5, Fig6], "x", [-500, 1000]);
scaleAxes(Fig5, "y", [], [-60, 60], "max");
scaleAxes(Fig6, "c", [], [-20, 20]);

%% Layout
% plotLayout([FigP_Wave_Const, FigP_Wave_Rand, FigP_Wave_Diff, FigPE_Wave_Const, FigPE_Wave_Rand, FigPE_Wave_Diff], posIndex);

%% Save
AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);
temp = string(split(MATPATH, '\'));
DateStr = temp(end - 1);
ROOTPATH = "D:\Education\Lab\monkey\ECOG\Figures\what-when\";
BPATH = strcat(ROOTPATH, DateStr, "\Behavior\");
MMNPATH = strcat(ROOTPATH, DateStr, "\MMN\");
mkdir(BPATH);
mkdir(MMNPATH);

print(FigBehavior, strcat(BPATH, "Behavior_", DateStr), "-djpeg", "-r200");

print(Fig1(1), strcat(MMNPATH, AREANAME, "_MMN_Const_Correct_Raw", DateStr), "-djpeg", "-r200");
print(Fig1(2), strcat(MMNPATH, AREANAME, "_MMN_Const_Wrong_Raw", DateStr), "-djpeg", "-r200");
print(Fig2(1), strcat(MMNPATH, AREANAME, "_MMN_Const_Correct_TFA", DateStr), "-djpeg", "-r200");
print(Fig2(2), strcat(MMNPATH, AREANAME, "_MMN_Const_Wrong_TFA", DateStr), "-djpeg", "-r200");

print(Fig3(1), strcat(MMNPATH, AREANAME, "_MMN_Rand_Correct_Raw", DateStr), "-djpeg", "-r200");
print(Fig3(2), strcat(MMNPATH, AREANAME, "_MMN_Rand_Wrong_Raw", DateStr), "-djpeg", "-r200");
print(Fig4(1), strcat(MMNPATH, AREANAME, "_MMN_Rand_Correct_TFA", DateStr), "-djpeg", "-r200");
print(Fig4(2), strcat(MMNPATH, AREANAME, "_MMN_Rand_Wrong_TFA", DateStr), "-djpeg", "-r200");

print(Fig5(1), strcat(MMNPATH, AREANAME, "_Const_Raw", DateStr), "-djpeg", "-r200");
print(Fig5(2), strcat(MMNPATH, AREANAME, "_Rand_Raw", DateStr), "-djpeg", "-r200");
print(Fig6(1), strcat(MMNPATH, AREANAME, "_Const_TFA", DateStr), "-djpeg", "-r200");
print(Fig6(2), strcat(MMNPATH, AREANAME, "_Rand_TFA", DateStr), "-djpeg", "-r200");