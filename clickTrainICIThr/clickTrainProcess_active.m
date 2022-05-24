%% Data loading
clear; clc; close all;
% addpath(genpath('E:\OneDrive\OneDrive - zju.edu.cn\实验室\Matlab程序\MATLABUtils'));
BLOCKPATH = 'G:\ECoG\chouchou\cc20220523\Block-3';
posIndex = 1; % 1-AC, 2-PFC
% ICIStr = {'4','4.01','4.03','4.04','4.06'};
ICIStr = {'4','4.03','4.06','4.09','4.12'};
posStr = ["LAuC", "LPFC"];
temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs'});
epocs = temp.epocs;
% temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'streams'});
% streams = temp.streams;

%% Params settings
clearvars -except posIndex posStr epocs streams ICIStr

window = [-2500, 6000]; % ms

choiceWin = [0, 600]; % ms
fs = 300; % Hz, for downsampling
scaleFactor = 1e6;

trialAll = ActiveProcess_clickTrain(epocs, choiceWin);

trialsNoInterrupt = trialAll([trialAll.interrupt] == false);
ISI = fix(mean(cellfun(@(x, y) (x(end) - x(1)) / y, {trialsNoInterrupt.soundOnsetSeq}, {trialsNoInterrupt.stdNum})));
stdNumAll = unique([trialsNoInterrupt.stdNum]);

trialReg = trialAll([trialAll.stdOrdr] == 1);
trialIrreg = trialAll([trialAll.stdOrdr] == 6);





%% Behavior
[Fig, mAxe] = plotClickTrainBehaviorOnly(trialReg, "r", "Regular", ICIStr);
[Fig, mAxe] = plotClickTrainBehaviorOnly(trialIrreg, "b", "Irregular", ICIStr, Fig, mAxe);

%% reconstruct data
fs0 = streams.(posStr(posIndex)).fs;
trialReg = trialReg([trialReg.correct] == true);
trialIrreg = trialIrreg([trialIrreg.correct] == true);
trials = trialReg;
% trials = trialIRReg;
trialsSTD = cell(length(stdNumAll), 1);
resultSTD = cell(length(stdNumAll), 1);

for sIndex = 1:length(stdNumAll)+1
   
    if sIndex == length(stdNumAll)+1
        windowSTD = [ISI * stdNumAll(sIndex - 1) - 1 , window(2)];
        ECOG = selectEcog(streams.(posStr(posIndex)), trials, "trial onset", window) * scaleFactor;
    else
         trialsSTD{sIndex} = trials([trials.correct] == true & [trials.stdNum] >= stdNumAll(sIndex));
        if sIndex == 1
            windowSTD = [window(1), ISI * stdNumAll(sIndex)];
        else
            windowSTD = [ISI * (stdNumAll(sIndex) - 1), ISI * stdNumAll(sIndex)];
        end
        ECOG = selectEcog(streams.(posStr(posIndex)), trialsSTD{sIndex}, "trial onset", window) * scaleFactor;
    end
    weightSTD{sIndex} = zeros(1, size(ECOG{1}, 2));
    weightSTD{sIndex}(floor((windowSTD(1) - window(1)) * fs0 / 1000 + 1):floor((windowSTD(2) - window(1)) * fs0 / 1000)) = 1 / length(ECOG);
    resultSTD{sIndex} = cell2mat(cellfun(@sum, changeCellRowNum(ECOG .* weightSTD{sIndex}), "UniformOutput", false));

end

chMean = resultSTD{1};

for index = 2:length(resultSTD)
    chMean = chMean + resultSTD{index};
end

chSE = zeros(size(chMean, 1), size(chMean, 2));


%% Raw wave
Fig1 = plotRawWave(chMean, chSE, window);
yRange = scaleAxes(Fig1, "y", [-100, 100]);
allAxes = findobj(Fig1, "Type", "axes");
% title(allAxes(end), ['CH 1 | dRatio=', num2str(dRatio)])
for aIndex = 1:length(allAxes)
    plot(allAxes(aIndex), [0, 0], yRange, "k--", "LineWidth", 0.6);
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
    plot(allAxes(aIndex), [0, 0] - window(1), yRange, "k--", "LineWidth", 0.6);
end

drawnow;
% saveas(Fig2, strcat("figs/time-freq/", posStr(posIndex), "_dRatio", num2str(dRatio), "_TFA.jpg"));
