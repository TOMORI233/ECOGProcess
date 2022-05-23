%% Data loading
clear; clc; close all;
BLOCKPATH = 'G:\ECoG\chouchou\cc20220523\Block-1';
posIndex = 1; % 1-AC, 2-PFC

posStr = ["LAuC", "LPFC"];
temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs'});
epocs = temp.epocs;
temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'streams'}, 'STORE', posStr(posIndex));
streams = temp.streams;
fs0 = streams.(posStr(posIndex)).fs;
totalChNum = length(streams.(posStr(posIndex)).channels);

%% Params settings
window = [-1000, 1500]; % ms
choiceWin = [0, 600]; % ms
fs = 300; % Hz, for downsampling
scaleFactor = 1e6;

trialAll = ActiveProcess_1_9Freq(epocs, choiceWin);

trialsNoInterrupt = trialAll([trialAll.interrupt] == false);
ISI = fix(mean(cellfun(@(x, y) (x(end) - x(1)) / y, {trialsNoInterrupt.soundOnsetSeq}, {trialsNoInterrupt.stdNum})));

%% Behavior
trials1_3 = trialAll([trialAll.stdNum] >= 1 & [trialAll.stdNum] <= 3);
trials4_6 = trialAll([trialAll.stdNum] >= 4 & [trialAll.stdNum] <= 6);
trials7_9 = trialAll([trialAll.stdNum] >= 7 & [trialAll.stdNum] <= 9);

[Fig, mAxe] = plotBehaviorOnly(trials1_3, "k", "1 2 3");
[Fig, mAxe] = plotBehaviorOnly(trials4_6, "b", "4 5 6", Fig, mAxe);
[Fig, mAxe] = plotBehaviorOnly(trials7_9, "r", "7 8 9", Fig, mAxe);

%% 
result = cellfun(@(x) x * scaleFactor, selectEcog(streams.(posStr(posIndex)), trials1_3, "dev onset", window), "UniformOutput", false);
temp = cell2mat(result);

chMean = zeros(totalChNum, size(result{1}, 2));
chSE = zeros(totalChNum, size(result{1}, 2));

for index = 1:totalChNum
    chMean(index, :) = mean(temp(index:totalChNum:length(result) * totalChNum, :), 1);
    chSE(index, :) = std(temp(index:totalChNum:length(result) * totalChNum, :), [], 1);
end

%% Raw wave
Fig1 = plotRawWave(chMean, chSE, window);
yRange = scaleAxes(Fig1, "y", [-100, 100]);
allAxes = findobj(Fig1, "Type", "axes");
% title(allAxes(end), ['CH 1 | dRatio=', num2str(dRatio)])
for aIndex = 1:length(allAxes)
    plot(allAxes(aIndex), [0, 0], yRange, "k--", "LineWidth", 0.6);
end

drawnow;
% saveas(Fig1, strcat("figs/raw/", posStr(posIndex), "_dRatio", num2str(dRatio), "_Raw.jpg"));

%% Time-Freq
Fig2 = plotTimeFreqAnalysis(double(chMean), fs0, fs);
yRange = scaleAxes(Fig2);
cRange = scaleAxes(Fig2, "c");
allAxes = findobj(Fig2, "Type", "axes");
% title(allAxes(end), ['CH 1 | dRatio=', num2str(roundn(devFreq(dIndex) / devFreq(1), -2))])
for aIndex = 1:length(allAxes)
    plot(allAxes(aIndex), [0, 0] - window(1), yRange, "w--", "LineWidth", 0.6);
end

drawnow;
% saveas(Fig2, strcat("figs/time-freq/", posStr(posIndex), "_dRatio", num2str(dRatio), "_TFA.jpg"));
