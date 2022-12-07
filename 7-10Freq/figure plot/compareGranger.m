%% granger
clear; clc;

monkeyID = 2; % 1-CC, 2-XX
type = 1; % 1-PE, 2-DM

%% Load
if type == 1 % PE

    if monkeyID == 1
        dataAC  = load("CC\PE\AC_PE_Data.mat");
        dataPFC = load("CC\PE\PFC_PE_Data.mat");
    else
        dataAC  = load("XX\PE\AC_PE_Data.mat");
        dataPFC = load("XX\PE\PFC_PE_Data.mat");
    end
    
    window = dataAC.windowPE;

    dRatioAll = dataAC.dRatioAll;
    dRatio = dataAC.dRatio;
    % dRatio1 = dRatio(1);
    dRatio0 = dRatio(2:end);

    idx = ismember(dRatioAll, dRatio0);
    trialsECOG_AC  = dataAC.trialsECOG(idx);
    trialsECOG_PFC = dataPFC.trialsECOG(idx);
else % DM
    
    if monkeyID == 1
        dataAC  = load("CC\DM\AC_DM_Data.mat");
        dataPFC = load("CC\DM\PFC_DM_Data.mat");
    else
        dataAC  = load("XX\DM\AC_DM_Data.mat");
        dataPFC = load("XX\DM\PFC_DM_Data.mat");
    end
    
    window = dataAC.windowDM;

    trialsECOG_AC  = dataAC.trialsECOG_correct;
    trialsECOG_PFC = dataPFC.trialsECOG_correct;
    dRatio0 = [1.02, 1.04, 1.06, 1.08];

    % trialsECOG_AC  = dataAC.trialsECOG_wrong;
    % trialsECOG_PFC = dataPFC.trialsECOG_wrong;
    % dRatio0 = 1;
end

fs = dataAC.fs;
channels = dataAC.channels;
topoSize = [8, 8]; % nx * ny

%% Parameter settings
windowGranger = [0, 300];

nSmooth = 2;
channels = mat2cell(reshape(channels, topoSize), nSmooth * ones(topoSize(1) / nSmooth, 1), nSmooth * ones(topoSize(1) / nSmooth, 1));
channels = reshape(channels, [numel(channels), 1]);
channels = cellfun(@(x) reshape(x, [1, numel(x)]), channels, "UniformOutput", false);

areaAC = 1:length(channels);
areaPFC = 1:length(channels);

borderPercentage = 0.95; % for scaling granger spectrum

%% Perform Granger
tIdx = fix((windowGranger(1) - window(1)) / 1000 * fs) + 1:fix((windowGranger(2) - window(1)) / 1000 * fs);
trialsECOG_AC  = cellfun(@(x) cell2mat(cellfun(@(y) mean(x(y, tIdx), 1), channels, "UniformOutput", false)), trialsECOG_AC, "UniformOutput", false);
trialsECOG_PFC = cellfun(@(x) cell2mat(cellfun(@(y) mean(x(y, tIdx), 1), channels, "UniformOutput", false)), trialsECOG_PFC, "UniformOutput", false);
[granger, coh, cohm] = mGranger(trialsECOG_AC, trialsECOG_PFC, window, fs);

%% ft plot
cfg           = [];
cfg.parameter = 'grangerspctrm';
cfg.zlim      = [0 0.1];
figure;
maximizeFig;
ft_connectivityplot(cfg, granger);

%% plot
granger_sum = sum(granger.grangerspctrm, 3);

figure;
maximizeFig;
screenSize = get(0, "ScreenSize");
adjIdx = screenSize(4) / screenSize(3);
rightShift = 0.3;
paddings = [(1 - adjIdx + 0.13 + rightShift) / 2, (1 - adjIdx + 0.13 - rightShift) / 2, 0.08, 0.05];

