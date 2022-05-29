addpath(genpath("..\..\ECOGProcess"));
%% Data loading
clear; clc; close all;
BLOCKPATH = 'G:\ECoG\chouchou\cc20220528\Block-1';
posIndex = 1; % 1-AC, 2-PFC
pairStr = {'4-4.06RC','4-4.06RD','4-4.06IC','4-4.06ID','4-4.06InC','4-4.06InD','40-40.6RC','40-40.6RD','Tone-C','Tone-D'};
posStr = ["LAuC", "LPFC"];
temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs'});
epocs = temp.epocs;
soundDuration = 600; % ms
% temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'streams'}, 'STORE', posStr(posIndex));
% streams = temp.streams;
% fs0 = streams.(posStr(posIndex)).fs;
% totalChNum = length(streams.(posStr(posIndex)).channels);

%% Params settings
window = [-3000, 3000]; % ms
choiceWin = [-300, 1000]; % ms
fs = 300; % Hz, for downsampling
scaleFactor = 1e6;

%% Behavior processing
trialAll = ActiveProcess_clickTrainWM(epocs, choiceWin, soundDuration);
trialsNoInterrupt = trialAll([trialAll.interrupt] == false);
ISI = fix(mean(cellfun(@(x, y) (x(end) - x(1)) / y, {trialsNoInterrupt.soundOnsetSeq}, {trialsNoInterrupt.stdNum})));

%% Plot behavior result
trials1 = trialsNoInterrupt(1:floor(length(trialsNoInterrupt)/2));
[Fig, mAxe] = plotClickTrainWMBehaviorOnly(trials1, "k", {'control', 'dev'},pairStr);
trials2 = trialsNoInterrupt(floor(length(trialsNoInterrupt))/2 + 1:end);
[Fig, mAxe] = plotClickTrainWMBehaviorOnly(trials2, "k", {'control', 'dev'},pairStr);

%% ECOG
trials = [{trials1_3([trials1_3.correct] == true & [trials1_3.oddballType] == "DEV")}; ...
          {trials4_6([trials4_6.correct] == true & [trials4_6.oddballType] == "DEV")}; ...
          {trials7_9([trials7_9.correct] == true & [trials7_9.oddballType] == "DEV")}];
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
    plotLayout(Fig1(tIndex), posIndex);
    set(Fig1(tIndex), "NumberTitle", "off", "Name", legendStr(tIndex));
    
    %% Time-Freq
    Fig2(tIndex) = plotTimeFreqAnalysis(double(chMean), fs0, fs);
    plotLayout(Fig2(tIndex), posIndex);
    set(Fig2(tIndex), "NumberTitle", "off", "Name", legendStr(tIndex));
end

% Scale
scaleAxes(Fig1, "x", [-500, 1000]);
yRange = scaleAxes(Fig1, "y", [-50, 50]);
allAxes = findobj(Fig1, "Type", "axes");
for aIndex = 1:length(allAxes)
    plot(allAxes(aIndex), [0, 0], yRange, "k--", "LineWidth", 0.6);
end
drawnow;

scaleAxes(Fig2, "x", [-500, 1000] - window(1));
yRange = scaleAxes(Fig2);
cRange = scaleAxes(Fig2, "c");
allAxes = findobj(Fig2, "Type", "axes");
for aIndex = 1:length(allAxes)
    plot(allAxes(aIndex), [0, 0] - window(1), yRange, "w--", "LineWidth", 0.6);
end
drawnow;