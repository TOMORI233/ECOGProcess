clear; clc; close all;

%% Parameter settings
DATAPATH = 'D:\Lab\Projects\ECOG\MAT Data\XX\Corr\xx20230413\xx20230413_AC.mat';
% DATAPATH = 'D:\Lab\Projects\ECOG\MAT Data\XX\Corr\xx20230413\xx20230413_PFC.mat';

params.posIndex = 1;
params.processFcn = @CorrProcess;

colors = {[1 0 0], [0 0 1]};

%% Processing
[trialAll, ECOGDataset] = ECOGPreprocess(DATAPATH, params);
fs = ECOGDataset.fs;
channels = ECOGDataset.channels;

trialAll = trialAll(1:60);

%% Plot
window = [0, 10000];
orderAll = sort(unique([trialAll.order]))';
trialsECOG = selectEcog(ECOGDataset, trialAll, "trial onset", window);
chData = [];

for fIndex = 1:length(orderAll)
    temp = trialsECOG([trialAll.order] == orderAll(fIndex));
    chMean = cell2mat(cellfun(@mean, changeCellRowNum(temp), "UniformOutput", false));
    chData(fIndex).chMean = chMean;
    chData(fIndex).color = colors{fIndex};
end

% FigWave = plotRawWaveMulti(chData, window, "CT Screening");
% scaleAxes("y", "cutoffRange", [-60, 60], "symOpts", "max", "uiOpt", "show");

%% 
windowC = [1000, 8000];
tIdx = fix((windowC(1) - window(1)) * fs / 1000) + 1:fix((windowC(2) - window(1)) * fs / 1000);
chMeanF = chData(1).chMean(:, tIdx);
chMeanB = chData(2).chMean(:, tIdx);
nLagHalf = 25; % 50 ms
lags = -nLagHalf:nLagHalf;

tic
resFB = rowFcn(@(x, y) calCorrLag(x, y, nLagHalf), chMeanF, chMeanB, "UniformOutput", false);
toc

tic
resFrB = rowFcn(@(x, y) calCorrLag(x, y, nLagHalf), chMeanF, flip(chMeanB, 2), "UniformOutput", false);
toc

meanFB = cellfun(@(x) mean(x, 1), resFB, "UniformOutput", false);
seFB = cellfun(@(x) SE(x, 1), resFB, "UniformOutput", false);
meanFrB = cellfun(@(x) mean(x, 1), resFrB, "UniformOutput", false);
seFrB = cellfun(@(x) SE(x, 1), resFrB, "UniformOutput", false);

figure;
for cIndex = 1:64
    mSubplot(8, 8, cIndex);
    errorbar(lags, meanFrB{cIndex}, seFrB{cIndex}, "Color", colors{1});
    hold on;
    errorbar(lags, meanFB{cIndex}, seFB{cIndex}, "Color", colors{2});
end

%%
combFF = [];
combFB = [];
idxF = find([trialAll.order] == 1);
idxB = find([trialAll.order] == 2);
for index1 = 1:length(idxF)
    for index2 = 1:length(idxF)
        if index2 > index1
            combFF = [combFF; idxF(index1), idxF(index2)];
        end
    end
end
for index1 = 1:length(idxF)
    for index2 = 1:length(idxB)
        if index2 > index1
            combFB = [combFB; idxF(index1), idxB(index2)];
        end
    end
end

tic
resFF_All = cell(size(combFF, 1), 1);
parfor index = 1:size(combFF, 1)
    resFF_All{index} = rowFcn(@(x, y) calCorrLag(x, y, nLagHalf), trialsECOG{combFF(index, 1)}, trialsECOG{combFF(index, 2)}, "UniformOutput", false);
end
toc
resFF_All(cellfun(@isempty, resFF_All)) = [];
mSave('C_FF.mat', 'resFF_All');
meanFF = changeCellRowNum(cellfun(@(x) cell2mat(cellfun(@(y) mean(y, 1), x, "UniformOutput", false)), resFF_All, "UniformOutput", false));
meanFF = cellfun(@(x) mean(x, 1), meanFF, "UniformOutput", false);
clear resFF_All

tic
resFrB_All = cell(size(combFB, 1), 1);
parfor index = 1:size(combFB, 1)
    resFrB_All{index} = rowFcn(@(x, y) calCorrLag(x, y, nLagHalf), trialsECOG{combFB(index, 1)}, flip(trialsECOG{combFB(index, 2)}, 2), "UniformOutput", false);
end
toc
resFrB_All(cellfun(@isempty, resFrB_All)) = [];
mSave('C_FrB.mat', 'resFrB_All');
meanFrB = changeCellRowNum(cellfun(@(x) cell2mat(cellfun(@(y) mean(y, 1), x, "UniformOutput", false)), resFrB_All, "UniformOutput", false));
meanFrB = cellfun(@(x) mean(x, 1), meanFrB, "UniformOutput", false);
clear resFrB_All

figure;
for cIndex = 1:64
    mSubplot(8, 8, cIndex);
    plot(lags, meanFF{cIndex}, "Color", colors{1});
    hold on;
    plot(lags, meanFrB{cIndex}, "Color", colors{2});
end
scaleAxes;