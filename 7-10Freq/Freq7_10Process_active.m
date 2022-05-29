%% Data loading
clear; clc; close all;
BLOCKPATH = 'E:\ECoG\TDT Data\chouchou\cc20220517\Block-8';
posIndex = 1; % 1-AC, 2-PFC
posStr = ["LAuC", "LPFC"];

temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs'});
epocs = temp.epocs;

temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'streams'}, 'STORE', posStr(posIndex));
streams = temp.streams;

ECOGDataset = streams.(posStr(posIndex));
fs0 = ECOGDataset.fs;

%% Parameter setting
choiceWin = [0, 800]; % ms
fs = 300; % Hz, for downsampling

%% Processing
trialAll = ActiveProcess_7_10Freq(epocs, choiceWin);

%% Behavior
plotBehaviorOnly(trialAll, "r", "7-10 Freq");

%% 7-10
window = [-1500, 2000];

for sIndex = 7:10
    trials = trialAll([trialAll.stdNum] == sIndex & [trialAll.correct] == true & [trialAll.oddballType] == "STD");
    [~, chMean, chStd] = selectEcog(ECOGDataset, trials, "dev onset", window);

    % Raw wave
    Fig1(sIndex - 6) = plotRawWave(chMean, chStd, window, ['std number = ', num2str(sIndex)]);
    drawnow;

    % TFA
    Fig2(sIndex - 6) = plotTimeFreqAnalysis(chMean, fs0, fs, window, ['std number = ', num2str(sIndex)]);
    drawnow;
end

% Scale
scaleAxes(Fig1, "y", [-80, 80]);
scaleAxes(Fig1, "x", [-1000, 1500]);
plotLayout(Fig1, posIndex);

scaleAxes(Fig2);
scaleAxes(Fig2, "x", [-1000, 1500]);
cRange = scaleAxes(Fig2, "c", [0, 30]);
plotLayout(Fig2, posIndex);

%% STD
window = [-2500, 6000]; % ms
[chMean, chStd] = joinSTD(trialAll, ECOGDataset, window);

% Raw wave
FigSTD(1) = plotRawWave(chMean, chStd, window);
drawnow;

% Time-Freq
FigSTD(2) = plotTimeFreqAnalysis(double(chMean), fs0, fs, window);
drawnow;

FigSTD = plotLayout(FigSTD, posIndex);

%% DEV
window = [-2000, 2000]; % ms
devFreqAll = [trialAll.devFreq];
stdFreqAll = cellfun(@(x) x(1), {trialAll.freqSeq});
dRatioAll = devFreqAll ./ stdFreqAll;
dRatio = unique(dRatioAll);
dRatio(dRatio == 0) = [];

for dIndex = 1:length(dRatio)
    trials = trialAll([trialAll.correct] == true & dRatioAll == dRatio(dIndex));
    [~, chMean, chStd] = selectEcog(ECOGDataset, trials, "dev onset", window);

    % Raw wave
    FigDEV1(dIndex) = plotRawWave(chMean, chStd, window, ['dRatio = ', num2str(dRatio(dIndex))]);
    drawnow;

    % Time-Freq
    FigDEV2(dIndex) = plotTimeFreqAnalysis(chMean, fs0, fs, window, ['dRatio = ', num2str(dRatio(dIndex))]);
    drawnow;
end

% Scale
scaleAxes(FigDEV1, "x", [-300, 1000]);
scaleAxes(FigDEV1, "y", [-80, 80]);
FigDEV1 = plotLayout(FigDEV1, posIndex);

scaleAxes(FigDEV2);
scaleAxes([FigSTD(2), FigDEV2], "c");
FigDEV2 = plotLayout(FigDEV2, posIndex);

%% Save
dRatio = roundn(dRatio, -2);
AREANAME = ["AC", "PFC"];
temp = string(split(BLOCKPATH, '\'));
DateStr = temp(end - 1);
DEVROOTPATH = strcat("D:\Education\Lab\monkey\ECOG\Figures\7-10Freq\", DateStr, "\DEV\");
STDROOTPATH = strcat("D:\Education\Lab\monkey\ECOG\Figures\7-10Freq\", DateStr, "\STD\");
mkdir(DEVROOTPATH);
mkdir(STDROOTPATH);

print(FigSTD(1), strcat(STDROOTPATH, AREANAME(posIndex), "_STD_Raw"), "-djpeg", "-r200");
print(FigSTD(2), strcat(STDROOTPATH, AREANAME(posIndex), "_STD_TFA"), "-djpeg", "-r200");

for dIndex = 1:length(FigDEV1)
    print(FigDEV1(dIndex), strcat(DEVROOTPATH, AREANAME(posIndex), "_DEV_Raw_dRatio", num2str(dIndex)), "-djpeg", "-r200");
    print(FigDEV2(dIndex), strcat(DEVROOTPATH, AREANAME(posIndex), "_DEV_TFA_dRatio", num2str(dIndex)), "-djpeg", "-r200");
end