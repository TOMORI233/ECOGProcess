addpath(genpath("..\..\ECOGProcess"));
%% Data loading
clear; clc; close all;
BLOCKPATH = 'G:\ECoG\chouchou\cc20220530\Block-4';
posIndex = 1; % 1-AC, 2-PFC
temp = string(split(BLOCKPATH, '\'));
DateStr = temp(end - 1);
Paradigm = 'ClickTrainOddDiffSoundsActive';
AREANAME = {'AC', 'PFC'};
ROOTPATH = fullfile('E:\ECoG\ECoGBehaviorResult',Paradigm,DateStr);

soundDuration = 300; % ms

% pairStr = {'4-4.06RC','4-4.06RD','4-4.06IC','4-4.06ID','4-4.06InC','4-4.06InD','40-40.6RC','40-40.6RD','Tone-C','Tone-D'};
pairStr = {'4-4.06RC','4-4.06RD','4-4.06IC','4-4.06ID','Tone-C','Tone-D'};
typeStr = {'4-4.06Regular','4-4.06Irregular','Tone'};
posStr = ["LAuC", "LPFC"];



temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs'});
epocs = temp.epocs;

temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'streams'}, 'STORE', posStr(posIndex));
streams = temp.streams;

ECOGDataset = streams.(posStr(posIndex));
fs0 = ECOGDataset.fs;



%% Params settings
choiceWin = [-150, 800]; % ms
fs = 300; % Hz, for downsampling

%% Behavior processing
% trialAll = ActiveProcess_clickTrainWM(epocs, choiceWin, soundDuration); % if input soundDuration, means offset choiceWin, otherwise, choiveWin aligns to deviant onset
trialAll = ActiveProcess_clickTrainWM(epocs, choiceWin);
trialAll = trialAll(2:end-1);
trialsNoInterrupt = trialAll([trialAll.interrupt] == false);
ISI = fix(mean(cellfun(@(x, y) (x(end) - x(1)) / y, {trialsNoInterrupt.soundOnsetSeq}, {trialsNoInterrupt.stdNum})));

%% Plot behavior result
trials = trialsNoInterrupt;
[Fig, mAxe] = plotClickTrainWMBehaviorOnly(trials, "k", {'control', 'dev'},pairStr);

diffPairs = [[trials.stdOrdr]' [trials.devOrdr]'];
diffPairsUnique = unique(diffPairs, 'rows');
stdType = unique(diffPairsUnique(:,1));
devType = unique(diffPairsUnique(:,2));

%% Prediction
window = [-2500, 6000]; % ms
for sIndex = 1 : length(stdType)
trials = trialAll([trialAll.stdOrdr] == stdType(sIndex) & [trialAll.interrupt] == false);
[chMean, chStd] = joinSTD(trials, ECOGDataset, window);
FigPWave(sIndex) = plotRawWave(chMean, chStd, window);
drawnow;
FigPTF(sIndex) = plotTFA(double(chMean), fs0, fs, window);
drawnow;
end
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
scaleAxes(FigDev1, "y", [-80, 80]);
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
%     result = changeCellRowNum(cellfun(@zscore, changeCellRowNum(result), "UniformOutput", false));
    resultC = [resultC; result([trials.correct] == true)];
    resultW = [resultW; result([trials.correct] == false & [trials.interrupt] == false)];

    chMeanC = cell2mat(cellfun(@mean, changeCellRowNum(resultC), "UniformOutput", false));
    chMeanW = cell2mat(cellfun(@mean, changeCellRowNum(resultW), "UniformOutput", false));
    FigDM1(dIndex) = plotRawWave(chMeanC - chMeanW, [], window, ['C', num2str(length(resultC)), 'W', num2str(length(resultW))]);
    drawnow;
    FigDM2(dIndex) = plotTFACompare(chMeanC, chMeanW, fs0, fs, window, ['C', num2str(length(resultC)), 'W', num2str(length(resultW))]);
    drawnow;
end

% Scale
scaleAxes([FigDM1, FigDM2], "x", [-1000, 1000]);
scaleAxes(FigDM1, "y");
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
%%
close all;