clear; clc;
% close all;

% load("CC\PE\AC_PE_tuning.mat");
% load("CC\DM\AC_DRP.mat");

% load("CC\PE\PFC_PE_tuning.mat");
% load("CC\DM\PFC_DRP.mat");

% load("XX\PE\AC_PE_tuning.mat");
% load("XX\DM\AC_DRP.mat");

load("XX\PE\PFC_PE_tuning.mat");
load("XX\DM\PFC_DRP.mat");

margins = [0.05, 0.05, 0.1, 0.1];
paddings = [0.05, 0.05, 0.01, 0.01];

alpha = 0.01;
chs = zeros(64, 12);

subplotNumDiff = [1:6, 13:18];
subplotNumP = [7:12, 19:24];

figure;
maximizeFig(gcf);
for wIndex = 1:12
    mAxesDiff(wIndex) = mSubplot(gcf, 4, 6, subplotNumDiff(wIndex), 1, margins, paddings);
    X = abs(resDP(wIndex).v - 0.5);
    Y = abs(tuningSlope(:, wIndex));
    sIdx = resDP(wIndex).p < alpha & P(:, wIndex) < alpha;
    chs(sIdx, wIndex) = 1;
    scatter(mAxesDiff(wIndex), X(sIdx), Y(sIdx), 100, "black", "filled");
    hold on;
    scatter(mAxesDiff(wIndex), X(~sIdx), Y(~sIdx), 100, "black");
    [R, pval] = corr(X, Y, "type", "Pearson");
    title(mAxesDiff(wIndex), ['[', num2str(resDP(wIndex).window), '] | R=', num2str(roundn(R, -4)), ' | p=', num2str(roundn(pval, -4))]);
    xlabel(mAxesDiff(wIndex), 'DRP');
%     xlim(mAxesDiff(wIndex), [0.3, 0.7]);
    if wIndex == 1 || wIndex == 7
        ylabel(mAxesDiff(wIndex), 'PE slope');
    end

    mAxesP(wIndex) = mSubplot(gcf, 4, 6, subplotNumP(wIndex), 1, margins, paddings);
    temp = reshape(chs(:, wIndex), [8, 8])';
    C = flipud(temp);
    C = interp2(C, 5);
    C = imgaussfilt(C, 8);
    X = linspace(1, 8, size(C, 1));
    Y = linspace(1, 8, size(C, 2));
    imagesc(mAxesP(wIndex), "XData", X, "YData", Y, "CData", C);
    colormap(mAxesP(wIndex), "jet");
    set(mAxesP(wIndex), "CLim", [0, 1]);
    xlim(mAxesP(wIndex), [1, 8]);
    ylim(mAxesP(wIndex), [1, 8]);
    xticklabels(mAxesP(wIndex), []);
    yticklabels(mAxesP(wIndex), []);
end