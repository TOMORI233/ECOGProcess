clear; clc;
%% Parameter settings
params.posIndex = 1; % 1-AC, 2-PFC
params.choiceWin = [100, 600];
params.processFcn = @ActiveProcess_freqLoc;

fs = 500; % Hz, for downsampling

%% Processing
% DATAPATH = 'E:\ECoG\xiaoxiao\xx20220907\Block-1';
MATPATH = 'E:\ECoG\MAT Data\XX\BlkFreqLoc Active\xx20220905\xx20220905_AC.mat';
[trialAll, ECOGDataset] = ECOGPreprocess(MATPATH, params);
ECOGDatasetTemp = ECOGDataset;
fs0 = ECOGDataset.fs;



%% ICA
window  = [-2000, 2000];
comp = mICA(ECOGDataset, trialAll([trialAll.oddballType]' ~= "INTERRUPT"), window, "dev onset", fs);
t1 = [-2000, -1500, -1000, -500, 0];
t2 = t1 + 200;
comp = realignIC(comp, window, t1, t2);
ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
plotRawWave(ICMean, [], window, "ICA", [8, 8]);
plotTFA(ICMean, fs, [], window, "ICA", [8, 8]);
plotTopoICA(comp, [8, 8]);
ECOGDataset.data = comp.unmixing * ECOGDatasetTemp.data;


ECOGDataset.data = ECOGDatasetTemp.data;


% comp = reverseIC(comp, input("IC to reverse: "));
% ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
% plotRawWave(ICMean, [], window, "ICA", [4, 5]);
% plotTFA(ICMean, fs, [], window, "ICA", [4, 5]);
% plotTopoICA(comp, [8, 8], [4, 5]);
%% trial select
block1Idx = mod([trialAll.trialNum]', 80) >= 1 & mod([trialAll.trialNum]', 80) <= 20;
block2Idx = mod([trialAll.trialNum]', 80) >= 21 & mod([trialAll.trialNum]', 80) <= 40;
block3Idx = mod([trialAll.trialNum]' - 1, 80) >= 40 & mod([trialAll.trialNum]', 80) <= 79;
stdFreq = unique([trialAll([trialAll.oddballType]' == "STD").devFreq]);
stdLoc = unique([trialAll([trialAll.oddballType]' == "STD").devLoc]);
trialsBlkFreq = trialAll([trialAll.devLoc]' == stdLoc & block1Idx);
trialsRandFreq = trialAll([trialAll.devLoc]' == stdLoc & block3Idx);
trialsBlkLoc = trialAll([trialAll.devFreq]' == stdFreq & block2Idx);
trialsRandLoc = trialAll([trialAll.devFreq]' == stdFreq & block3Idx);

devType = [trialAll.devType]';
dRatio = unique(devType(([trialAll.devType]' > 0)));

%% Behavior
[Fig, mAxe, ~, ~] = plotBehaviorOnly(trialsBlkFreq, "r", "block freq");
[Fig, mAxe, ~, ~] = plotBehaviorOnly(trialsRandFreq, "m", "rand freq", Fig, mAxe, "freq");
[Fig, mAxe, ~, ~] = plotBehaviorOnly(trialsBlkLoc, "b", "block loc", Fig, mAxe, "loc");
[Fig, mAxe, ~, ~] = plotBehaviorOnly(trialsRandLoc, "k", "rand loc", Fig, mAxe, "loc");



%% 
% window = [-2000, 2000];
% 
% for dIndex = 1:length(dRatio)
%     trials = trialAll([trialAll.correct] == true & dRatioAll == dRatio(dIndex));
%     [result, chMean, ~] = selectEcog(ECOGDataset, trials, "dev onset", window);
%     chData = struct("chMean", result, "color", repmat({[0.5, 0.5, 0.5]}, length(result), 1));
%     chData0.chMean = chMean;
%     chData0.color = "r";
%     Fig = plotRawWaveMulti([chData; chData0], window, strcat("dRatio = ", num2str(dRatio(dIndex))));
%     scaleAxes(Fig, "x", [-500, 1000]);
%     scaleAxes(Fig, "y", [], [-80, 80], "max");
%     drawnow;
% end

%% MMN - PE
window = [-2000, 2000];
colors = ["k", "b", "#FFA500", "r"];
for dIndex = 2 : length(dRatio)

% block freq
trialsBlkFreqC = trialsBlkFreq([trialsBlkFreq.devType]' == dIndex &  [trialsBlkFreq.correct]' == true);
trialsBlkFreqW = trialsBlkFreq([trialsBlkFreq.devType]' == dIndex &  [trialsBlkFreq.correct]' == false);
[resultBlkFreqDEVC, chMeanBlkFreqDEVC, ~] = selectEcog(ECOGDataset, trialsBlkFreqC, "dev onset", window);
[resultBlkFreqSTDC, chMeanBlkFreqSTDC, ~] = selectEcog(ECOGDataset, trialsBlkFreqC, "last std", window);
[resultBlkFreqDEVW, chMeanBlkFreqDEVW, ~] = selectEcog(ECOGDataset, trialsBlkFreqW, "dev onset", window);
[resultBlkFreqSTDW, chMeanBlkFreqSTDW, ~] = selectEcog(ECOGDataset, trialsBlkFreqW, "last std", window);
chMeanBlkFreqC(dIndex - 1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultBlkFreqDEVC - resultBlkFreqSTDC), "UniformOutput", false));
chMeanBlkFreqW(dIndex - 1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultBlkFreqDEVW - resultBlkFreqSTDW), "UniformOutput", false));
chMeanBlkFreqC(dIndex - 1).color = colors(dIndex - 1);
chMeanBlkFreqW(dIndex - 1).color = colors(dIndex - 1);

% rand freq
trialsRandFreqC = trialsRandFreq([trialsRandFreq.devType]' == dIndex &  [trialsRandFreq.correct]' == true);
trialsRandFreqW = trialsRandFreq([trialsRandFreq.devType]' == dIndex &  [trialsRandFreq.correct]' == false);
[resultRandFreqDEVC, chMeanRandFreqDEVC, ~] = selectEcog(ECOGDataset, trialsRandFreqC, "dev onset", window);
[resultRandFreqSTDC, chMeanRandFreqSTDC, ~] = selectEcog(ECOGDataset, trialsRandFreqC, "last std", window);
[resultRandFreqDEVW, chMeanRandFreqDEVW, ~] = selectEcog(ECOGDataset, trialsRandFreqW, "dev onset", window);
[resultRandFreqSTDW, chMeanRandFreqSTDW, ~] = selectEcog(ECOGDataset, trialsRandFreqW, "last std", window);
chMeanRandFreqC(dIndex - 1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultRandFreqDEVC - resultRandFreqSTDC), "UniformOutput", false));
chMeanRandFreqW(dIndex - 1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultRandFreqDEVW - resultRandFreqSTDW), "UniformOutput", false));
chMeanRandFreqC(dIndex - 1).color = colors(dIndex - 1);
chMeanRandFreqW(dIndex - 1).color = colors(dIndex - 1);

% block Loc
trialsBlkLocC = trialsBlkLoc([trialsBlkLoc.devType]' == dIndex &  [trialsBlkLoc.correct]' == true);
trialsBlkLocW = trialsBlkLoc([trialsBlkLoc.devType]' == dIndex &  [trialsBlkLoc.correct]' == false);
[resultBlkLocDEVC, chMeanBlkLocDEVC, ~] = selectEcog(ECOGDataset, trialsBlkLocC, "dev onset", window);
[resultBlkLocSTDC, chMeanBlkLocSTDC, ~] = selectEcog(ECOGDataset, trialsBlkLocC, "last std", window);
[resultBlkLocDEVW, chMeanBlkLocDEVW, ~] = selectEcog(ECOGDataset, trialsBlkLocW, "dev onset", window);
[resultBlkLocSTDW, chMeanBlkLocSTDW, ~] = selectEcog(ECOGDataset, trialsBlkLocW, "last std", window);
chMeanBlkLocC(dIndex - 1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultBlkLocDEVC - resultBlkLocSTDC), "UniformOutput", false));
chMeanBlkLocW(dIndex - 1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultBlkLocDEVW - resultBlkLocSTDW), "UniformOutput", false));
chMeanBlkLocC(dIndex - 1).color = colors(dIndex - 1);
chMeanBlkLocW(dIndex - 1).color = colors(dIndex - 1);

% rand Loc
trialsRandLocC = trialsRandLoc([trialsRandLoc.devType]' == dIndex &  [trialsRandLoc.correct]' == true);
trialsRandLocW = trialsRandLoc([trialsRandLoc.devType]' == dIndex &  [trialsRandLoc.correct]' == false);
[resultRandLocDEVC, chMeanRandLocDEVC, ~] = selectEcog(ECOGDataset, trialsRandLocC, "dev onset", window);
[resultRandLocSTDC, chMeanRandLocSTDC, ~] = selectEcog(ECOGDataset, trialsRandLocC, "last std", window);
[resultRandLocDEVW, chMeanRandLocDEVW, ~] = selectEcog(ECOGDataset, trialsRandLocW, "dev onset", window);
[resultRandLocSTDW, chMeanRandLocSTDW, ~] = selectEcog(ECOGDataset, trialsRandLocW, "last std", window);
chMeanRandLocC(dIndex - 1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultRandLocDEVC - resultRandLocSTDC), "UniformOutput", false));
chMeanRandLocW(dIndex - 1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultRandLocDEVW - resultRandLocSTDW), "UniformOutput", false));
chMeanRandLocC(dIndex - 1).color = colors(dIndex - 1);
chMeanRandLocW(dIndex - 1).color = colors(dIndex - 1);
end

