addpath(genpath(fileparts(mfilename('fullpath'))));
clear; clc; close all;
%% Parameter setting
params.posIndex = 1; % 1-AC, 2-PFC
params.choiceWin = [100, 800];
params.processFcn = @ActiveProcess_clickTrainWM;
fs = 500; % Hz, for downsampling

%% Processing
BLOCKPATH = 'G:\xiaoxiao\xx20220611\Block-2';
[trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH, params, 1);

if ~isempty(ECOGDataset)
    fs0 = ECOGDataset.fs;
end

%% Data saving params
temp = string(split(BLOCKPATH, '\'));
DateStr = temp(end - 1);
Paradigm = 'ClickTrainOddDiffSoundsActive';
AREANAME = {'AC', 'PFC'};
ROOTPATH = fullfile('E:\ECoG\ECoGBehaviorResult',Paradigm,DateStr);
soundDuration = 200; % ms

%% title & labels
% pairStr = {'4-4.06RC','4-4.06RD','4-4.06IC','4-4.06ID','4-4.06InC','4-4.06InD','40-40.6RC','40-40.6RD','Tone-C','Tone-D'};
pairStr = {'4-4.06RC','4-4.06RD','4-4.06IC','4-4.06ID','FuzaTone-C','FuzaTone-D'};
typeStr = {'4-4.06Regular','4-4.06Irregular','ComplexTone'};
posStr = ["LAuC", "LPFC"];

%% Behavior processing
% trialAll = ActiveProcess_clickTrainWM(epocs, choiceWin, soundDuration); % if input soundDuration, means offset choiceWin, otherwise, choiveWin aligns to deviant onset
% trialAll = ActiveProcess_clickTrainWM(epocs, choiceWin);
trialAll = trialAll(2:end);
trialsNoInterrupt = trialAll([trialAll.interrupt] == false);
ISI = fix(mean(cellfun(@(x, y) (x(end) - x(1)) / y, {trialsNoInterrupt.soundOnsetSeq}, {trialsNoInterrupt.stdNum})));
diffPairs = [[trialsNoInterrupt.stdOrdr]' [trialsNoInterrupt.devOrdr]'];
diffPairsUnique = unique(diffPairs, 'rows');
stdType = unique(diffPairsUnique(:,1));
devType = unique(diffPairsUnique(:,2));
%% Plot behavior result
trials = trialsNoInterrupt;
[Fig, mAxe] = plotClickTrainWMBehaviorOnly(trials, "k", {'control', 'dev'},pairStr);


%% Prediction
window = [-2500, 6000]; % ms
for sIndex = 1 : length(stdType)
    trials = trialAll([trialAll.stdOrdr] == stdType(sIndex) & [trialAll.interrupt] == false);
    [chMean, chStd] = joinSTD(trials, ECOGDataset, window);
    FigPWave(sIndex) = plotRawWave(chMean, chStd, window, ['stiTyme: ', num2str(typeStr{sIndex}), '(N=', num2str(length(trials)), ')']);
    drawnow;
    FigPTF(sIndex) = plotTFA(double(chMean), fs0, fs, window, ['stiTyme: ', num2str(typeStr{sIndex}), '(N=', num2str(length(trials)), ')']);
    drawnow;
end
scaleAxes(FigPWave, "y", [-60, 60]);
scaleAxes(FigPTF, "c", [], [0, 20]);

% Layout
plotLayout(FigPWave, posIndex);

% saveFigures
predictPath = fullfile(ROOTPATH,'predictionResponse');
if ~exist(predictPath,"dir")
    mkdir(predictPath)
end
for figN = 1 : length(FigPWave)
    saveas(FigPWave(figN),strcat(fullfile(predictPath,typeStr{figN}), '_',  AREANAME{posIndex}, '_Waveform.jpg'));
    saveas(FigPTF(figN),strcat(fullfile(predictPath,typeStr{figN}), '_',  AREANAME{posIndex}, '_TimeFrequency.jpg'));
end


%% deivant response
window = [-2000, 2000]; % ms

for dIndex = 1:length(devType)
    trials = trialAll([trialAll.devOrdr] == devType(dIndex) & [trialAll.interrupt] == false & [trialAll.correct] == true);
    [~, chMean, chStd] = selectEcog(ECOGDataset, trials, "dev onset", window);
    FigDev1(dIndex) = plotRawWave(chMean, chStd, window, ['stiTyme: ', num2str(pairStr{dIndex}), '(N=', num2str(length(trials)), ')']);
    drawnow;
    FigDev2(dIndex) = plotTFA(chMean, fs0, fs, window, ['stiTyme: ', num2str(pairStr{dIndex}), '(N=', num2str(length(trials)), ')']);
    drawnow;
end

% Scale
scaleAxes([FigDev1, FigDev2], "x", [-500, 1000]);
scaleAxes(FigDev1, "y", [-60, 60]);
scaleAxes(FigDev2, "c", [], [0, 20]);

% Layout
plotLayout(FigDev1, posIndex);

% saveFigures
devPath = fullfile(ROOTPATH,'deviantResponse');
if ~exist(devPath,"dir")
    mkdir(devPath)
end
for figN = 1 : length(FigDev1)
    saveas(FigDev1(figN),strcat(fullfile(devPath,pairStr{figN}), '_',  AREANAME{posIndex}, '_Waveform.jpg'));
    saveas(FigDev2(figN),strcat(fullfile(devPath,pairStr{figN}), '_',  AREANAME{posIndex}, '_TimeFrequency.jpg'));
end

%% Decision making
window = [-2000, 2000];
% resultC = [];
% resultW = [];

for dIndex = 1 : length(devType)
    resultC = [];
    resultW = [];
    trials = trialAll([trialAll.devOrdr] == devType(dIndex));
    [result, ~, ~] = selectEcog(ECOGDataset, trials, "dev onset", window);
    result = changeCellRowNum(cellfun(@zscore, changeCellRowNum(result), "UniformOutput", false));
    resultC = [resultC; result([trials.correct] == true)];
    resultW = [resultW; result([trials.correct] == false & [trials.interrupt] == false)];
    if length(resultW)<0.1*length(trials) || length(resultC)<0.1*length(trials)
        FigDM1(dIndex) = figure('Visible','off');
        FigDM2(dIndex) = figure('Visible','off');
        continue
    else
        chMeanStd = cell2mat(cellfun(@mean, changeCellRowNum(resultC), "UniformOutput", false));
        chMeanDev = cell2mat(cellfun(@mean, changeCellRowNum(resultW), "UniformOutput", false));
        FigDM1(dIndex) = plotRawWave(chMeanDev - chMeanStd, [], window, ['C', num2str(length(resultC)), 'W', num2str(length(resultW))]);
        drawnow;
        FigDM2(dIndex) = plotTFACompare(chMeanDev, chMeanStd, fs0, fs, window, ['C', num2str(length(resultC)), 'W', num2str(length(resultW))]);
        drawnow;
    end
end

% Scale
scaleAxes([FigDM1, FigDM2], "x", [-1000, 1000]);
scaleAxes(FigDM1, "y", [], [-60 60]);
cRange = scaleAxes(FigDM2, "c", []);

% Layout
plotLayout(FigDM1, posIndex);

% saveFigures
DMPath = fullfile(ROOTPATH,'decisionMaking');
if ~exist(DMPath,"dir")
    mkdir(DMPath)
end
for figN = 1 : length(FigDM1)
    saveas(FigDM1(figN),strcat(fullfile(DMPath,pairStr{figN}), '_' , AREANAME{posIndex}, '_Waveform.jpg'));
    saveas(FigDM2(figN),strcat(fullfile(DMPath,pairStr{figN}), '_' , AREANAME{posIndex}, '_TimeFrequency.jpg'));
end


%% MMN
window = [-2000, 2000];
dIndex = 2;
trialsC = trialAll([trialAll.correct] == true & [trialAll.devOrdr] == devType(dIndex));
trialsW = trialAll([trialAll.correct] == false & [trialAll.interrupt] == false & [trialAll.devOrdr] == devType(dIndex));
[resultDEVC, chMeanDEVC, ~] = selectEcog(ECOGDataset, trialsC, "dev onset", window);
[resultSTDC, chMeanSTDC, ~] = selectEcog(ECOGDataset, trialsC, "last std", window);
[resultDEVW, chMeanDEVW, ~] = selectEcog(ECOGDataset, trialsW, "dev onset", window);
[resultSTDW, chMeanSTDW, ~] = selectEcog(ECOGDataset, trialsW, "last std", window);
chMeanC = cell2mat(cellfun(@mean, changeCellRowNum(resultDEVC - resultSTDC), "UniformOutput", false));
chMeanW = cell2mat(cellfun(@mean, changeCellRowNum(resultDEVW - resultSTDW), "UniformOutput", false));
FigMMN1(1) = plotRawWave(chMeanC, [], window, "C:DEV-last STD");
FigMMN1(2) = plotRawWave(chMeanW, [], window, "W:DEV-last STD");
FigMMN2(1) = plotTFACompare(chMeanDEVC, chMeanSTDC, fs0, fs, window, "C:DEV-last STD");
FigMMN2(2) = plotTFACompare(chMeanDEVW, chMeanSTDW, fs0, fs, window, "W:DEV-last STD");
scaleAxes([FigMMN1, FigMMN2], "x", [0, 500]);
scaleAxes(FigMMN1, "y", [], [-60, 60], "max");
scaleAxes(FigMMN2, "c", [], [-10, 10]);
% Layout
plotLayout(FigMMN1, posIndex);

% saveFigures
MMNPath = fullfile(ROOTPATH,'MMN');
if ~exist(MMNPath,"dir")
    mkdir(MMNPath)
end
for figN = 1 : length(FigMMN1)
    saveas(FigMMN1(figN),strcat(fullfile(MMNPath,pairStr{figN}), '_' , AREANAME{posIndex}, '_Waveform.jpg'));
    saveas(FigMMN2(figN),strcat(fullfile(MMNPath,pairStr{figN}), '_' , AREANAME{posIndex}, '_TimeFrequency.jpg'));
end


%% dev V.S. control
window = [-2000, 2000];
dIndex = 2;
trialsRegC = trialAll([trialAll.stdOrdr] == stdType(1) & [trialAll.interrupt] == false & [trialAll.oddballType] == "STD");
trialsRegD = trialAll([trialAll.stdOrdr] == stdType(1) & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV");
trialsIrregC = trialAll([trialAll.stdOrdr] == stdType(2) & [trialAll.interrupt] == false & [trialAll.oddballType] == "STD");
trialsIrregD = trialAll([trialAll.stdOrdr] == stdType(2) & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV");
trialsToneC = trialAll([trialAll.stdOrdr] == stdType(3) & [trialAll.interrupt] == false & [trialAll.oddballType] == "STD");
trialsToneD = trialAll([trialAll.stdOrdr] == stdType(3) & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV");

[resultRegC, chMeanRegC, ~] = selectEcog(ECOGDataset, trialsRegC, "dev onset", window);
[resultRegD, chMeanRegD, ~] = selectEcog(ECOGDataset, trialsRegD, "dev onset", window);
[resultIrregC, chMeanIrregC, ~] = selectEcog(ECOGDataset, trialsIrregC, "dev onset", window);
[resultIrregD, chMeanIrregD, ~] = selectEcog(ECOGDataset, trialsIrregD, "dev onset", window);
[resultToneC, chMeanToneC, ~] = selectEcog(ECOGDataset, trialsToneC, "dev onset", window);
[resultToneD, chMeanToneD, ~] = selectEcog(ECOGDataset, trialsToneD, "dev onset", window);
FigDevVSControl1(1) = plotRawWave(chMeanRegD - chMeanRegC, [], window, "Reg:DEV-Control");
FigDevVSControl1(2) = plotRawWave(chMeanIrregD - chMeanIrregC, [], window, "Irreg:DEV-Control");
FigDevVSControl1(3) = plotRawWave(chMeanToneD - chMeanToneC, [], window, "FuzaTone:DEV-Control");
FigDevVSControl2(1) = plotTFACompare(chMeanRegD, chMeanRegC, fs0, fs, window, "Reg:DEV-Control");
FigDevVSControl2(2) = plotTFACompare(chMeanIrregD, chMeanIrregC, fs0, fs, window, "Irreg:DEV-Control");
FigDevVSControl2(3) = plotTFACompare(chMeanToneD, chMeanToneC, fs0, fs, window, "FuzaTone:DEV-Control");

allAxes = findobj([FigDevVSControl1, FigDevVSControl2], "Type", "axes");
yRange = scaleAxes([FigDevVSControl1, FigDevVSControl2]);
for aIndex = 1:length(allAxes)
    plot(allAxes(aIndex), [500, 500], yRange, "k--", "LineWidth", 0.6);
end
scaleAxes([FigDevVSControl1, FigDevVSControl2], "x", [-500, 1000]);
scaleAxes(FigDevVSControl1, "y", [], [-60, 60], "max");
scaleAxes(FigDevVSControl2, "c", [], [-10, 10]);
% Layout
plotLayout(FigDevVSControl1, posIndex);

% saveFigures
devControlPath = fullfile(ROOTPATH,'Dev-Control');
if ~exist(devControlPath,"dir")
    mkdir(devControlPath)
end
for figN = 1 : length(FigDevVSControl1)
    saveas(FigDevVSControl1(figN),strcat(fullfile(devControlPath,typeStr{figN}), '_' , AREANAME{posIndex}, '_Waveform.jpg'));
    saveas(FigDevVSControl2(figN),strcat(fullfile(devControlPath,typeStr{figN}), '_' , AREANAME{posIndex}, '_TimeFrequency.jpg'));
end

%%
close all;