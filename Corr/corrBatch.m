clear; clc;
% close all;
%% Parameter settings
% DATAPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\XX\Corr\xx20230413\xx20230413_AC.mat';
DATAPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\XX\Corr\xx20230413\xx20230413_PFC.mat';

params.posIndex = 1;
params.processFcn = @CorrProcess;

colors = {[1 0 0], [0 0 1]};

%% Processing
[trialAll, ECOGDataset] = ECOGPreprocess(DATAPATH, params);
fs = ECOGDataset.fs;
channels = ECOGDataset.channels;

%% Plot Raw wave
window = [0, 10000];
orderAll = sort(unique([trialAll.order]))';
trialsECOG = selectEcog(ECOGDataset, trialAll, "trial onset", window);
chData = [];

for oIndex = 1:length(orderAll)
    temp = trialsECOG([trialAll.order] == orderAll(oIndex));
    chMean = cell2mat(cellfun(@mean, changeCellRowNum(temp), "UniformOutput", false));
    chData(oIndex).chMean = chMean;
    chData(oIndex).color = colors{oIndex};
end

FigWave = plotRawWaveMulti(chData, window, "Correlation");
scaleAxes("y", "cutoffRange", [-50, 50], "symOpts", "max", "uiOpt", "show");

%% Correlation
windowC = [1000, 8000];
tIdx = fix((windowC(1) - window(1)) * fs / 1000) + 1:fix((windowC(2) - window(1)) * fs / 1000);
chMeanF = chData(1).chMean(:, tIdx); % forward
chMeanB = chData(2).chMean(:, tIdx); % backward
C_FB = rowFcn(@(x, y) corrAnalysis(x, y), chMeanF, chMeanB);
figure;
maximizeFig;
mSubplot(1, 1, 1, "shape", "square-min");
plotTopo(C_FB, [8, 8]);
title('Forward vs Backward');
colorbar;
scaleAxes("c", "symOpt", "max");

C_FrB = rowFcn(@(x, y) corrAnalysis(x, flip(y)), chMeanF, chMeanB);
figure;
maximizeFig;
mSubplot(1, 1, 1, "shape", "square-min");
plotTopo(C_FrB, [8, 8]);
title('Forward vs reverse Backward');
colorbar;
scaleAxes("c", "symOpt", "max");

figure;
maximizeFig;
mSubplot(1, 1, 1, "shape", "square-min");
plotTopo(C_FrB - C_FB, [8, 8]);
title('Forward - reverse Backward');
colorbar;
scaleAxes("c", "symOpt", "max");

%% 
tempF = trialsECOG([trialAll.order] == 1);
tempF = cellfun(@(x) x(:, tIdx), tempF, "UniformOutput", false);
resF = cell(length(tempF), length(tempF));
for index1 = 1:length(tempF)
    for index2 = 1:length(tempF)
        resF{index1, index2} = rowFcn(@(x, y) corrAnalysis(x, y), tempF{index1}, tempF{index2});
    end
end

tempB = trialsECOG([trialAll.order] == 2);
tempB = cellfun(@(x) x(:, tIdx), tempB, "UniformOutput", false);
resB = cell(length(tempB), length(tempB));
for index1 = 1:length(tempB)
    for index2 = 1:length(tempB)
        resB{index1, index2} = rowFcn(@(x, y) corrAnalysis(x, y), tempB{index1}, tempB{index2});
    end
end

%% 
figure;
maximizeFig;
screenSize = get(0, "ScreenSize");
adjIdx = screenSize(4) / screenSize(3);
for cIndex = 1:64
    mSubplot(8, 8, cIndex, "margins", ones(1, 4) * 0.01, "paddings", [(1 - adjIdx + 0.13) / 2, (1 - adjIdx + 0.13) / 2, 0.09, 0.04]);
    imagesc('XData', 1:length(tempF), 'YData', 1:length(tempF), 'CData', cell2mat(cellfun(@(x) x(cIndex), resF, "UniformOutput", false)));
    set(gca, "XLimitMethod", "tight");
    set(gca, "YLimitMethod", "tight");
    xticklabels('');
    yticklabels('');
end
scaleAxes("c", "symOpt", "max");
cb = colorbar('position', [0.9, 0.1, 0.015, 0.8]);
cb.Label.String = 'Forward';
cb.Label.FontSize = 15;
cb.Label.FontWeight = 'bold';
cb.Label.Rotation = -90;
cb.Label.VerticalAlignment = 'bottom';

figure;
maximizeFig;
screenSize = get(0, "ScreenSize");
adjIdx = screenSize(4) / screenSize(3);
for cIndex = 1:64
    mSubplot(8, 8, cIndex, "margins", ones(1, 4) * 0.01, "paddings", [(1 - adjIdx + 0.13) / 2, (1 - adjIdx + 0.13) / 2, 0.09, 0.04]);
    imagesc('XData', 1:length(tempB), 'YData', 1:length(tempB), 'CData', cell2mat(cellfun(@(x) x(cIndex), resB, "UniformOutput", false)));
    set(gca, "XLimitMethod", "tight");
    set(gca, "YLimitMethod", "tight");
    xticklabels('');
    yticklabels('');
end
scaleAxes("c", "symOpt", "max");
scaleAxes("c", "symOpt", "max");
cb = colorbar('position', [0.9, 0.1, 0.015, 0.8]);
cb.Label.String = 'Backward';
cb.Label.FontSize = 15;
cb.Label.FontWeight = 'bold';
cb.Label.Rotation = -90;
cb.Label.VerticalAlignment = 'bottom';

%%
t = 1102:1000/fs:7900;
lag = -25:25;
resFB = cell(length(t), length(lag));
resFrB = cell(length(t), length(lag));

parfor tIndex = 1:length(t)
    tIdx2 = fix((t(tIndex) - 50 - windowC(1)) * fs / 1000) + 1:fix((t(tIndex) + 50 - windowC(1)) * fs / 1000);
    for idx = 1:51
        resFB{tIndex, idx} = rowFcn(@(x, y) corrAnalysis(x(tIdx2), y(tIdx2 + lag(idx))), chMeanF, chMeanB);
        resFrB{tIndex, idx} = rowFcn(@(x, y) corrAnalysis(x(tIdx2), y(tIdx2 + lag(idx))), chMeanF, flip(chMeanB, 2));
    end
    
end

for cIndex = 1:64
    tempFB{cIndex} = cell2mat(cellfun(@(x) x(cIndex), resFB, 'UniformOutput', false));
    tempFrB{cIndex} = cell2mat(cellfun(@(x) x(cIndex), resFrB, 'UniformOutput', false));
end

meanFB = cellfun(@(x) mean(x, 1), tempFB', "uni", false);
seFB = cellfun(@(x) SE(x, 1), tempFB', "uni", false);
meanFrB = cellfun(@(x) mean(x, 1), tempFrB', "uni", false);
seFrB = cellfun(@(x) SE(x, 1), tempFrB', "uni", false);

figure;
for cIndex = 1:64
    mSubplot(8, 8, cIndex);
    errorbar(lag, meanFB{cIndex}, seFB{cIndex}, "Color", "k");
    hold on;
    errorbar(lag, meanFrB{cIndex}, seFrB{cIndex}, "Color", "r");
end
scaleAxes;