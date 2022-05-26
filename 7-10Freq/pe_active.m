%% Data loading
clear; clc; close all;
BLOCKPATH = 'E:\ECoG\TDT Data\chouchou\cc20220520\Block-1';
posIndex = 1; % 1-AC, 2-PFC
posStr = ["LAuC", "LPFC"];

temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs'});
epocs = temp.epocs;

temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'streams'}, 'STORE', posStr(posIndex));
streams = temp.streams;

fs0 = streams.(posStr(posIndex)).fs;

%% Parameter setting
choiceWin = [0, 800]; % ms
fs = 300; % Hz, for downsampling

%% Processing
trialAll = ActiveProcess_7_10Freq(epocs, choiceWin);

%% Behavior
plotBehaviorOnly(trialAll, "r", "7-10 Freq");

%% STD
window = [-2500, 6000]; % ms
[chMean, chStd] = joinSTD(trialAll, streams.(posStr(posIndex)), window);

% Raw wave
Fig0(1) = plotRawWave(chMean, chStd, window);
drawnow;

% Time-Freq
Fig0(2) = plotTimeFreqAnalysis(double(chMean), fs0, fs, window);
drawnow;

Fig0 = plotLayout(Fig0, posIndex);

%% DEV
window = [-2000, 2000]; % ms
devFreqAll = [trialAll.devFreq];
stdFreqAll = cellfun(@(x) x(1), {trialAll.freqSeq});
dRatioAll = devFreqAll ./ stdFreqAll;
dRatio = unique(dRatioAll);
dRatio(dRatio == 0) = [];

for dIndex = 1:length(dRatio)
    trials = trialAll([trialAll.correct] == true & dRatioAll == dRatio(dIndex));
    [result, chMean, chStd] = selectEcog(streams.(posStr(posIndex)), trials, "dev onset", window);

    % Raw wave
    Fig1(dIndex) = plotRawWave(chMean, chStd, window, ['dRatio = ', num2str(dRatio(dIndex))]);
    drawnow;

    % Time-Freq
    Fig2(dIndex) = plotTimeFreqAnalysis(chMean, fs0, fs, window, ['dRatio = ', num2str(dRatio(dIndex))]);
    drawnow;
end

% Scale
scaleAxes(Fig1, "x", [-300, 1000]);
scaleAxes(Fig1, "y", [-80, 80]);
Fig1 = plotLayout(Fig1, posIndex);

scaleAxes(Fig2, "x", [-300, 1000] - window(1));
scaleAxes(Fig2);
scaleAxes([Fig0(2), Fig2], "c");
Fig2 = plotLayout(Fig2, posIndex);

%% Save
dRatio = roundn(dRatio, -2);
AREANAME = ["AC", "PFC"];
temp = string(split(BLOCKPATH, '\'));
DateStr = temp(end - 1);
DEVROOTPATH = strcat("D:\Education\Lab\monkey\ECOG\Figures\7-10Freq\", DateStr, "\DEV\");
STDROOTPATH = strcat("D:\Education\Lab\monkey\ECOG\Figures\7-10Freq\", DateStr, "\STD\");
mkdir(DEVROOTPATH);
mkdir(STDROOTPATH);

print(Fig0(1), strcat(STDROOTPATH, AREANAME(posIndex), "_STD_Raw"), "-djpeg", "-r200");
print(Fig0(2), strcat(STDROOTPATH, AREANAME(posIndex), "_STD_TFA"), "-djpeg", "-r200");

for dIndex = 1:length(Fig1)
    print(Fig1(dIndex), strcat(DEVROOTPATH, AREANAME(posIndex), "_DEV_Raw_dRatio", num2str(dIndex)), "-djpeg", "-r200");
    print(Fig2(dIndex), strcat(DEVROOTPATH, AREANAME(posIndex), "_DEV_TFA_dRatio", num2str(dIndex)), "-djpeg", "-r200");
end