mSubplot(2, 1, 1, [0.35, 1], "alignment", "center-left");
h = histogram(granger_sum, 'BinWidth', 0.01, "DisplayName", "All");
upper = h.BinEdges(find(cumsum(h.Values) >= borderPercentage * sum(h.Values), 1));
lines = [];
lines.X = upper;
lines.legend = [num2str(borderPercentage * 100), '% upper border at ', num2str(upper)];
addLines2Axes(lines);
ylabel('Count');
title(['Dev onset [', num2str(windowGranger(1)), ', ', num2str(windowGranger(2)), '] ms (dRatio = ', char(join(string(num2str(dRatio0')), ', ')), ' | Each averaged by a ', num2str(nSmooth), '*', num2str(nSmooth), ' area)']);

AC2AC   = granger_sum(1:length(channels), 1:length(channels));
AC2PFC  = granger_sum(1:length(channels), length(channels) + 1:end);
PFC2AC  = granger_sum(length(channels) + 1:end, 1:length(channels));
PFC2PFC = granger_sum(length(channels) + 1:end, length(channels) + 1:end);

a1 = mSubplot(2, 1, 2, [0.35, 0.5], "alignment", "top-left");
histogram(AC2PFC, "DisplayName", "From AC to PFC", 'BinWidth', 0.05, "FaceColor", "r");
legend;
ylabel('Count');
xticklabels('');
a2 = mSubplot(2, 1, 2, [0.35, 0.5], "alignment", "bottom-left");
histogram(PFC2AC, "DisplayName", "From PFC to AC", 'BinWidth', 0.05, "FaceColor", "b");
legend;
xlabel('Granger spectrum');
ylabel('Count');
scaleAxes([a1, a2], "x", [0, inf]);
scaleAxes([a1, a2], "y", [0, inf]);
lines = [];
lines.X = mean(AC2PFC, "all");
lines.color = 'r';
lines.legend = ['mean at ', num2str(lines.X)];
addLines2Axes(a1, lines);
lines.X = mean(PFC2AC, "all");
lines.color = 'b';
lines.legend = ['mean at ', num2str(lines.X)];
addLines2Axes(a2, lines);

mSubplot(2, 2, 1, "shape", "fill", "paddings", paddings);
imagesc("XData", areaAC, "YData", areaPFC, "CData", AC2PFC');
xlim([areaAC(1) - 0.5, areaAC(end) + 0.5]);
ylim([areaPFC(1) - 0.5, areaPFC(end) + 0.5]);
xticklabels('');
yticks(areaPFC);
ylabel('To PFC', 'FontSize', 12, 'FontWeight', 'bold');
set(gca, "Box", "on");
set(gca, "BoxStyle", "full");
set(gca, "LineWidth", 3);

mSubplot(2, 2, 3, "shape", "fill", "paddings", paddings);
imagesc("XData", areaAC, "YData", areaAC, "CData", AC2AC');
xlim([areaAC(1) - 0.5, areaAC(end) + 0.5]);
ylim([areaAC(1) - 0.5, areaAC(end) + 0.5]);
xticks(areaAC);
yticks(areaAC);
xlabel('From AC', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('To AC', 'FontSize', 12, 'FontWeight', 'bold');
set(gca, "Box", "on");
set(gca, "BoxStyle", "full");
set(gca, "LineWidth", 3);

mSubplot(2, 2, 2, "shape", "fill", "paddings", paddings);
imagesc("XData", areaPFC, "YData", areaPFC, "CData", PFC2PFC');
xlim([areaPFC(1) - 0.5, areaPFC(end) + 0.5]);
ylim([areaPFC(1) - 0.5, areaPFC(end) + 0.5]);
xticklabels('');
yticklabels('');
set(gca, "Box", "on");
set(gca, "BoxStyle", "full");
set(gca, "LineWidth", 3);

mSubplot(2, 2, 4, "shape", "fill", "paddings", paddings);
imagesc("XData", areaPFC, "YData", areaAC, "CData", PFC2AC');
xlim([areaPFC(1) - 0.5, areaPFC(end) + 0.5]);
ylim([areaAC(1) - 0.5, areaAC(end) + 0.5]);
xticks(areaPFC);
yticklabels('');
xlabel('From PFC', 'FontSize', 12, 'FontWeight', 'bold');
set(gca, "Box", "on");
set(gca, "BoxStyle", "full");
set(gca, "LineWidth", 3);

cb = colorbar('position', [0.9, 0.1, 0.015, 0.8]);
cb.Label.String = 'Granger spectrem';
cb.Label.FontSize = 15;
cb.Label.FontWeight = 'bold';
cb.Label.Rotation = -90;
cb.Label.VerticalAlignment = 'bottom';
colormap('jet');
scaleAxes("c", [0, inf], [0, upper]);

%% diff plot
figure;
maximizeFig;
mSubplot(1, 1, 1, "shape", "square-max");
imagesc("XData", areaAC, "YData", areaPFC, "CData", AC2PFC' - PFC2AC);
xlim([areaAC(1) - 0.5, areaAC(end) + 0.5]);
ylim([areaPFC(1) - 0.5, areaPFC(end) + 0.5]);
xlabel('AC', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('PFC', 'FontSize', 16, 'FontWeight', 'bold');
xticks(areaAC);
yticks(areaPFC);
title(['Dev onset [', num2str(windowGranger(1)), ', ', num2str(windowGranger(2)), '] ms (dRatio = ', char(join(string(num2str(dRatio0')), ', ')), ' | Each averaged by a ', num2str(nSmooth), '*', num2str(nSmooth), ' area)'], 'FontSize', 15, 'FontWeight', 'bold');
set(gca, "Box", "on");
set(gca, "BoxStyle", "full");
set(gca, "LineWidth", 3);

cb = colorbar('position', [0.75, 0.12, 0.01, 0.8]);
cb.Label.String = '\Delta Granger spectrem (Red: AC as source / Blue: PFC as source)';
cb.Label.FontSize = 14;
cb.Label.FontWeight = 'bold';
cb.Label.Rotation = -90;
cb.Label.VerticalAlignment = 'bottom';
colormap('jet');
scaleAxes("c", [], [], "max");

%% diff plot topo
shiftFromCenter = 0.5;

figure;
maximizeFig;

% AC topo
mAxe = mSubplot(topoSize(1) / nSmooth, topoSize(2) / nSmooth, 1, [topoSize(1) / nSmooth, topoSize(2) / nSmooth], "margins", zeros(1, 4), "paddings", [(1 - adjIdx + 0.13 - shiftFromCenter) / 2, (1 - adjIdx + 0.13 + shiftFromCenter) / 2, 0.09, 0.04], "alignment", "top-left");
text(mAxe, 0.5, 1.02, 'AC', "FontSize", 15, "FontWeight", "bold", "HorizontalAlignment", "center");
set(mAxe, "Visible", "off");
temp = rowFcn(@(x) flip(reshape(x, [topoSize(1) / nSmooth, topoSize(2) / nSmooth])', 1), (AC2PFC' - PFC2AC)', "UniformOutput", false);
for index = 1:length(temp)
    mSubplot(topoSize(1) / nSmooth, topoSize(2) / nSmooth, index, "margins", ones(1, 4) * 0.01, "paddings", [(1 - adjIdx + 0.13 - shiftFromCenter) / 2, (1 - adjIdx + 0.13 + shiftFromCenter) / 2, 0.09, 0.04]);
    imagesc("XData", 1:topoSize(1) / nSmooth, "YData", 1:topoSize(2) / nSmooth, "CData", temp{index});
    xlim([0.5, 4.5]);
    ylim([0.5, 4.5]);
    xticklabels('');
    yticklabels('');
end

% PFC topo
mAxe = mSubplot(topoSize(1) / nSmooth, topoSize(2) / nSmooth, 1, [topoSize(1) / nSmooth, topoSize(2) / nSmooth], "margins", zeros(1, 4), "paddings", [(1 - adjIdx + 0.13 + shiftFromCenter) / 2, (1 - adjIdx + 0.13 - shiftFromCenter) / 2, 0.09, 0.04], "alignment", "top-left");
text(mAxe, 0.5, 1.02, 'PFC', "FontSize", 15, "FontWeight", "bold", "HorizontalAlignment", "center");
set(mAxe, "Visible", "off");
temp = rowFcn(@(x) flip(reshape(x, [topoSize(1) / nSmooth, topoSize(2) / nSmooth])', 1), AC2PFC' - PFC2AC, "UniformOutput", false);
for index = 1:length(temp)
    mSubplot(topoSize(1) / nSmooth, topoSize(2) / nSmooth, index, "margins", ones(1, 4) * 0.01, "paddings", [(1 - adjIdx + 0.13 + shiftFromCenter) / 2, (1 - adjIdx + 0.13 - shiftFromCenter) / 2, 0.09, 0.04]);
    imagesc("XData", 1:topoSize(1) / nSmooth, "YData", 1:topoSize(2) / nSmooth, "CData", temp{index});
    xlim([0.5, 4.5]);
    ylim([0.5, 4.5]);
    xticklabels('');
    yticklabels('');
end

cb = colorbar('Location', 'south', 'position', [0.2, 0.06, 0.6, 0.02]);
cb.Label.String = '\Delta Granger spectrem (Red: AC as source / Blue: PFC as source)';
cb.Label.FontSize = 14;
cb.Label.FontWeight = 'bold';
cb.Label.VerticalAlignment = 'top';
colormap('jet');
scaleAxes("c", [], [], "max");
