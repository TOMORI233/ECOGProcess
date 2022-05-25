addpath(genpath("..\..\ECOGProcess"));
%% Data loading
clear; clc; close all;
BLOCKPATH = 'G:\ECoG\chouchou\cc20220524\Block-1';
posIndex = 1; % 1-AC, 2-PFC

posStr = ["LAuC", "LPFC"];
temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs'});
epocs = temp.epocs;
temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'streams'}, 'STORE', posStr(posIndex));
streams = temp.streams;
fs0 = streams.(posStr(posIndex)).fs;
totalChNum = length(streams.(posStr(posIndex)).channels);

%% Params settings
window = [-3000, 3000]; % ms
choiceWin = [0, 600]; % ms
fs = 300; % Hz, for downsampling
scaleFactor = 1e6;

%% Behavior processing
trialAll = ActiveProcess_1_9Freq(epocs, choiceWin);
trialsNoInterrupt = trialAll([trialAll.interrupt] == false);
ISI = fix(mean(cellfun(@(x, y) (x(end) - x(1)) / y, {trialsNoInterrupt.soundOnsetSeq}, {trialsNoInterrupt.stdNum})));

%% Plot behavior result
trials1_3 = trialAll([trialAll.stdNum] >= 1 & [trialAll.stdNum] <= 3);
trials4_6 = trialAll([trialAll.stdNum] >= 4 & [trialAll.stdNum] <= 6);
trials7_9 = trialAll([trialAll.stdNum] >= 7 & [trialAll.stdNum] <= 9);
[Fig, mAxe] = plotBehaviorOnly(trials1_3, "k", "1 2 3");
[Fig, mAxe] = plotBehaviorOnly(trials4_6, "b", "4 5 6", Fig, mAxe);
[Fig, mAxe] = plotBehaviorOnly(trials7_9, "r", "7 8 9", Fig, mAxe);

%% ECOG
trials = [{trials1_3([trials1_3.correct] == true)}; ...
          {trials4_6([trials4_6.correct] == true)}; ...
          {trials7_9([trials7_9.correct] == true)}];
legendStr = ["1-3", "4-6", "7-9"];

for tIndex = 1:length(trials)
    result = cellfun(@(x) x * scaleFactor, selectEcog(streams.(posStr(posIndex)), trials{tIndex}, "dev onset", window), "UniformOutput", false);
    temp = cell2mat(result);
    chMean = zeros(totalChNum, size(result{1}, 2));
    chSE = zeros(totalChNum, size(result{1}, 2));
    
    for index = 1:totalChNum
        chMean(index, :) = mean(temp(index:totalChNum:length(result) * totalChNum, :), 1);
        chSE(index, :) = std(temp(index:totalChNum:length(result) * totalChNum, :), [], 1);
    end

    %% Raw wave
    Fig1(tIndex) = plotRawWave(chMean, chSE, window);
    set(Fig1(tIndex), "NumberTitle", "off", "Name", legendStr(tIndex));
    
    %% Time-Freq
    Fig2(tIndex) = plotTimeFreqAnalysis(double(chMean), fs0, fs);
    set(Fig2(tIndex), "NumberTitle", "off", "Name", legendStr(tIndex));
end

%% Scale
scaleAxes(Fig1, "x", [-300, 1000]);
yRange = scaleAxes(Fig1, "y", [-50, 50]);
allAxes = findobj(Fig1, "Type", "axes");
for aIndex = 1:length(allAxes)
    plot(allAxes(aIndex), [0, 0], yRange, "k--", "LineWidth", 0.6);
end
drawnow;

scaleAxes(Fig2, "x", [-300, 1000] - window(1));
yRange = scaleAxes(Fig2);
cRange = scaleAxes(Fig2, "c");
allAxes = findobj(Fig2, "Type", "axes");
for aIndex = 1:length(allAxes)
    plot(allAxes(aIndex), [0, 0] - window(1), yRange, "w--", "LineWidth", 0.6);
end
drawnow;