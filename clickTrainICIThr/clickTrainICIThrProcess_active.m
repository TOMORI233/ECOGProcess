addpath(genpath("..\..\ECOGProcess"));
clear; clc; close all;
%% Parameter setting
posStr = ["LAuC", "LPFC"];
params.posIndex = 1; % 1-AC, 2-PFC
posIndex = params.posIndex;
params.choiceWin = [100, 800];
params.processFcn = @ActiveProcess_clickTrain1_9;

fs = 500; % Hz, for downsampling

%% Processing

% joinBlocks
% BLOCKPATH1 = 'E:\ECoG\chouchou\cc20220614\Block-3';
% BLOCKPATH2 = 'E:\ECoG\chouchou\cc20220614\Block-4';
% opts.sfNames = posStr(posIndex);
% opts.efNames = ["num0", "push", "erro", "ordr"];
% [trialAll, ECOGDataset] = ECOGPreprocessJoinBlock({BLOCKPATH1, BLOCKPATH2}, params, opts, [1817 0]);

% normal 
BLOCKPATH = 'G:\ECoG\xiaoxiao\xx20220630\Block-2';
[trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH, params, 1);

if ~isempty(ECOGDataset)
    fs0 = ECOGDataset.(posStr(posIndex)).fs;
end
%% Data saving params


temp = string(split(BLOCKPATH, '\'));
DateStr = temp(end - 1);
Paradigm = 'ClickTrainOddICIThrActive';
AREANAME = {'AC', 'PFC'};
ROOTPATH = fullfile('E:\ECoG\ECoGBehaviorResult',Paradigm,DateStr);
soundDuration = 200; % ms

%% title & labels
diffStr = {'control(4msReg)','deviant(4.03msReg)','deviant(4.06msReg)','deviant(4.09msReg)','deviant(4.12msReg)'};
typeStr = '7-10';
posStr = ["LAuC", "LPFC"];


%% Behavior processing
trialAll = trialAll(2:end);
trialsNoInterrupt = trialAll([trialAll.interrupt] == false);
ISI = fix(mean(cellfun(@(x, y) (x(end) - x(1)) / y, {trialsNoInterrupt.soundOnsetSeq}, {trialsNoInterrupt.stdNum})));
diffPairs = [[trialsNoInterrupt.stdOrdr]' [trialsNoInterrupt.devOrdr]'];
diffPairsUnique = unique(diffPairs, 'rows');
stdType = unique(diffPairsUnique(:,1));
devType = unique(diffPairsUnique(:,2));


%% Plot behavior result
[FigBehavior, mAxe] = plotBehaviorOnly(trialAll, "k", "7-10");

set(mAxe(1),'xticklabel',diffStr);

% saveFigures
behavPath = fullfile(ROOTPATH,'behaviorResult');
if ~exist(behavPath,"dir")
    mkdir(behavPath)
end
saveas(FigBehavior,strcat(behavPath, '\behavResult.jpg'));

%% Prediction
window = [-2500, 6000]; %=
[chMean, chStd] = joinSTD(trialAll([trialAll.interrupt] == false), ECOGDataset, window);
FigPWave = plotRawWave(chMean, chStd, window);
drawnow;
FigPTF = plotTFA(double(chMean), fs0, fs, window);
drawnow;

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
    
    trials = trialAll([trialAll.devOrdr] == devType(dIndex) & [trialAll.interrupt] == false & [trialAll.correct] == true  & [trialAll.stdNum] >= 1 & [trialAll.stdNum] <= 3);
    [~, chMean, chStd] = selectEcog(ECOGDataset, trials, "dev onset", window);
    FigDev_Wave(dIndex) = plotRawWave(chMean, chStd, window, ['stiTyme: ', num2str(pairStr{dIndex}), '(N=', num2str(length(trials)), ') | 7-10']);
    drawnow;
    FigDev_TFA(dIndex) = plotTFA(chMean, fs0, fs, window, ['stiTyme: ', num2str(pairStr{dIndex}), '(N=', num2str(length(trials)), ') | 7-10']);
    drawnow;

end

% Scale
scaleAxes([FigDev_Wave,  FigDev_TFA], "x", [-500, 1000]);
scaleAxes(FigDev_Wave, "y", [-80, 80]);
scaleAxes(FigDev_TFA, "c", [], [0, 20]);

% Layout
plotLayout([FigDev_Wave, FigDev_Wave4_6, FigDev_Wave7_9], posIndex);

% saveFigures
devPath = fullfile(ROOTPATH,'deviantResponse');
if ~exist(devPath,"dir")
    mkdir(devPath)
end
for figN = 1 : length(FigDev_Wave)
    saveas(FigDev_Wave(figN),strcat(fullfile(devPath, diffStr{figN}), '_',  AREANAME{posIndex}, '_Waveform.jpg'));
    saveas(FigDev_TFA(figN),strcat(fullfile(devPath, diffStr{figN}), '_',  AREANAME{posIndex}, '_TimeFrequency.jpg'));
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
    if isempty(resultW) || isempty(resultC)
        FigDM1(dIndex) = figure('Visible','off');
        FigDM2(dIndex) = figure('Visible','off');
        continue
    else
    chMeanC = cell2mat(cellfun(@mean, changeCellRowNum(resultC), "UniformOutput", false));
    chMeanW = cell2mat(cellfun(@mean, changeCellRowNum(resultW), "UniformOutput", false));
    FigDM1(dIndex) = plotRawWave(chMeanC - chMeanW, [], window, ['C', num2str(length(resultC)), 'W', num2str(length(resultW))]);
    drawnow;
    FigDM2(dIndex) = plotTFACompare(chMeanC, chMeanW, fs0, fs, window, ['C', num2str(length(resultC)), 'W', num2str(length(resultW))]);
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
    saveas(FigDM1(figN),strcat(fullfile(devPath, diffStr{figN}), '_' , AREANAME{posIndex}, '_Waveform.jpg'));
    saveas(FigDM2(figN),strcat(fullfile(devPath, diffStr{figN}), '_' , AREANAME{posIndex}, '_TimeFrequency.jpg'));
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
scaleAxes([FigMMN1, FigMMN2], "x", [0, 200]);
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
    saveas(FigMMN1(figN),strcat(MMNPath, '_' , AREANAME{posIndex}, '_Waveform.jpg'));
    saveas(FigMMN2(figN),strcat(MMNPath, '_' , AREANAME{posIndex}, '_TimeFrequency.jpg'));
end


%% dev V.S. control
window = [-2000, 2000];
dIndex = 2;
trialsC = trialAll([trialAll.stdNum] >= 1 & [trialAll.stdNum] <= 3 & [trialAll.interrupt] == false & [trialAll.oddballType] == "STD");
trialsR = trialAll([trialAll.stdNum] >= 1 & [trialAll.stdNum] <= 3 & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV");

[~, chMeanC, ~] = selectEcog(ECOGDataset, trialsC, "dev onset", window);
[~, chMeanD, ~] = selectEcog(ECOGDataset, trialsR, "dev onset", window);
FigDevVSControl1 = plotRawWave(chMeanD - chMeanC, [], window, "Reg:DEV-Control");

FigDevVSControl2 = plotTFACompare(chMeanD, chMeanC, fs0, fs, window, "Reg:DEV-Control");


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
    saveas(FigDevVSControl1(figN),strcat(devControlPath, '_' , AREANAME{posIndex}, '_Waveform.jpg'));
    saveas(FigDevVSControl2(figN),strcat(devControlPath, '_' , AREANAME{posIndex}, '_TimeFrequency.jpg'));
end


%%
close all;