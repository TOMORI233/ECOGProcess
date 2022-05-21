%% Data loading
clear; clc; close all;
BLOCKPATH = 'G:\ECoG\chouchou\cc20220521\Block-1';
posIndex = 1; % 1-AC, 2-PFC

posStr = ["LAuC", "LPFC"];
temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs'});
epocs = temp.epocs;
temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'streams'}, 'STORE', posStr(posIndex));
streams = temp.streams;

%% Processing
window = [-2000, 1000]; % ms
choiceWin = [0, 800]; % ms
fs = 300; % Hz, for downsampling
scaleFactor = 1e6;

trialAll = ActiveProcess_ECOG(epocs, choiceWin);
trialsConst = trialAll(logical(mod(ceil([trialAll.trialNum] / 20), 2)));
trialsRand = trialAll(~logical(mod(ceil([trialAll.trialNum] / 20), 2)));
[Fig, mAxe] = plotBehaviorOnly(trialsConst, "b", "Constant");
[Fig, mAxe] = plotBehaviorOnly(trialsRand, "r", "Random", Fig, mAxe);

trials = trialsConst([trialsConst.correct] == true);









trials = trialsRand([trialsRand.correct] == true);
result = cellfun(@(x) x * scaleFactor, selectEcog(streams.(posStr(posIndex)), trials, "dev onset", window), 'UniformOutput', false);
totalChNum = length(streams.(posStr(posIndex)).channels);
fs0 = streams.(posStr(posIndex)).fs;
temp = cell2mat(result);

chMean = zeros(totalChNum, size(result{1}, 2));
chSE = zeros(totalChNum, size(result{1}, 2));

for index = 1:totalChNum
    chMean(index, :) = mean(temp(index:totalChNum:length(result) * totalChNum, :), 1);
    chSE(index, :) = std(temp(index:totalChNum:length(result) * totalChNum, :), [], 1);
end

% Raw wave
Fig1 = plotRawWave(chMean, chSE, window);
yRange = scaleAxes(Fig1, "y", [-100, 100]);
allAxes = findobj(Fig1, "Type", "axes");
title(allAxes(end), ['CH 1 | dRatio=', num2str(dRatio)])
for aIndex = 1:length(allAxes)
    plot(allAxes(aIndex), [0, 0], yRange, "k--", "LineWidth", 0.6);
end
drawnow;
% saveas(Fig1, strcat("figs/raw/", posStr(posIndex), "_dRatio", num2str(dRatio), "_Raw.jpg"));

% Time-Freq
Fig2 = plotTimeFreqAnalysis(chMean, fs0, fs);
yRange = scaleAxes(Fig2);
cRange = scaleAxes(Fig2, "c");
allAxes = findobj(Fig2, "Type", "axes");
title(allAxes(end), ['CH 1 | dRatio=', num2str(roundn(devFreq(dIndex) / devFreq(1), -2))])
for aIndex = 1:length(allAxes)
    plot(allAxes(aIndex), [0, 0] - window(1), yRange, "w--", "LineWidth", 0.6);
end
drawnow;
% saveas(Fig2, strcat("figs/time-freq/", posStr(posIndex), "_dRatio", num2str(dRatio), "_TFA.jpg"));