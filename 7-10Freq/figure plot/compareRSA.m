clear; clc;
% close all force;
tuningPE_AC = load('CC\PE\AC_PE_tuning.mat');
tuningPE_PFC = load('CC\PE\PFC_PE_tuning.mat');
tuningDM_AC = load('CC\DM\AC_DM_tuning.mat');
tuningDM_PFC = load('CC\DM\PFC_DM_tuning.mat');

margins = [0.05, 0.05, 0.1, 0.1];
paddings = [0.01, 0.01, 0.01, 0.01];

alpha = 0.01;
fs = 500;
a = 0.01;
cRangeCutoff = [-1.5, 1.5];
windowPE = [-500, 800];
windowDM = [-200, 800];
windowRSA = [0, 600];
tPE = windowPE(1):1000 / fs:windowPE(2);
tDM = windowDM(1):1000 / fs:windowDM(2);
tIdxPE = fix((windowRSA(1) - windowPE(1)) / 1000 * fs):fix((windowRSA(2) - windowPE(1)) / 1000 * fs);
tIdxDM = fix((windowRSA(1) - windowDM(1)) / 1000 * fs):fix((windowRSA(2) - windowDM(1)) / 1000 * fs);

%% AC
figure;
maximizeFig(gcf);
resultRSA_AC = cell2mat(rowFcn(@(x, y) xcorr(x(tIdxPE), y(tIdxDM)), mMapminmax(tuningPE_AC.PEI, 1), mMapminmax(tuningDM_AC.DMI, 1), "UniformOutput", false));
t = linspace(-diff(windowRSA), diff(windowRSA), size(resultRSA_AC, 2));
for cIndex = 1:64
    mSubplot(gcf, 8, 8, cIndex, [1, 1], margins, paddings);
    plot(t, resultRSA_AC(cIndex, :));
    xlim(windowRSA);
    title(['CH ', num2str(cIndex), ' | xcorr']);
    if cIndex < 57
        xticklabels([]);
    end
end

figure;
imagesc("XData", t, "YData", (1:64) - 0.5, "CData", resultRSA_AC);
xlim(windowRSA);