clear; clc;
%% Parameter settings
params.posIndex = 1; % 1-AC, 2-PFC
params.choiceWin = [100, 600];
params.processFcn = @ActiveProcess_7_10Freq;

fs = 500; % Hz, for downsampling

%% Processing
MATPATH = 'E:\ECoG\MAT Data\CC\7-10Freq Active\cc20220519\cc20220519_AC.mat';
[trialAll, ECOGDataset] = ECOGPreprocess(MATPATH, params);
fs0 = ECOGDataset.fs;

%% ICA
window  = [-2000, 2000];
comp = mICA(ECOGDataset, trialAll(10:40), window, "dev onset", fs);

%% rearrange
comp1 = rearrangeIC(comp, window, [-2000, -1500, -1000, -500, 0], 200);
ICMean2 = cell2mat(cellfun(@mean, changeCellRowNum(comp1.trial), "UniformOutput", false));
plotRawWave(ICMean2, [], window, "rearrange");
plotTFA(ICMean2, fs, [], window, "rearrange");
plotTopo(comp1);

%% reconstruction
ICs = 2;
comp2 = reconstructData(comp1, ICs);
chMeanRec = cell2mat(cellfun(@mean, changeCellRowNum(comp2.trial), "UniformOutput", false));
plotRawWave(chMeanRec, [], window, "reconstruct");
plotTFA(chMeanRec, fs, [], window, "reconstruct");

%%
devFreqAll = [trialAll.devFreq];
stdFreqAll = cellfun(@(x) x(1), {trialAll.freqSeq});
dRatioAll = roundn(devFreqAll ./ stdFreqAll, -2);
dRatio = unique(dRatioAll);
dRatio(dRatio == 0) = [];

%% Behavior
FigBehavior = plotBehaviorOnly(trialAll, "r", "7-10 Freq");
drawnow;

