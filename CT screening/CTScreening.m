clear; clc; close all;
%% Parameter settings
DATAPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\CC\CT Screening\cc20221212\cc20221212_AC.mat';
% DATAPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\CC\CT Screening\cc20221212\cc20221212_PFC.mat';

params.posIndex = 1;
params.processFcn = @CTScreeningProcess;

colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

%% Processing
[trialAll, ECOGDataset] = ECOGPreprocess(DATAPATH, params);
fs = ECOGDataset.fs;
channels = ECOGDataset.channels;
trialAll(1) = [];

%% Plot
window = [-500, 1000];
freqAll = sort(unique([trialAll.freq]), 'descend')';
freqAll = freqAll(freqAll >= 3920);
trialsECOG = selectEcog(ECOGDataset, trialAll, "trial onset", window);
chData = [];

for fIndex = 1:length(freqAll)
    temp = trialsECOG([trialAll.freq] == freqAll(fIndex));
    chMean = cell2mat(cellfun(@mean, changeCellRowNum(temp), "UniformOutput", false));
    chData(fIndex).chMean = chMean;
    chData(fIndex).color = colors{fIndex};
end

FigWave = plotRawWaveMulti(chData, window, "CT Screening");
scaleAxes("x", [0, 500]);
scaleAxes("y", "cutoffRange", [-60, 60], "symOpts", "max");

%% CBPT
t = linspace(window(1), window(2), size(chMean, 2))';
data = [];
pool = 2:5;
for dIndex = 1:length(pool)
    temp = trialsECOG([trialAll.freq] == freqAll(pool(dIndex)));
    % time 1*nSample
    data(dIndex).time = t' / 1000;
    % label nCh*1 cell
    data(dIndex).label = cellfun(@(x) num2str(x), num2cell(channels)', 'UniformOutput', false);
    % trial nTrial*nCh*nSample
    data(dIndex).trial = cell2mat(cellfun(@(x) permute(x, [3, 1, 2]), temp, "UniformOutput", false));
    % trialinfo nTrial*1
    data(dIndex).trialinfo = repmat(dIndex, [length(temp), 1]);
end

stat = CBPT(data);

p = stat.stat;
mask = stat.mask;
V0 = p .* mask;
windowSortCh = [0, 500];
tIdx = fix((windowSortCh(1) - window(1)) / 1000 * fs) + 1:fix((windowSortCh(2) - window(1)) / 1000 * fs);
[rankVs, chIdx] = sort(sum(mask(:, tIdx), 2), 'descend');
rankVsTemp = sort(sum(abs(V0(:, tIdx)), 2), 'descend');
rankV = unique(rankVs);
rankV = rankV(arrayfun(@(x) length(rankVs(rankVs == x)) > 1, rankV));
for index = 1:length(rankV)
    chIdxTemp = chIdx(rankVs == rankV(index));
    chIdx(rankVs == rankV(index)) = chIdxTemp(obtainArgoutN(@sort, 2, rankVsTemp(rankVs == rankV(index)), 'descend'));
end
V = V0(chIdx, :);

FigCBPT = figure;
maximizeFig;
mSubplot(1, 1, 1, 1, [0, 0, 0, 0], [0.03, 0.01, 0.06, 0.03]);
imagesc("XData", t, "YData", channels, "CData", V);
xlim([0, window(2)]);
ylim([0.5, 64.5]);
yticks(channels);
yticklabels(num2str(channels(chIdx)'));
cm = colormap('jet');
% cm(1:129, :) = repmat([1 1 1], [129, 1]);
% colormap(cm);
title('F-value of comparison among 4 deviant frequency ratio in all channels (significant)');
ylabel('Ranked channels');
xlabel('Time (ms)');
cb = colorbar;
cb.Label.String = '\bf{{\it{F}}-value}';
cb.Label.Interpreter = 'latex';
cb.Label.FontSize = 12;
cb.Label.Position = [2.5, 0];
cb.Label.Rotation = -90;
scaleAxes("c", "symOpts", "max");

%% check repetition frequency band
% window = [-1000, 5000];
% trials = trialAll(10:end-10);
% [trialsECOG, chMean, ~] = selectEcog(ECOGDataset, trials, "trial onset", window);
% Fig2 = plotTFA(chMean, fs0, 300, window);
% Fig = plotTFA2(trialsECOG, fs0, 300, window);
% scaleAxes(Fig,'y',[],[0 10]);
% scaleAxes(Fig,'c',[],[0 5]);