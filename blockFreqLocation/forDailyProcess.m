clear; close all; clc;

%% Load
params.posIndex = 1; % AC
params.choiceWin = [100, 600]; % ms
params.processFcn = @ActiveProcess_freqLoc;
[trialAll, ECOGDataset] = ECOGPreprocess('F:\Monkey ECoG\xx\xx20230228\Block-1', params, 'patch', 'bankIssue');

%% Filter
fhp = 0.1;
flp = 300;
ECOGDataset = ECOGFilter(ECOGDataset, fhp, flp);

%% Downsample
fd = 500; % Hz
ECOGDataset = ECOGResample(ECOGDataset, fd);
fs = fd;

%% Exclude trials
windowICA = [-2000, 1000];
trialAll = trialAll(~[trialAll.interrupt]);
trialAll([trialAll.devFreq] ~= mode([trialAll.devFreq])) = [];
trialsECOG = selectEcog(ECOGDataset, trialAll, "dev onset", windowICA);
[tIdx, chIdx] = excludeTrials(trialsECOG, 0.2, 0.2, "userDefineOpt", "on");
trialAll(tIdx) = [];
trialsECOG(tIdx) = [];

%% ICA
channels = ECOGDataset.channels;
channels(chIdx) = [];
[comp, ICs] = ICA_Population(trialsECOG, fs, windowICA, channels);
trialsECOG = cellfun(@(x) x(channels, :), trialsECOG, "UniformOutput", false);
trialsECOG = reconstructData(trialsECOG, comp, ICs);
trialsECOG = cellfun(@(x) insertRows(x, chIdx), trialsECOG, "UniformOutput", false);
trialsECOG = interpolateBadChs(trialsECOG, chIdx);

%% Behavior result
plotBehaviorOnly(trialAll, "r", "cueType", "loc", "legendStr", "location", "xlabelStr", "Deviant location");

%% PE
trials = trialAll([trialAll.correct]);
trialsECOG_PE = trialsECOG([trialAll.correct]);
devTypes = unique([trials.devType])';
colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

for index = 1:length(devTypes)
    temp = trialsECOG_PE([trials.devType] == devTypes(index));
    chData(index).chMean = cell2mat(cellfun(@mean, changeCellRowNum(temp), "UniformOutput", false));
    chData(index).color = colors{index};
    chData(index).legend = num2str(devTypes(index));
end

plotRawWaveMulti(chData, windowICA);
scaleAxes("x", [0, 800]);
scaleAxes("y", [-40, 40]);

plotRawWaveMulti(chData, windowICA, [], [1, 1], 38);
scaleAxes("x", [0, 800]);
scaleAxes("y", [-40, 40]);

%% Prediction
trialsECOG = selectEcog(ECOGDataset, trialAll, "trial onset", [-3000, 7000]);
trialsECOG = cellfun(@(x) x(channels, :), trialsECOG, "UniformOutput", false);
trialsECOG = reconstructData(trialsECOG, comp, ICs);
trialsECOG = cellfun(@(x) insertRows(x, chIdx), trialsECOG, "UniformOutput", false);
trialsECOG = interpolateBadChs(trialsECOG, chIdx);
[~, chMean, ~, windowP] = joinSTD(trialAll, trialsECOG, fs);
FigWave = plotRawWave(chMean, [], windowP);
FigTFR = plotTFA(chMean, fd, fd, windowP);
scaleAxes([FigWave, FigTFR], "x", [0, 5000]);
scaleAxes(FigWave, "y", [-40, 40]);
scaleAxes(FigTFR, "c", [0, 10]);

%% Decision making
windowDM = [-500, 1000];
trials = trialAll([trialAll.devType] > 1);
trialsECOG = selectEcog(ECOGDataset, trials, "dev onset", windowDM);
resultC = [];
resultW = [];
for index = 2:4
    trialsTemp = trials([trials.devType] == devTypes(index));
    temp = trialsECOG([trials.devType] == devTypes(index));
    result = changeCellRowNum(cellfun(@zscore, changeCellRowNum(temp), "UniformOutput", false));
    resultC = [resultC; result([trialsTemp.correct])];
    resultW = [resultW; result(~[trialsTemp.correct])];
end

chData = [];
chData(1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultC), "UniformOutput", false));
chData(1).color = 'r';
chData(2).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultW), "UniformOutput", false));
chData(2).color = 'k';
plotRawWaveMulti(chData, windowDM);
scaleAxes("x", [0, 800]);
scaleAxes("y", "symOpts", "max");

%% 
ISI = mode(cellfun(@(x) roundn((x(end) - x(1)) / (length(x) - 1), 0), {trialAll.soundOnsetSeq}'));
