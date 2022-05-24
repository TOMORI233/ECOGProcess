%% Data loading
clear; clc; close all;
BLOCKPATH = 'E:\ECoG\TDT Data\chouchou\cc20220520\Block-1';
posIndex = 1; % 1-AC, 2-PFC

posStr = ["LAuC", "LPFC"];
temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs'});
epocs = temp.epocs;
temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'streams'}, 'STORE', posStr(posIndex));
streams = temp.streams;

%% Processing
window = [-2000, 2000]; % ms
choiceWin = [0, 800]; % ms
fs = 300; % Hz, for downsampling
scaleFactor = 1e6;

trialAll = ActiveProcess_7_10Freq(epocs, choiceWin);
devFreq = unique([trialAll.devFreq])';
devFreq(devFreq == 0) = [];

plotBehaviorOnly(trialAll, "r", "7-10 Freq");

%%
for dIndex = 1:length(devFreq)
    dRatio = roundn(devFreq(dIndex) / devFreq(1), -2);
    trials = trialAll([trialAll.correct] == true & [trialAll.devFreq] == devFreq(dIndex));
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
    Fig1(dIndex) = plotRawWave(chMean, chSE, window);
    set(Fig1(dIndex), "NumberTitle", "off", "Name", strcat("difference ratio ", num2str(dRatio)));

    % Time-Freq
    Fig2(dIndex) = plotTimeFreqAnalysis(chMean, fs0, fs);
    set(Fig2(dIndex), "NumberTitle", "off", "Name", strcat("difference ratio ", num2str(dRatio)));
end

% Scale
scaleAxes(Fig1, "x", [-500, 1000]);
yRange = scaleAxes(Fig1, "y", [-50, 50]);
allAxes = findobj(Fig1, "Type", "axes");
for aIndex = 1:length(allAxes)
    plot(allAxes(aIndex), [0, 0], yRange, "k--", "LineWidth", 0.6);
end
Fig1 = plotLayout(Fig1, posIndex);
drawnow;

scaleAxes(Fig2, "x", [-500, 1000] - window(1));
yRange = scaleAxes(Fig2);
cRange = scaleAxes(Fig2, "c");
allAxes = findobj(Fig2, "Type", "axes");
for aIndex = 1:length(allAxes)
    plot(allAxes(aIndex), [0, 0] - window(1), yRange, "w--", "LineWidth", 0.6);
end
Fig2 = plotLayout(Fig2, posIndex);
drawnow;