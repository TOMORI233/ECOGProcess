clear; clc;
% close all force;

pAC = load('CC\DM\AC_DM_tuning.mat');
pPFC = load('CC\DM\PFC_DM_tuning.mat');
windowSort = [50, 350];

% pAC = load('XX\DM\AC_DM_tuning.mat');
% pPFC = load('XX\DM\PFC_DM_tuning.mat');
% windowSort = [100, 400];

alpha = 0.01;
edge = (0:50:700) + 25;
fs = 500;

a = 0.01;
cRangeCutoff = [-1.5, 1.5];

windowDM = [-200, 800];
t = windowDM(1) + 1:1000 / fs:windowDM(2);
tIdx = fix((windowSort(1) - windowDM(1)) / 1000 * fs) + 1:fix((windowSort(2) - windowDM(1)) / 1000 * fs);

%% AC
[~, idxAC] = sort(mean(pAC.p(:, tIdx), 2), 1, "ascend");
temp = pAC.p;
temp = temp(idxAC, :);
resultAC_p = log(temp / alpha) / log(a);
resultAC_DMI = pAC.DMI(idxAC, :);

%% PFC
[~, idxPFC] = sort(mean(pPFC.p(:, tIdx), 2), 1, "ascend");
temp = pPFC.p;
temp = temp(idxPFC, :);
resultPFC_p = log(temp / alpha) / log(a);
resultPFC_DMI = pPFC.DMI(idxPFC, :);

%% Plot
% p
figure;
maximizeFig(gcf);
subplot(1, 2, 1);
imagesc("XData", t, "YData", (1:64) - 0.5, "CData", resultPFC_p);
hold on;
imagesc("XData", t, "YData", (0:-1:-63) - 0.5, "CData", resultAC_p);
ylim([-64, 64]);
xlim([0, 600]);
plot([0, 600], [0, 0], 'k-', 'LineWidth', 1.2);
title('Z-scored wave p value');
yticklabels([]);
xlabel('Time from deviant sound onset (ms)');
set(gca, "CLim", cRangeCutoff);
cb = colorbar;
cb.Label.String = ['log_{', num2str(a), '}(p/', num2str(alpha), ')'];
cb.Label.FontSize = 12;
cb.Label.FontWeight = 'bold';
cb.Label.Rotation = -90;
cb.Label.VerticalAlignment = 'baseline';
text(-50, -29, 'AC', 'FontSize', 15, 'FontWeight', 'bold', 'Rotation', 90);
text(-50, 29, 'PFC', 'FontSize', 15, 'FontWeight', 'bold', 'Rotation', 90);

% DMI
subplot(1, 2, 2);
imagesc("XData", t, "YData", (1:64) - 0.5, "CData", resultPFC_DMI);
hold on;
imagesc("XData", t, "YData", (0:-1:-63) - 0.5, "CData", resultAC_DMI);
ylim([-64, 64]);
xlim([0, 600]);
plot([0, 600], [0, 0], 'k-', 'LineWidth', 1.2);
title('Decision making index');
yticklabels([]);
xlabel('Time from deviant sound onset (ms)');
scaleAxes(gca, "c", [], [], "min");
cb = colorbar;
cb.Label.String = 'DMI = Z-scored Wave_{push} - Z-scored Wave_{no push}';
cb.Label.FontSize = 12;
cb.Label.FontWeight = 'bold';
cb.Label.Rotation = -90;
cb.Label.VerticalAlignment = 'baseline';
text(-50, -29, 'AC', 'FontSize', 15, 'FontWeight', 'bold', 'Rotation', 90);
text(-50, 29, 'PFC', 'FontSize', 15, 'FontWeight', 'bold', 'Rotation', 90);