%% MMN - PE
window = [-2000, 2000];
trialsC = trialAll([trialAll.correct] == true & [trialAll.oddballType] == "DEV");
trialsW = trialAll([trialAll.correct] == false & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV");
[resultDEVC, chMeanDEVC, ~] = selectEcog(ECOGDataset, trialsC, "dev onset", window);
[resultSTDC, chMeanSTDC, ~] = selectEcog(ECOGDataset, trialsC, "last std", window);
[resultDEVW, chMeanDEVW, ~] = selectEcog(ECOGDataset, trialsW, "dev onset", window);
[resultSTDW, chMeanSTDW, ~] = selectEcog(ECOGDataset, trialsW, "last std", window);
chMeanC = cell2mat(cellfun(@(x) mean(comp.unmixing * x), changeCellRowNum(resultDEVC - resultSTDC), "UniformOutput", false));
chMeanW = cell2mat(cellfun(@(x) mean(comp.unmixing * x), changeCellRowNum(resultDEVW - resultSTDW), "UniformOutput", false));
Fig1(1) = plotRawWave(chMeanC, [], window, "C:DEV-last STD");
Fig1(2) = plotRawWave(chMeanW, [], window, "W:DEV-last STD");
Fig2(1) = plotTFACompare(chMeanDEVC, chMeanSTDC, fs0, fs, window, "C:DEV-last STD");
Fig2(2) = plotTFACompare(chMeanDEVW, chMeanSTDW, fs0, fs, window, "W:DEV-last STD");
scaleAxes([Fig1, Fig2], "x", [0, 500]);
scaleAxes(Fig1, "y", [], [-60, 60], "max");
scaleAxes(Fig2, "c", [], [-20, 20]);

%% Prediction
window = [-2500, 6000]; % ms
[~, chMean, ~] = joinSTD(trialAll([trialAll.correct] == true), ECOGDataset, window);
FigP(1) = plotRawWave(chMean, [], window);
drawnow;
FigP(2) = plotTFA(chMean, fs0, fs, window);
drawnow;

%% Prediction error
window = [-2000, 2000]; % ms

for dIndex = 1:length(dRatio)
    trials = trialAll([trialAll.correct] == true & dRatioAll == dRatio(dIndex));
    [~, chMean, chStd] = selectEcog(ECOGDataset, trials, "dev onset", window);
    FigPE1(dIndex) = plotRawWave(chMean, chStd, window, ['dRatio=', num2str(dRatio(dIndex)), '(N=', num2str(length(trials)), ')']);
    drawnow;
    FigPE2(dIndex) = plotTFA(chMean, fs0, fs, window, ['dRatio=', num2str(dRatio(dIndex)), '(N=', num2str(length(trials)), ')']);
    drawnow;
end

% Scale
scaleAxes([FigPE1, FigPE2], "x", [-1500, 2000]);
scaleAxes([FigP(1), FigPE1], "y", [-80, 80]);
scaleAxes([FigP(2), FigPE2], "c", [], [0, 15]);

%% Decision making
window = [-2000, 2000];
resultC = [];
resultW = [];

for dIndex = 2:length(dRatio)
    trials = trialAll(dRatioAll == dRatio(dIndex));
    [result, ~, ~] = selectEcog(ECOGDataset, trials, "dev onset", window);
    result = changeCellRowNum(cellfun(@zscore, changeCellRowNum(result), "UniformOutput", false));
    resultC = [resultC; result([trials.correct] == true)];
    resultW = [resultW; result([trials.correct] == false & [trials.interrupt] == false)];
end

chMeanC = cell2mat(cellfun(@mean, changeCellRowNum(resultC), "UniformOutput", false));
chMeanW = cell2mat(cellfun(@mean, changeCellRowNum(resultW), "UniformOutput", false));
FigDM1 = plotRawWave(chMeanC - chMeanW, [], window, ['C', num2str(length(resultC)), 'W', num2str(length(resultW))]);
drawnow;
FigDM2 = plotTFACompare(chMeanC, chMeanW, fs0, fs, window, ['C', num2str(length(resultC)), 'W', num2str(length(resultW))]);
drawnow;

% Scale
scaleAxes([FigDM1, FigDM2], "x", [-1000, 1000]);
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
plotLayout([FigP(1), FigPE1, FigDM1], posIndex);

%% Save
AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);
temp = string(split(BLOCKPATH, '\'));
DateStr = temp(end - 1);
ROOTPATH = "D:\Education\Lab\monkey\ECOG\Figures\7-10Freq\";
BPATH = strcat(ROOTPATH, DateStr, "\Behavior\");
PEPATH = strcat(ROOTPATH, DateStr, "\Prediction error\");
PPATH = strcat(ROOTPATH, DateStr, "\Prediction\");
DMPATH = strcat(ROOTPATH, DateStr, "\Decision making\");
mkdir(BPATH);
mkdir(PEPATH);
mkdir(PPATH);
mkdir(DMPATH);

print(FigBehavior, strcat(BPATH, "Behavior_", DateStr), "-djpeg", "-r200");
print(FigP(1), strcat(PPATH, AREANAME, "_Prediction_Raw_", DateStr), "-djpeg", "-r200");
print(FigP(2), strcat(PPATH, AREANAME, "_Prediction_TFA_", DateStr), "-djpeg", "-r200");

print(FigDM1, strcat(DMPATH, AREANAME, "_DM_Raw_", DateStr), "-djpeg", "-r200");
print(FigDM2, strcat(DMPATH, AREANAME, "_DM_TFA_", DateStr), "-djpeg", "-r200");

for dIndex = 1:length(FigPE1)
    print(FigPE1(dIndex), strcat(PEPATH, AREANAME, "_PE_Raw_", num2str(dIndex), "_", DateStr), "-djpeg", "-r200");
    print(FigPE2(dIndex), strcat(PEPATH, AREANAME, "_PE_TFA_", num2str(dIndex), "_", DateStr), "-djpeg", "-r200");
end