addpath(genpath("..\..\ECOGProcess"));
<<<<<<< HEAD
%% Data loading
clear; clc; close all;
% BLOCKPATH = 'G:\xiaoxiao\xx20220608\Block-1';
BLOCKPATH = 'G:\ECoG\chouchou\cc20220610\Block-2';
posIndex = 1; % 1-AC, 2-PFC
temp = string(split(BLOCKPATH, '\'));
DateStr = temp(end - 1);
Paradigm = 'ClickTrainOddDiffSoundsActive';
AREANAME = {'AC', 'PFC'};
ROOTPATH = fullfile('E:\ECoG\ECoGBehaviorResult',Paradigm,DateStr);

soundDuration = 300; % ms

% pairStr = {'4-4.06RC','4-4.06RD','4-4.06IC','4-4.06ID','4-4.06InC','4-4.06InD','40-40.6RC','40-40.6RD','Tone-C','Tone-D'};
pairStr = {'1-3RC','1-3RD','4-6RC','4-6RD','7-9RC','7-9RD'};
typeStr = {'1-3','4-6','7-9'};

posStr = ["LAuC", "LPFC"];



temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs'});
epocs = temp.epocs;

% 
% temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'streams'}, 'STORE', posStr(posIndex));
% streams = temp.streams;
% 
% ECOGDataset = streams.(posStr(posIndex));
% fs0 = ECOGDataset.fs;

%% test
% epocs = data.epocs;
% ECOGDataset = data.streams.LAuC;
% fs0 = ECOGDataset.fs;
%% Params settings
choiceWin = [100, 800]; % ms
fs = 500; % Hz, for downsampling

%% Behavior processing
% trialAll = ActiveProcess_clickTrainWM(epocs, choiceWin, soundDuration); % if input soundDuration, means offset choiceWin, otherwise, choiveWin aligns to deviant onset
trialAll = ActiveProcess_clickTrain1_9(epocs, choiceWin);
trialAll = trialAll(2:end);
trialsNoInterrupt = trialAll([trialAll.interrupt] == false);
ISI = fix(mean(cellfun(@(x, y) (x(end) - x(1)) / y, {trialsNoInterrupt.soundOnsetSeq}, {trialsNoInterrupt.stdNum})));
=======
clear; clc; close all;
%% Parameter setting

params.posIndex = 1; % 1-AC, 2-PFC
posIndex = params.posIndex;
params.choiceWin = [100, 800];
params.processFcn = @ActiveProcess_clickTrain1_9;

fs = 500; % Hz, for downsampling

%% Processing
BLOCKPATH = 'E:\ECoG\chouchou\cc20220613\Block-1';
[trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH, params);

if ~isempty(ECOGDataset)
    fs0 = ECOGDataset.fs;
end
%% Data saving params


