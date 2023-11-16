clear; clc; close all force;
%% Active
load('D:\Education\Lab\Projects\ECOG\ECOG process\7-10Freq\batch\Active\CC\Population\Prediction\AC_Prediction_Data.mat');

t = (0:size(trialsECOG{1}, 2) - 1)' / fs * 1000 + windowP(1);
nCh = size(trialsECOG{1}, 1);
ISI = fix(mean(cellfun(@(x, y) (x(end) - x(1)) / y, {trialAll.soundOnsetSeq}, {trialAll.stdNum})));
fRange = [1000 / ISI - 0.1, 1000 / ISI + 0.1]; % 2 ± 0.1 Hz
nStdAll = unique([trialAll.stdNum]);
nStd = nStdAll(end);
tIdx = fix((0-windowP(1))*fs/1000)+1:fix((ISI*nStd-windowP(1))*fs/1000);

[~, chMean] = joinSTD(trialAll, trialsECOG, fs);
chMeanA = chMean;
chData(1).chMean = chMeanA;
chData(1).color = "r";
chData(1).legend = "active";

temp = cellfun(@(x) x(:, tIdx), trialsECOG, "UniformOutput", false);
idx = randperm(length(temp));
temp1 = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(temp(idx(1:fix(length(temp)/2)))), "UniformOutput", false));
temp2 = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(temp(idx(fix(length(temp)/2+1:end)))), "UniformOutput", false));

res = rowFcn(@(x, y) corrAnalysis(x, y), temp1, temp2);
figure;
maximizeFig;
mAxe = mSubplot(1,1,1,"shape","square-min");
plotTopo(mAxe, res);
plotLayout(mAxe, 1, 0.5);
cb = colorbar(mAxe, 'position', [0.75, 0.12, 0.01, 0.8]);
cb.Label.String = 'Correlation among behavioral task trials';
cb.Label.FontSize = 12;
cb.Label.VerticalAlignment = 'bottom';
cb.Label.Rotation = -90;

%% Passive
load('D:\Education\Lab\Projects\ECOG\ECOG process\7-10Freq\batch\Passive\CC\Population\Prediction\AC_Prediction_Data.mat');
[~, chMean] = joinSTD(trialAll, trialsECOG, fs);
chMeanP = chMean;
chData(2).chMean = chMeanP;
chData(2).color = "b";
chData(2).legend = "passive";

temp = cellfun(@(x) x(:, tIdx), trialsECOG, "UniformOutput", false);
idx = randperm(length(temp));
temp1 = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(temp(idx(1:fix(length(temp)/2)))), "UniformOutput", false));
temp2 = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(temp(idx(fix(length(temp)/2+1:end)))), "UniformOutput", false));

res = rowFcn(@(x, y) corrAnalysis(x, y), temp1, temp2);
figure;
maximizeFig;
mAxe = mSubplot(1,1,1,"shape","square-min");
plotTopo(mAxe, res);
plotLayout(mAxe, 1, 0.5);
cb = colorbar(mAxe, 'position', [0.75, 0.12, 0.01, 0.8]);
cb.Label.String = 'Correlation among non-behavioral trials';
cb.Label.FontSize = 12;
cb.Label.VerticalAlignment = 'bottom';
cb.Label.Rotation = -90;

%% 
plotRawWaveMulti(chData, windowP);
scaleAxes("x", [0, ISI * nStd]);
scaleAxes("y", "on", "symOpts", "max", "uiOpt", "show");

plotTFACompare(chMeanA, chMeanP, fs, fs, windowP);
scaleAxes("x", [0, ISI * nStd]);
scaleAxes("c", "uiOpt", "show");

res = rowFcn(@(x, y) corrAnalysis(x, y), chMeanA(:, tIdx), chMeanP(:, tIdx));
figure;
maximizeFig;
mAxe = mSubplot(1,1,1,"shape","square-min");
plotTopo(mAxe, res);
plotLayout(mAxe, 1, 0.5);
cb = colorbar(mAxe, 'position', [0.75, 0.12, 0.01, 0.8]);
cb.Label.String = 'Correlation between behavioral task and non-behavioral task';
cb.Label.FontSize = 12;
cb.Label.VerticalAlignment = 'bottom';
cb.Label.Rotation = -90;