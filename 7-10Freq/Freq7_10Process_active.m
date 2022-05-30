%% Data loading
clear; clc; close all;
% BLOCKPATH = 'E:\ECoG\TDT Data\chouchou\cc20220517\Block-8';
% BLOCKPATH = 'E:\ECoG\TDT Data\chouchou\cc20220518\Block-1';
% BLOCKPATH = 'E:\ECoG\TDT Data\chouchou\cc20220519\Block-3';
% BLOCKPATH = 'E:\ECoG\TDT Data\chouchou\cc20220520\Block-1';
BLOCKPATH = 'E:\ECoG\TDT Data\chouchou\cc20220525\Block-1';
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
devFreqAll = [trialAll.devFreq];
stdFreqAll = cellfun(@(x) x(1), {trialAll.freqSeq});
dRatioAll = roundn(devFreqAll ./ stdFreqAll, -2);
dRatio = unique(dRatioAll);
dRatio(dRatio == 0) = [];

%% Behavior
FigBehavior = plotBehaviorOnly(trialAll, "r", "7-10 Freq");
drawnow;

%% Temp
% window = [-2000, 2000];
% 
% trials5 = trialAll([trialAll.correct] == true & dRatioAll == dRatio(end));
% trials4 = trialAll([trialAll.correct] == true & dRatioAll == dRatio(end - 1));
% trials3 = trialAll([trialAll.correct] == true & dRatioAll == dRatio(end - 2));
% [~, chMean5, ~] = selectEcog(ECOGDataset, trials5, "dev onset", window);
% [~, chMean4, ~] = selectEcog(ECOGDataset, trials4, "dev onset", window);
% [~, chMean3, ~] = selectEcog(ECOGDataset, trials3, "dev onset", window);
% Fig1 = plotRawWave(chMean5 - chMean4, [], window, "5-4");
% Fig2 = plotRawWave(chMean5 - chMean3, [], window, "5-3");
% Fig3 = plotTFACompare(chMean5, chMean4, fs0, fs, window, "5-4");
% Fig4 = plotTFACompare(chMean5, chMean3, fs0, fs, window, "5-3");
% 
% % Scale 
% scaleAxes([Fig1, Fig2, Fig3, Fig4], "x", [-300, 1000]);
% scaleAxes([Fig1, Fig2], "y", [-50, 50]);
% scaleAxes([Fig3, Fig4], "c");
% 
% plotLayout([Fig1, Fig2], posIndex);

%% Prediction
window = [-2500, 6000]; % ms
[chMean, chStd] = joinSTD(trialAll, ECOGDataset, window);
FigP(1) = plotRawWave(chMean, chStd, window);
drawnow;
FigP(2) = plotTimeFreqAnalysis(double(chMean), fs0, fs, window);
drawnow;

%% Prediction error
window = [-2000, 2000]; % ms

for dIndex = 1:length(dRatio)
    trials = trialAll([trialAll.correct] == true & dRatioAll == dRatio(dIndex));
    [~, chMean, chStd] = selectEcog(ECOGDataset, trials, "dev onset", window);
    FigPE1(dIndex) = plotRawWave(chMean, chStd, window, ['dRatio=', num2str(dRatio(dIndex)), '(N=', num2str(length(trials)), ')']);
    drawnow;
    FigPE2(dIndex) = plotTimeFreqAnalysis(chMean, fs0, fs, window, ['dRatio=', num2str(dRatio(dIndex)), '(N=', num2str(length(trials)), ')']);
    drawnow;
end

% Scale
scaleAxes([FigPE1, FigPE2], "x", [-300, 1000]);
scaleAxes([FigP(1), FigPE1], "y", [-80, 80]);
scaleAxes([FigP(2), FigPE2], "c");

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
cRange = scaleAxes(FigDM2, "c", [-20, 20]);

%% Layout
plotLayout([FigP(1), FigPE1, FigDM1], posIndex);

%% Save
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
print(FigP(1), strcat(PPATH, AREANAME(posIndex), "_Prediction_Raw_", DateStr), "-djpeg", "-r200");
print(FigP(2), strcat(PPATH, AREANAME(posIndex), "_Prediction_TFA_", DateStr), "-djpeg", "-r200");

for dIndex = 1:length(FigDM1)
    print(FigDM1(dIndex), strcat(DMPATH, AREANAME(posIndex), "_DM_Raw_", num2str(dIndex + 1), "_", DateStr), "-djpeg", "-r200");
    print(FigDM2(dIndex), strcat(DMPATH, AREANAME(posIndex), "_DM_TFA_", num2str(dIndex + 1), "_", DateStr), "-djpeg", "-r200");
end

for dIndex = 1:length(FigPE1)
    print(FigPE1(dIndex), strcat(PEPATH, AREANAME(posIndex), "_PE_Raw_", num2str(dIndex)), "-djpeg", "-r200");
    print(FigPE2(dIndex), strcat(PEPATH, AREANAME(posIndex), "_PE_TFA_", num2str(dIndex)), "-djpeg", "-r200");
end