% plot raw wave
MMNBlkWaveFig(1) = plotRawWaveMulti(chMeanBlkFreqC, window, "blkFreq C:DEV-last STD");
MMNBlkWaveFig(2) = plotRawWaveMulti(chMeanBlkLocC, window, "blkLoc C:DEV-last STD");
MMNRandWaveFig(1) = plotRawWaveMulti(chMeanRandFreqC, window, "randFreq C:DEV-last STD");
MMNRandWaveFig(2) = plotRawWaveMulti(chMeanRandLocC, window, "randLoc C:DEV-last STD");

% plot TFA
% for dIndex = 1 : length(devRatio)
% Fig2(1) = plotTFACompare(chMeanDEVC, chMeanSTDC, fs0, fs, window, "C:DEV-last STD");
% Fig2(2) = plotTFACompare(chMeanDEVW, chMeanSTDW, fs0, fs, window, "W:DEV-last STD");

scaleAxes([MMNBlkWaveFig, MMNRandWaveFig], "x", [-200, 1000]);
scaleAxes([MMNBlkWaveFig, MMNRandWaveFig], "y", [], [-60, 60], "max");
% scaleAxes(Fig2, "c", [], [-20, 20]);

%% Prediction
trialsBlkFreq = trialAll([trialAll.devLoc]' == stdLoc & block1Idx);
trialsRand = trialAll([trialAll.oddballType]' ~= "INTERRUPT" & block3Idx);
trialsBlkLoc = trialAll([trialAll.devFreq]' == stdFreq & block2Idx);

window = [-2500, 6000]; % ms
PETitle = ["block freq", "block loc", "rand"];
[~, chMeanP(1).chMean, ~] = joinSTD(trialsBlkFreq([trialsBlkFreq.correct] == true), ECOGDataset);
[~, chMeanP(2).chMean, ~] = joinSTD(trialsBlkLoc([trialsBlkLoc.correct] == true), ECOGDataset);
[~, chMeanP(3).chMean, ~] = joinSTD(trialsRand([trialsRand.correct] == true), ECOGDataset);
chMeanP(1).color = "r"; chMeanP(2).color = "b"; chMeanP(3).color = "k"; 
trialN = [length(trialsBlkFreq), length(trialsBlkLoc), length(trialsRand)];
FigPWave = plotRawWaveMulti(chMeanP, window, strcat("prediction, Nbf=", num2str(trialN(1)), ",Nbl=", num2str(trialN(2)), "Nr=", num2str(trialN(3))));
drawnow;
scaleAxes(FigPWave, "y", [-80, 80]);

for bIndex = 1 : 3
FigPTFA(bIndex) = plotTFA(chMeanP(bIndex).chMean, fs0, fs, window, strcat("prediction", PETitle(bIndex), "num=", num2str(trialN(bIndex))));
drawnow;
end
scaleAxes(FigPTFA, "c", [0, 10]);



%% Prediction error
window = [-2000, 2000]; % ms
colors = ["k", "b", "#FFA500", "r"];
for dIndex = 2:length(dRatio)
    trialsBlkFreqC = trialsBlkFreq([trialsBlkFreq.devType]' == dIndex &  [trialsBlkFreq.correct]' == true);
    trialsBlkLocC = trialsBlkLoc([trialsBlkLoc.devType]' == dIndex &  [trialsBlkLoc.correct]' == true);
    trialsRandFreqC = trialsRandFreq([trialsRandFreq.devType]' == dIndex &  [trialsRandFreq.correct]' == true);
    trialsRandLocC = trialsRandLoc([trialsRandLoc.devType]' == dIndex &  [trialsRandLoc.correct]' == true);
    [~, chMeanBlkFreqC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsBlkFreqC, "dev onset", window);
    chMeanBlkFreqC(dIndex - 1).color = colors(dIndex - 1);
    [~, chMeanRandFreqC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsRandFreqC, "dev onset", window);
    chMeanRandFreqC(dIndex - 1).color = colors(dIndex - 1);
    [~, chMeanBlkLocC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsBlkLocC, "dev onset", window);
    chMeanBlkLocC(dIndex - 1).color = colors(dIndex - 1);
    [~, chMeanRandLocC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsRandLocC, "dev onset", window);
    chMeanRandLocC(dIndex - 1).color = colors(dIndex - 1);
end
% plot raw wave
PEBlkWaveFig(1) = plotRawWaveMulti(chMeanBlkFreqC, window, "PE: blkFreq"); drawnow;
PEBlkWaveFig(2) = plotRawWaveMulti(chMeanBlkLocC, window, "PE: blkLoc"); drawnow;
PERandWaveFig(1) = plotRawWaveMulti(chMeanRandFreqC, window, "PE: randFreq"); drawnow;
PERandWaveFig(2) = plotRawWaveMulti(chMeanRandLocC, window, "PE: randLoc"); drawnow;

%     FigPE2(dIndex) = plotTFA(chMean, fs0, fs, window, ['dRatio=', num2str(dRatio(dIndex)), '(N=', num2str(length(trials)), ')']);
%     drawnow;

% Scale
scaleAxes([PEBlkWaveFig, PERandWaveFig], "x", [-200, 1000]);
scaleAxes([PEBlkWaveFig, PERandWaveFig], "y", [-3, 3]);
% scaleAxes([FigP(2), FigPE2], "c", [], [0, 15]);

%% Decision making
window = [-2000, 2000];
colors = ["r", "b", "#FFC0CB", "#4682B4"];
trialStr = ["trialsBlkFreq", "trialsRandFreq", "trialsBlkLoc", "trialsRandLoc"];
for tIndex = 1 : length(trialStr)
eval(strcat("trialTemp = ", trialStr(tIndex), ";")); 
resultC = [];
resultW = [];

for dIndex = 2
    trials = trialTemp([trialTemp.devType]' == dRatio(dIndex));
    [result, ~, ~] = selectEcog(ECOGDataset, trials, "dev onset", window);
    result = changeCellRowNum(cellfun(@zscore, changeCellRowNum(result), "UniformOutput", false));
    resultC = [resultC; result([trials.correct] == true)];
    resultW = [resultW; result([trials.correct] == false & [trials.interrupt] == false)];
end

chMeanC = cell2mat(cellfun(@mean, changeCellRowNum(resultC), "UniformOutput", false));
chMeanW = cell2mat(cellfun(@mean, changeCellRowNum(resultW), "UniformOutput", false));
chMeanDM(tIndex).chMean = chMeanC - chMeanW;
chMeanDM(tIndex).chMeanC = chMeanC;
chMeanDM(tIndex).chMeanW = chMeanW;
chMeanDM(tIndex).resultC = resultC;
chMeanDM(tIndex).resultW = resultW;
chMeanDM(tIndex).color = colors(tIndex);
end

FigDM1 = plotRawWaveMulti(chMeanDM, window, "decision making C-W");
% FigDM1 = plotRawWave(chMeanC - chMeanW, [], window, ['C', num2str(length(resultC)), 'W', num2str(length(resultW))]);
drawnow;
for tIndex = 1 : length(trialStr)
FigDM2(tIndex) = plotTFACompare(chMeanDM(tIndex).chMeanC, chMeanDM(tIndex).chMeanW, fs0, fs, window, strcat(trialStr(tIndex), "C", num2str(length(chMeanDM(tIndex).resultC)), "W", num2str(length(chMeanDM(tIndex).resultW))));
drawnow;
end

% Scale
scaleAxes([FigDM1, FigDM2], "x", [-200, 1000]);
scaleAxes(FigDM1, "y");
cRange = scaleAxes(FigDM2, "c", [], [-0.1, 0.1], "max");

%% Motion response
% window = [-3000, 2000];
% [~, chMean, chStd] = selectEcog(ECOGDataset, trialAll([trialAll.correct] == true & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV"), "push onset", window);
% FigTemp(1) = plotRawWave(chMean, chStd, window, "push onset");
% FigTemp(2) = plotTFA(chMean, fs0, fs, window, "push onset");
% scaleAxes(FigTemp, "x", [-1000, 2000]);
% scaleAxes(FigTemp(1), "y", [], [-80, 80]);
% scaleAxes(FigTemp(2), "c", [], [0, 20]);

%% Layout
% plotLayout([FigP(1), FigPE1, FigDM1], posIndex);

%% Save
% AREANAME = ["AC", "PFC"];
% AREANAME = AREANAME(params.posIndex);
% temp = string(split(BLOCKPATH, '\'));
% DateStr = temp(end - 1);
% ROOTPATH = "D:\Education\Lab\monkey\ECOG\Figures\7-10Freq\";
% BPATH = strcat(ROOTPATH, DateStr, "\Behavior\");
% PEPATH = strcat(ROOTPATH, DateStr, "\Prediction error\");
% PPATH = strcat(ROOTPATH, DateStr, "\Prediction\");
% DMPATH = strcat(ROOTPATH, DateStr, "\Decision making\");
% mkdir(BPATH);
% mkdir(PEPATH);
% mkdir(PPATH);
% mkdir(DMPATH);
% 
% print(FigBehavior, strcat(BPATH, "Behavior_", DateStr), "-djpeg", "-r200");
% print(FigP(1), strcat(PPATH, AREANAME, "_Prediction_Raw_", DateStr), "-djpeg", "-r200");
% print(FigP(2), strcat(PPATH, AREANAME, "_Prediction_TFA_", DateStr), "-djpeg", "-r200");
% 
% print(FigDM1, strcat(DMPATH, AREANAME, "_DM_Raw_", DateStr), "-djpeg", "-r200");
% print(FigDM2, strcat(DMPATH, AREANAME, "_DM_TFA_", DateStr), "-djpeg", "-r200");
% 
% for dIndex = 1:length(FigPE1)
%     print(FigPE1(dIndex), strcat(PEPATH, AREANAME, "_PE_Raw_", num2str(dIndex), "_", DateStr), "-djpeg", "-r200");
%     print(FigPE2(dIndex), strcat(PEPATH, AREANAME, "_PE_TFA_", num2str(dIndex), "_", DateStr), "-djpeg", "-r200");
% end