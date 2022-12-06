clear; clc;
% close all force;
dataAC = load('CC\PE\AC_PE_tuning.mat');
dataPFC = load('CC\PE\PFC_PE_tuning.mat');
% pAC = load('XX\PE\AC_PE_tuning.mat');
% pPFC = load('XX\PE\PFC_PE_tuning.mat');

alpha = 0.01;
edge = (0:50:550) + 25;
fs = 500;

n = 1;
a = 0.01;
cRangeCutoff = [];

windowPE = [-500, 800];
windowSort = [0, 400];
t = windowPE(1) + 1:1000 / fs:windowPE(2);
tIdx = fix((windowSort(1) - windowPE(1)) / 1000 * fs) + 1:fix((windowSort(2) - windowPE(1)) / 1000 * fs);

%% AC
cRangeAC = dataAC.cRange;
resultAC_V = dataAC.V0(dataAC.idx, :);
resultAC_PEI = dataAC.PEI(dataAC.idx, :);

%% PFC
cRangePFC = dataPFC.cRange;
resultPFC_V = dataPFC.V0(dataPFC.idx, :);
resultPFC_PEI = dataPFC.PEI(dataPFC.idx, :);

%% Plot
figure;
maximizeFig(gcf);
% p
subplot(1, 2, 1);
imagesc("XData", t, "YData", (1:64) - 0.5, "CData", resultPFC_V);
hold on;
imagesc("XData", t, "YData", (0:-1:-63) - 0.5, "CData", resultAC_V);
ylim([-64, 64]);
xlim([0, 600]);
plot([0, 600], [0, 0], 'k-', 'LineWidth', 1.2);
title('Predictive error p value');
yticklabels([]);
xlabel('Time from deviant sound onset (ms)');
scaleAxes(gca, "c", [], [-inf, min([cRangeAC(2), cRangePFC(2)])], "max");
cb = colorbar;
cb.Label.String = '\bf{{\it{F}}-value}';
cb.Label.FontSize = 12;
cb.Label.FontWeight = 'bold';
cb.Label.Rotation = -90;
cb.Label.VerticalAlignment = 'baseline';
text(-50, -29, 'AC', 'FontSize', 15, 'FontWeight', 'bold', 'Rotation', 90);
text(-50, 29, 'PFC', 'FontSize', 15, 'FontWeight', 'bold', 'Rotation', 90);

% PEI
subplot(1, 2, 2);
imagesc("XData", t, "YData", (1:64) - 0.5, "CData", resultPFC_PEI);
hold on;
imagesc("XData", t, "YData", (0:-1:-63) - 0.5, "CData", resultAC_PEI);
ylim([-64, 64]);
xlim([0, 600]);
plot([0, 600], [0, 0], 'k-', 'LineWidth', 1.2);
title('Predictive error index');
yticklabels([]);
xlabel('Time from deviant sound onset (ms)');
scaleAxes(gca, "c", [], [-15, 15], "max");
cb = colorbar;
cb.Label.String = 'PEI = Wave_{1.08} - Wave_{1.02}';
cb.Label.FontSize = 12;
cb.Label.FontWeight = 'bold';
cb.Label.Rotation = -90;
cb.Label.VerticalAlignment = 'baseline';
text(-50, -29, 'AC', 'FontSize', 15, 'FontWeight', 'bold', 'Rotation', 90);
text(-50, 29, 'PFC', 'FontSize', 15, 'FontWeight', 'bold', 'Rotation', 90);

colormap("jet");