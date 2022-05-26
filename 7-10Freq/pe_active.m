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
devFreqAll = [trialAll.devFreq];
stdFreqAll = cellfun(@(x) x(1), {trialAll.freqSeq});
dRatioAll = devFreqAll ./ stdFreqAll;

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
allAxes = findobj(Fig0(2), "Type", "axes");
for aIndex = 1:length(allAxes)
    plot(allAxes(aIndex), [0, 0] - window(1), yRange, "w--", "LineWidth", 0.6);
end
drawnow;

scaleAxes(Fig0(2), "x", window - window(1));
Fig0 = plotLayout(Fig0, posIndex);

%% DEV
window = [-2000, 2000]; % ms
dRatio = unique(dRatioAll);
dRatio(dRatio == 0) = [];

for dIndex = 1:length(dRatio)
    trials = trialAll([trialAll.correct] == true & dRatioAll == dRatio(dIndex));
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
    Fig1(dIndex) = plotRawWave(chMean, chSE, window, ['dRatio = ', num2str(dRatio(dIndex))]);
    set(Fig1(dIndex), "NumberTitle", "off", "Name", strcat("DEV onset - difference ratio ", num2str(dRatio(dIndex))));
    drawnow;

    % Time-Freq
    Fig2(dIndex) = plotTimeFreqAnalysis(chMean, fs0, fs, ['dRatio = ', num2str(dRatio(dIndex))]);
    set(Fig2(dIndex), "NumberTitle", "off", "Name", strcat("DEV onset - difference ratio ", num2str(dRatio(dIndex))));
    drawnow;
end

% Scale
scaleAxes(Fig1, "x", [-300, 1000]);
yRange = scaleAxes(Fig1, "y", [-80, 80]);
allAxes = findobj(Fig1, "Type", "axes");
for aIndex = 1:length(allAxes)
    plot(allAxes(aIndex), [0, 0], yRange, "k--", "LineWidth", 0.6);
end
Fig1 = plotLayout(Fig1, posIndex);
drawnow;

scaleAxes(Fig2, "x", [-300, 1000] - window(1));
yRange = scaleAxes(Fig2);
cRange = scaleAxes([Fig0(2), Fig2], "c");
allAxes = findobj(Fig2, "Type", "axes");
for aIndex = 1:length(allAxes)
    plot(allAxes(aIndex), [0, 0] - window(1), yRange, "w--", "LineWidth", 0.6);
end
Fig2 = plotLayout(Fig2, posIndex);
drawnow;

%% Save
dRatio = roundn(dRatio, -2);
AREANAME = ["AC", "PFC"];
temp = string(split(BLOCKPATH, '\'));
DateStr = temp(end - 1);
DEVROOTPATH = strcat("D:\Education\Lab\monkey\ECOG\Figures\7-10Freq\", DateStr, "\DEV\");
STDROOTPATH = strcat("D:\Education\Lab\monkey\ECOG\Figures\7-10Freq\", DateStr, "\STD\");

try
    mkdir(DEVROOTPATH);
    mkdir(STDROOTPATH);
end

for dIndex = 1:length(Fig1)
    print(Fig1(dIndex), strcat(DEVROOTPATH, AREANAME(posIndex), "_DEV_Raw_dRatio", num2str(dIndex)), "-djpeg", "-r200");
    print(Fig2(dIndex), strcat(DEVROOTPATH, AREANAME(posIndex), "_DEV_TFA_dRatio", num2str(dIndex)), "-djpeg", "-r200");
end

print(Fig0(1), strcat(STDROOTPATH, AREANAME(posIndex), "_STD_Raw"), "-djpeg", "-r200");
print(Fig0(2), strcat(STDROOTPATH, AREANAME(posIndex), "_STD_TFA"), "-djpeg", "-r200");