addpath(genpath("..\..\ECOGProcess"));
%% Data loading
clear; clc; close all;
BLOCKPATH = 'G:\ECoG\chouchou\cc20220530\Block-4';
posIndex = 1; % 1-AC, 2-PFC

soundDuration = 200; % ms

% pairStr = {'4-4.06RC','4-4.06RD','4-4.06IC','4-4.06ID','4-4.06InC','4-4.06InD','40-40.6RC','40-40.6RD','Tone-C','Tone-D'};
pairStr = {'4-4.06RC','4-4.06RD','4-4.06IC','4-4.06ID','Tone-C','Tone-D'};
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

%% Params settings
choiceWin = [0, 1000]; % ms
fs = 300; % Hz, for downsampling

%% Behavior processing
% trialAll = ActiveProcess_clickTrainWM(epocs, choiceWin, soundDuration); % if input soundDuration, means offset choiceWin, otherwise, choiveWin aligns to deviant onset
trialAll = ActiveProcess_clickTrainWM(epocs, choiceWin);
trialsNoInterrupt = trialAll([trialAll.interrupt] == false);
ISI = fix(mean(cellfun(@(x, y) (x(end) - x(1)) / y, {trialsNoInterrupt.soundOnsetSeq}, {trialsNoInterrupt.stdNum})));

%% Plot behavior result
trials = trialsNoInterrupt;
[Fig, mAxe] = plotClickTrainWMBehaviorOnly(trials, "k", {'control', 'dev'},pairStr);

diffPairs = [[trials.stdOrdr]' [trials.devOrdr]'];
diffPairsUnique = unique(diffPairs, 'rows');
stdType = unique(diffPairsUnique(:,1));

%% Prediction
window = [-2500, 6000]; % ms
for sIndex = 1 : length(stdType)
trialP = trialAll([trialAll.stdOrdr] == stdType(sIndex) & [trialAll.interrupt] == false);
[chMean2, chStd2] = joinSTDAll(trialP, ECOGDataset, window);
FigP(1) = plotRawWave(chMean, chStd, window);
drawnow;
FigP(2) = plotTimeFreqAnalysis(double(chMean), fs0, fs, window);
drawnow;
end
% window = [-2500, 6000]; % ms
% [chMean, chStd] = joinSTD(trialAll, ECOGDataset, window);
% FigP(1) = plotRawWave(chMean, chStd, window);
% drawnow;
% FigP(2) = plotTimeFreqAnalysis(double(chMean), fs0, fs, window);
% drawnow;

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