temp = string(split(BLOCKPATH, '\'));
DateStr = temp(end - 1);
Paradigm = 'ClickTrainOdd1-9RegActive';
AREANAME = {'AC', 'PFC'};
ROOTPATH = fullfile('E:\ECoG\ECoGBehaviorResult',Paradigm,DateStr);
soundDuration = 200; % ms

%% title & labels
diffStr = {'control(4msReg)','deviant(4.03msReg)','deviant(4.06msReg)','deviant(4.09msReg)','deviant(4.12msReg)'};
typeStr = {'1-3','4-6','7-9'};
posStr = ["LAuC", "LPFC"];


%% Behavior processing
trialAll = trialAll(2:end);
trialsNoInterrupt = trialAll([trialAll.interrupt] == false);
ISI = fix(mean(cellfun(@(x, y) (x(end) - x(1)) / y, {trialsNoInterrupt.soundOnsetSeq}, {trialsNoInterrupt.stdNum})));
diffPairs = [[trialsNoInterrupt.stdOrdr]' [trialsNoInterrupt.devOrdr]'];
diffPairsUnique = unique(diffPairs, 'rows');
stdType = unique(diffPairsUnique(:,1));
devType = unique(diffPairsUnique(:,2));
>>>>>>> 29653e8ceb2f088327817ec0ce18d2e0ac0f68b9

trials1_3 = trialAll([trialAll.stdNum] >= 1 & [trialAll.stdNum] <= 3);
trials4_6 = trialAll([trialAll.stdNum] >= 4 & [trialAll.stdNum] <= 6);
trials7_9 = trialAll([trialAll.stdNum] >= 7 & [trialAll.stdNum] <= 9);

%% Plot behavior result
<<<<<<< HEAD
[FigBehavior, mAxe] = plotBehaviorOnly(trials1_3, "k", "1 2 3");
[FigBehavior, mAxe] = plotBehaviorOnly(trials4_6, "b", "4 5 6", FigBehavior, mAxe);
[FigBehavior, mAxe] = plotBehaviorOnly(trials7_9, "r", "7 8 9", FigBehavior, mAxe);
set(mAxe(1),'xticklabel',{'control','deviant'});
diffPairs = [[trialAll.stdOrdr]' [trialAll.devOrdr]'];
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
=======

[FigBehavior, mAxe] = plotBehaviorOnly(trials1_3, "k", "1 2 3");
[FigBehavior, mAxe] = plotBehaviorOnly(trials4_6, "b", "4 5 6", FigBehavior, mAxe);
[FigBehavior, mAxe] = plotBehaviorOnly(trials7_9, "r", "7 8 9", FigBehavior, mAxe);
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

>>>>>>> 29653e8ceb2f088327817ec0ce18d2e0ac0f68b9
scaleAxes(FigPTF, "c", [], [0, 20]);

% Layout
plotLayout(FigPWave, posIndex);

% saveFigures
predictPath = fullfile(ROOTPATH,'predictionResponse');
if ~exist(predictPath,"dir")
    mkdir(predictPath)
end
for figN = 1 : length(FigPWave)
<<<<<<< HEAD
    saveas(FigPWave(figN),strcat(fullfile(predictPath,typeStr{figN}), '_',  AREANAME{posIndex}, '_Waveform.jpg'));
    saveas(FigPTF(figN),strcat(fullfile(predictPath,typeStr{figN}), '_',  AREANAME{posIndex}, '_TimeFrequency.jpg'));
=======
    saveas(FigPWave(figN),strcat(predictPath, '_',  AREANAME{posIndex}, '_Waveform.jpg'));
    saveas(FigPTF(figN),strcat(predictPath, '_',  AREANAME{posIndex}, '_TimeFrequency.jpg'));
>>>>>>> 29653e8ceb2f088327817ec0ce18d2e0ac0f68b9
end


%% deivant response
window = [-2000, 2000]; % ms

for dIndex = 1:length(devType)
<<<<<<< HEAD
    trials = trialAll([trialAll.devOrdr] == devType(dIndex) & [trialAll.interrupt] == false & [trialAll.correct] == true);
    [~, chMean, chStd] = selectEcog(ECOGDataset, trials, "dev onset", window);
    FigDev1(dIndex) = plotRawWave(chMean, chStd, window, ['stiTyme: ', num2str(pairStr{dIndex}), '(N=', num2str(length(trials)), ')']);
    drawnow;
    FigDev2(dIndex) = plotTFA(chMean, fs0, fs, window, ['stiTyme: ', num2str(pairStr{dIndex}), '(N=', num2str(length(trials)), ')']);
=======
    %%1-3
    trials = trialAll([trialAll.devOrdr] == devType(dIndex) & [trialAll.interrupt] == false & [trialAll.correct] == true  & [trialAll.stdNum] >= 1 & [trialAll.stdNum] <= 3);
    [~, chMean, chStd] = selectEcog(ECOGDataset, trials, "dev onset", window);
    FigDev_Wave1_3(dIndex) = plotRawWave(chMean, chStd, window, ['stiTyme: ', num2str(diffStr{dIndex}), '(N=', num2str(length(trials)), ') | 1-3']);
    drawnow;
    FigDev_TFA1_3(dIndex) = plotTFA(chMean, fs0, fs, window, ['stiTyme: ', num2str(diffStr{dIndex}), '(N=', num2str(length(trials)), ') | 1-3']);
    drawnow;
    %%4-6
    trials = trialAll([trialAll.devOrdr] == devType(dIndex) & [trialAll.interrupt] == false & [trialAll.correct] == true  & [trialAll.stdNum] >= 4 & [trialAll.stdNum] <= 6);
    [~, chMean, chStd] = selectEcog(ECOGDataset, trials, "dev onset", window);
    FigDev_Wave4_6(dIndex) = plotRawWave(chMean, chStd, window, ['stiTyme: ', num2str(diffStr{dIndex}), '(N=', num2str(length(trials)), ') | 4-6']);
    drawnow;
    FigDev_TFA4_6(dIndex) = plotTFA(chMean, fs0, fs, window, ['stiTyme: ', num2str(diffStr{dIndex}), '(N=', num2str(length(trials)), ') | 4-6']);
    drawnow;
    %%7-9
    trials = trialAll([trialAll.devOrdr] == devType(dIndex) & [trialAll.interrupt] == false & [trialAll.correct] == true  & [trialAll.stdNum] >= 7 & [trialAll.stdNum] <= 9);
    [~, chMean, chStd] = selectEcog(ECOGDataset, trials, "dev onset", window);
    FigDev_Wave7_9(dIndex) = plotRawWave(chMean, chStd, window, ['stiTyme: ', num2str(diffStr{dIndex}), '(N=', num2str(length(trials)), ') | 7-9']);
    drawnow;
    FigDev_TFA7_9(dIndex) = plotTFA(chMean, fs0, fs, window, ['stiTyme: ', num2str(diffStr{dIndex}), '(N=', num2str(length(trials)), ') | 7-9']);
>>>>>>> 29653e8ceb2f088327817ec0ce18d2e0ac0f68b9
    drawnow;
end

% Scale
<<<<<<< HEAD
scaleAxes([FigDev1, FigDev2], "x", [-500, 1000]);
scaleAxes(FigDev1, "y", [-80, 80]);
scaleAxes(FigDev2, "c", [], [0, 20]);

% Layout
plotLayout(FigDev1, posIndex);
=======
scaleAxes([FigDev_Wave1_3, FigDev_Wave4_6, FigDev_Wave7_9, FigDev_TFA1_3, FigDev_TFA4_6, FigDev_TFA7_9], "x", [-500, 1000]);
scaleAxes([FigDev_Wave1_3, FigDev_Wave4_6, FigDev_Wave7_9], "y", [-80, 80]);
scaleAxes([FigDev_TFA1_3, FigDev_TFA4_6, FigDev_TFA7_9], "c", [], [0, 20]);

% Layout
plotLayout([FigDev_Wave1_3, FigDev_Wave4_6, FigDev_Wave7_9], posIndex);
>>>>>>> 29653e8ceb2f088327817ec0ce18d2e0ac0f68b9

% saveFigures
devPath = fullfile(ROOTPATH,'deviantResponse');
if ~exist(devPath,"dir")
    mkdir(devPath)
end
<<<<<<< HEAD
for figN = 1 : length(FigDev1)
    saveas(FigDev1(figN),strcat(fullfile(devPath,pairStr{figN}), '_',  AREANAME{posIndex}, '_Waveform.jpg'));
    saveas(FigDev2(figN),strcat(fullfile(devPath,pairStr{figN}), '_',  AREANAME{posIndex}, '_TimeFrequency.jpg'));
=======
for figN = 1 : length(FigDev_Wave1_3)
    saveas(FigDev_Wave1_3(figN),strcat(fullfile(devPath, '1-3' ,diffStr{figN}), '_',  AREANAME{posIndex}, '_Waveform.jpg'));
    saveas(FigDev_TFA1_3(figN),strcat(fullfile(devPath, '1-3' ,diffStr{figN}), '_',  AREANAME{posIndex}, '_TimeFrequency.jpg'));
     saveas(FigDev_Wave4_6(figN),strcat(fullfile(devPath, '4-6' ,diffStr{figN}), '_',  AREANAME{posIndex}, '_Waveform.jpg'));
    saveas(FigDev_TFA4_6(figN),strcat(fullfile(devPath, '4-6' ,diffStr{figN}), '_',  AREANAME{posIndex}, '_TimeFrequency.jpg'));
     saveas(FigDev_Wave7_9(figN),strcat(fullfile(devPath, '7-9' ,diffStr{figN}), '_',  AREANAME{posIndex}, '_Waveform.jpg'));
    saveas(FigDev_TFA7_9(figN),strcat(fullfile(devPath, '7-9' ,diffStr{figN}), '_',  AREANAME{posIndex}, '_TimeFrequency.jpg'));
>>>>>>> 29653e8ceb2f088327817ec0ce18d2e0ac0f68b9
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
<<<<<<< HEAD
    saveas(FigDM1(figN),strcat(fullfile(DMPath,pairStr{figN}), '_' , AREANAME{posIndex}, '_Waveform.jpg'));
    saveas(FigDM2(figN),strcat(fullfile(DMPath,pairStr{figN}), '_' , AREANAME{posIndex}, '_TimeFrequency.jpg'));
end


%% MMN
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
=======
    saveas(FigDM1(figN),strcat(fullfile(DMPath,diffStr{figN}), '_' , AREANAME{posIndex}, '_Waveform.jpg'));
    saveas(FigDM2(figN),strcat(fullfile(DMPath,diffStr{figN}), '_' , AREANAME{posIndex}, '_TimeFrequency.jpg'));
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
    saveas(FigMMN1(figN),strcat(fullfile(MMNPath,diffStr{figN}), '_' , AREANAME{posIndex}, '_Waveform.jpg'));
    saveas(FigMMN2(figN),strcat(fullfile(MMNPath,diffStr{figN}), '_' , AREANAME{posIndex}, '_TimeFrequency.jpg'));
end


%% dev V.S. control
window = [-2000, 2000];
dIndex = 2;
trialsC1_3 = trialAll([trialAll.stdNum] >= 1 & [trialAll.stdNum] <= 3 & [trialAll.interrupt] == false & [trialAll.oddballType] == "STD");
trialsR1_3 = trialAll([trialAll.stdNum] >= 1 & [trialAll.stdNum] <= 3 & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV");
trialsC4_6 = trialAll([trialAll.stdNum] >= 4 & [trialAll.stdNum] <= 6 & [trialAll.interrupt] == false & [trialAll.oddballType] == "STD");
trialsD4_6 = trialAll([trialAll.stdNum] >= 4 & [trialAll.stdNum] <= 6 & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV");
trialsC7_9 = trialAll([trialAll.stdNum] >= 7 & [trialAll.stdNum] <= 9 & [trialAll.interrupt] == false & [trialAll.oddballType] == "STD");
trialsD7_9 = trialAll([trialAll.stdNum] >= 7 & [trialAll.stdNum] <= 9 & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV");

[~, chMeanC1_3, ~] = selectEcog(ECOGDataset, trialsC1_3, "dev onset", window);
[~, chMeanD1_3, ~] = selectEcog(ECOGDataset, trialsR1_3, "dev onset", window);
[~, chMeanC4_6, ~] = selectEcog(ECOGDataset, trialsC4_6, "dev onset", window);
[~, chMeanD4_6, ~] = selectEcog(ECOGDataset, trialsD4_6, "dev onset", window);
[~, chMeanC7_9, ~] = selectEcog(ECOGDataset, trialsC7_9, "dev onset", window);
[~, chMeanD7_9, ~] = selectEcog(ECOGDataset, trialsD7_9, "dev onset", window);
FigDevVSControl1(1) = plotRawWave(chMeanD1_3 - chMeanC1_3, [], window, "Reg:DEV-Control");
FigDevVSControl1(2) = plotRawWave(chMeanD4_6 - chMeanC4_6, [], window, "Irreg:DEV-Control");
FigDevVSControl1(3) = plotRawWave(chMeanD7_9 - chMeanC7_9, [], window, "FuzaTone:DEV-Control");
FigDevVSControl2(1) = plotTFACompare(chMeanD1_3, chMeanC1_3, fs0, fs, window, "Reg:DEV-Control");
FigDevVSControl2(2) = plotTFACompare(chMeanD4_6, chMeanC4_6, fs0, fs, window, "Irreg:DEV-Control");
FigDevVSControl2(3) = plotTFACompare(chMeanD7_9, chMeanC7_9, fs0, fs, window, "FuzaTone:DEV-Control");

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
>>>>>>> 29653e8ceb2f088327817ec0ce18d2e0ac0f68b9
end


%%
close all;