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
choiceWin = [0, 800]; % ms
fs = 300; % Hz, for downsampling
scaleFactor = 1e6;

trialAll = ActiveProcess_7_10Freq(epocs, choiceWin);
devFreq = unique([trialAll.devFreq])';
devFreq(devFreq == 0) = [];

trialsNoInterrupt = trialAll([trialAll.interrupt] == false);
ISI = fix(mean(cellfun(@(x, y) (x(end) - x(1)) / y, {trialsNoInterrupt.soundOnsetSeq}, {trialsNoInterrupt.stdNum})));
stdNumAll = unique([trialsNoInterrupt.stdNum]);

fs0 = streams.(posStr(posIndex)).fs;

%% Behavior
plotBehaviorOnly(trialAll, "r", "7-10 Freq");

%% STD
window = [-2500, 6000]; % ms
resultSTD = cell(length(stdNumAll), 1);
trials = trialAll([trialAll.correct] == true);

for sIndex = 1:length(stdNumAll)
    trialsSTD = trials([trials.correct] == true & [trials.stdNum] >= stdNumAll(sIndex));

    if sIndex == 1
        windowSTD = [window(1), ISI * stdNumAll(sIndex)];
    else
        windowSTD = [ISI * (stdNumAll(sIndex) - 1), ISI * stdNumAll(sIndex)];
    end

    ECOG = cellfun(@(x) x * scaleFactor, selectEcog(streams.(posStr(posIndex)), trialsSTD, "trial onset", window), "UniformOutput", false);
    weightSTD = zeros(1, size(ECOG{1}, 2));
    weightSTD(floor((windowSTD(1) - window(1)) * fs0 / 1000 + 1):floor((windowSTD(2) - window(1)) * fs0 / 1000)) = 1 / length(ECOG);
    resultSTD{sIndex} = cell2mat(cellfun(@sum, changeCellRowNum(cellfun(@(x) x .* weightSTD, ECOG, "UniformOutput", false)), "UniformOutput", false));
end

chMean = resultSTD{1};

for index = 2:length(resultSTD)
    chMean = chMean + resultSTD{index};
end

chSE = zeros(size(chMean, 1), size(chMean, 2));

% Raw wave
Fig0(1) = plotRawWave(chMean, chSE, window);
yRange = scaleAxes(Fig0(1), "y");
allAxes = findobj(Fig0(1), "Type", "axes");
for aIndex = 1:length(allAxes)
    plot(allAxes(aIndex), [0, 0], yRange, "k--", "LineWidth", 0.6);
end
drawnow;

% Time-Freq
Fig0(2) = plotTimeFreqAnalysis(double(chMean), fs0, fs);
yRange = scaleAxes(Fig0(2));
scaleAxes(Fig0(2), "c", [0, 25]);
allAxes = findobj(Fig0(2), "Type", "axes");
for aIndex = 1:length(allAxes)
    plot(allAxes(aIndex), [0, 0] - window(1), yRange, "w--", "LineWidth", 0.6);
end
drawnow;

scaleAxes(Fig0(1), "x", [-500, window(2)]);
scaleAxes(Fig0(2), "x", [-500, window(2)] - window(1));
Fig0 = plotLayout(Fig0, posIndex);

%% DEV
window = [-2000, 2000]; % ms

for dIndex = 1:length(devFreq)
    dRatio = roundn(devFreq(dIndex) / devFreq(1), -2);
    trials = trialAll([trialAll.correct] == true & [trialAll.devFreq] == devFreq(dIndex));
    result = cellfun(@(x) x * scaleFactor, selectEcog(streams.(posStr(posIndex)), trials, "dev onset", window), 'UniformOutput', false);
    totalChNum = length(streams.(posStr(posIndex)).channels);
    temp = cell2mat(result);
    
    chMean = zeros(totalChNum, size(result{1}, 2));
    chSE = zeros(totalChNum, size(result{1}, 2));
    
    for index = 1:totalChNum
        chMean(index, :) = mean(temp(index:totalChNum:length(result) * totalChNum, :), 1);
        chSE(index, :) = std(temp(index:totalChNum:length(result) * totalChNum, :), [], 1);
    end

    % Raw wave
    Fig1(dIndex) = plotRawWave(chMean, chSE, window, ['dRatio = ', num2str(dRatio)]);
    set(Fig1(dIndex), "NumberTitle", "off", "Name", strcat("difference ratio ", num2str(dRatio)));
    drawnow;

    % Time-Freq
    Fig2(dIndex) = plotTimeFreqAnalysis(chMean, fs0, fs, ['dRatio = ', num2str(dRatio)]);
    set(Fig2(dIndex), "NumberTitle", "off", "Name", strcat("difference ratio ", num2str(dRatio)));
    drawnow;
end

% Scale
scaleAxes(Fig1, "x", [-1500, 1000]);
yRange = scaleAxes(Fig1, "y", [-80, 80]);
allAxes = findobj(Fig1, "Type", "axes");
for aIndex = 1:length(allAxes)
    plot(allAxes(aIndex), [0, 0], yRange, "k--", "LineWidth", 0.6);
end
Fig1 = plotLayout(Fig1, posIndex);
drawnow;

scaleAxes(Fig2, "x", [-1500, 1000] - window(1));
yRange = scaleAxes(Fig2);
cRange = scaleAxes(Fig2, "c");
allAxes = findobj(Fig2, "Type", "axes");
for aIndex = 1:length(allAxes)
    plot(allAxes(aIndex), [0, 0] - window(1), yRange, "w--", "LineWidth", 0.6);
end
Fig2 = plotLayout(Fig2, posIndex);
drawnow;