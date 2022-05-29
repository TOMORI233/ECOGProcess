%% Data loading
clear; clc; close all;
BLOCKPATH = 'E:\ECoG\TDT Data\chouchou\cc20220520\Block-1';
posIndex = 1; % 1-AC, 2-PFC
posStr = ["LAuC", "LPFC"];

temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs'});
epocs = temp.epocs;

temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'streams'}, 'STORE', posStr(posIndex));
streams = temp.streams;

ECOGDataset = streams.(posStr(posIndex));
fs0 = ECOGDataset.fs;

AREANAME = ["AC", "PFC"];
temp = string(split(BLOCKPATH, '\'));
DateStr = temp(end - 1);

%% Parameter setting
choiceWin = [0, 600]; % ms
fs = 300; % Hz, for downsampling

%% Processing
trialAll = ActiveProcess_7_10Freq(epocs, choiceWin);

%% Behavior
FigBehavior = plotBehaviorOnly(trialAll, "r", "7-10 Freq");
drawnow;

%% Prediction
window = [-2500, 6000]; % ms
[chMean, chStd] = joinSTD(trialAll, ECOGDataset, window);
FigSTD(1) = plotRawWave(chMean, chStd, window);
drawnow;
FigSTD(2) = plotTimeFreqAnalysis(double(chMean), fs0, fs, window);
drawnow;

%% Prediction error
window = [-2000, 2000]; % ms
devFreqAll = [trialAll.devFreq];
stdFreqAll = cellfun(@(x) x(1), {trialAll.freqSeq});
dRatioAll = roundn(devFreqAll ./ stdFreqAll, -2);
dRatio = unique(dRatioAll);
dRatio(dRatio == 0) = [];

for dIndex = 1:length(dRatio)
    trials = trialAll([trialAll.correct] == true & dRatioAll == dRatio(dIndex));
    [~, chMean, chStd] = selectEcog(ECOGDataset, trials, "dev onset", window);
    FigDEV1(dIndex) = plotRawWave(chMean, chStd, window, ['dRatio=', num2str(dRatio(dIndex)), '(N=', num2str(length(trials)), ')']);
    drawnow;
    FigDEV2(dIndex) = plotTimeFreqAnalysis(chMean, fs0, fs, window, ['dRatio=', num2str(dRatio(dIndex)), '(N=', num2str(length(trials)), ')']);
    drawnow;
end

% Scale
scaleAxes([FigDEV1, FigDEV2], "x", [-300, 1000]);
scaleAxes([FigSTD(1), FigDEV1], "y", [-80, 80]);
scaleAxes([FigSTD(2), FigDEV2], "c", [0, 20]);

%% Decision making
window = [-2000, 2000];

for dIndex = 2:length(dRatio)
    trialsC = trialAll([trialAll.correct] == true & dRatioAll == dRatio(dIndex));
    trialsW = trialAll([trialAll.correct] == false & [trialAll.interrupt] == false & dRatioAll == dRatio(dIndex));

    if isempty(trialsC) || isempty(trialsW)
        FigDM1(dIndex - 1) = figure;
        FigDM2(dIndex - 1) = figure;
        set(FigDM1(dIndex - 1), "visible", "off");
        set(FigDM2(dIndex - 1), "visible", "off");
        continue;
    end

    meanRT = mean([trialsC.firstPush]' - cellfun(@(x) x(end), {trialsC.soundOnsetSeq}'));
    
    for tIndex = 1:length(trialsW)
        trialsW(tIndex).firstPush = trialsW(tIndex).soundOnsetSeq(end) + meanRT;
    end

    [~, chMeanC, ~] = selectEcog(ECOGDataset, trialsC, "dev onset", window);
    [~, chMeanW, ~] = selectEcog(ECOGDataset, trialsW, "dev onset", window);
    FigDM1(dIndex - 1) = plotRawWave(chMeanC - chMeanW, [], window, ['dRatio=', num2str(dRatio(dIndex))]);
    drawnow;
    FigDM2(dIndex - 1) = plotTFACompare(chMeanC, chMeanW, fs0, fs, window, ['dRatio=', num2str(dRatio(dIndex))]);
    drawnow;
end

% Scale
scaleAxes([FigDM1, FigDM2], "x", [-1000, 1000]);
scaleAxes(FigDM1, "y", [-80, 80]);
cRange = scaleAxes(FigDM2, "c");

%% Layout
plotLayout([FigSTD, FigDEV1, FigDEV2, FigDM1, FigDM2], posIndex);

%% Save
ROOTPATH = "D:\Education\Lab\monkey\ECOG\Figures\7-10Freq\";
BPATH = strcat(ROOTPATH, DateStr, "\Behavior\");
PEPATH = strcat(ROOTPATH, DateStr, "\Prediction error\");
PPATH = strcat(ROOTPATH, DateStr, "\Prediction\");
DMPATH = strcat(ROOTPATH, DateStr, "\Decision making\");
mkdir(BPATH);
mkdir(PEPATH);
mkdir(PPATH);

print(FigBehavior, strcat(BPATH, "Behavior_", DateStr), "-djpeg", "-r200");
print(FigSTD(1), strcat(PPATH, AREANAME(posIndex), "_Prediction_Raw_", DateStr), "-djpeg", "-r200");
print(FigSTD(2), strcat(PPATH, AREANAME(posIndex), "_Prediction_TFA_", DateStr), "-djpeg", "-r200");

for dIndex = 1:length(FigDM1)
    print(FigDM1(dIndex), strcat(DMPATH, AREANAME(posIndex), "_DM_Raw_", num2str(dIndex + 1), "_", DateStr), "-djpeg", "-r200");
    print(FigDM2(dIndex), strcat(DMPATH, AREANAME(posIndex), "_DM_TFA_", num2str(dIndex + 1), "_", DateStr), "-djpeg", "-r200");
end

for dIndex = 1:length(FigDEV1)
    print(FigDEV1(dIndex), strcat(PEPATH, AREANAME(posIndex), "_PE_Raw_", num2str(dIndex)), "-djpeg", "-r200");
    print(FigDEV2(dIndex), strcat(PEPATH, AREANAME(posIndex), "_PE_TFA_", num2str(dIndex)), "-djpeg", "-r200");
end