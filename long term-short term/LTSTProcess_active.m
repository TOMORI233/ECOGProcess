addpath(genpath("..\..\ECOGProcess"));
%% Data loading
clear; clc; close all;
BLOCKPATH = 'E:\ECoG\Data\chouchou\cc20220521\Block-1';
posIndex = 1; % 1-AC, 2-PFC

posStr = ["LAuC", "LPFC"];
temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs'});
epocs = temp.epocs;
temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'streams'}, 'STORE', posStr(posIndex));
streams = temp.streams;

%% Params settings
clearvars -except posIndex posStr epocs streams
window = [-2500, 6000]; % ms

choiceWin = [0, 600]; % ms
fs = 300; % Hz, for downsampling
scaleFactor = 1e6;

trialAll = ActiveProcess_LTST(epocs, choiceWin);

trialsNoInterrupt = trialAll([trialAll.interrupt] == false);
ISI = fix(mean(cellfun(@(x, y) (x(end) - x(1)) / y, {trialsNoInterrupt.soundOnsetSeq}, {trialsNoInterrupt.stdNum})));
stdNumAll = unique([trialsNoInterrupt.stdNum]);

trialsConst = trialAll(logical(mod(ceil([trialAll.trialNum] / 20), 2)));
trialsRand = trialAll(~logical(mod(ceil([trialAll.trialNum] / 20), 2)));

fs0 = streams.(posStr(posIndex)).fs;

% trials = trialsConst([trialsConst.correct] == true);
trials = trialsRand([trialsRand.correct] == true);

resultSTD = cell(length(stdNumAll), 1);

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

%% Behavior
[Fig, mAxe] = plotBehaviorOnly(trialsConst, "b", "Constant");
[Fig, mAxe] = plotBehaviorOnly(trialsRand, "r", "Random", Fig, mAxe);

%% Raw wave
Fig1 = plotRawWave(chMean, chSE, window);
yRange = scaleAxes(Fig1, "y");
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
cRange = scaleAxes(Fig2, "c", [0, 25]);
allAxes = findobj(Fig2, "Type", "axes");
% title(allAxes(end), ['CH 1 | dRatio=', num2str(roundn(devFreq(dIndex) / devFreq(1), -2))])
for aIndex = 1:length(allAxes)
    plot(allAxes(aIndex), [0, 0] - window(1), yRange, "w--", "LineWidth", 0.6);
end

drawnow;
% saveas(Fig2, strcat("figs/time-freq/", posStr(posIndex), "_dRatio", num2str(dRatio), "_TFA.jpg"));
