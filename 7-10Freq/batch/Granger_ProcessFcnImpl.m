function Granger_ProcessFcnImpl(trialsECOG_AC, trialsECOG_PFC, params)
% Input:
%     trialsECOG_AC/_PFC: nTrial*1 cell, each with a nCh*nSample double matrix
%     params:
%         - fs: sample freq, in Hz, default=500
%         - windowData: data window, in ms, default=[0,500]
%         - nSmooth: smooth with a nSmooth*nSmooth mask (no overlapping), default=2 (nSmooth=1 means no smoothing)
%         - topoSize: [nx, ny], default: [8, 8]
%         - borderPercentage: for scaling granger spectrum, default=0.95
%         - fRange: sum granger spectrum within this freq range, default=[0,250]
%         - SAVEPATH: root save path
%         - labelStr: title and file name

narginchk(2, 3);

if nargin < 3
    params = [];
end

paramsDefault = struct("fs", 500, ...
                       "window", [0, 500], ...
                       "nSmooth", 2, ...
                       "topoSize", [8, 8], ...
                       "borderPercentage", 0.95, ...
                       "fRange", [0, 250], ...
                       "SAVEPATH", [pwd, '\'], ...
                       "labelStr", '');
params = getOrFull(params, paramsDefault);
parseStruct(params);

mkdir(SAVEPATH);

%% Parameter settings
channels = 1:size(trialsECOG_AC{1}, 1);
channels = mat2cell(reshape(channels, topoSize), nSmooth * ones(topoSize(1) / nSmooth, 1), nSmooth * ones(topoSize(1) / nSmooth, 1));
channels = reshape(channels, [numel(channels), 1]);
channels = cellfun(@(x) reshape(x, [1, numel(x)]), channels, "UniformOutput", false);
channelsAC = cellfun(@(x) x(~ismember(x, badCHsAC)), channels, "UniformOutput", false);
channelsPFC = cellfun(@(x) x(~ismember(x, badCHsPFC)), channels, "UniformOutput", false);

if any(cellfun(@isempty, channelsAC)) || any(cellfun(@isempty, channelsPFC))
    error("Too many channels excluded!");
end

areaAC = 1:length(channels);
areaPFC = 1:length(channels);

%% Perform Granger
try
    load([SAVEPATH, 'GrangerData_', labelStr, '.mat']);
catch
    trialsECOG_AC  = cellfun(@(x) cell2mat(cellfun(@(y) mean(x(y, :), 1), channelsAC, "UniformOutput", false)), trialsECOG_AC, "UniformOutput", false);
    trialsECOG_PFC = cellfun(@(x) cell2mat(cellfun(@(y) mean(x(y, :), 1), channelsPFC, "UniformOutput", false)), trialsECOG_PFC, "UniformOutput", false);
    granger = mGranger(trialsECOG_AC, trialsECOG_PFC, windowData, fs);
    mSave([SAVEPATH, 'GrangerData_', labelStr, '.mat'], "granger");
end

%% ft plot
cfg           = [];
cfg.parameter = 'grangerspctrm';
cfg.zlim      = [0 0.1];
ftcpFig = figure;
maximizeFig;
ft_connectivityplot(cfg, granger);
mPrint(ftcpFig, [SAVEPATH, labelStr, '_ftconnectivityplot.jpg'], "-djpeg", "-r600");

%% hist plot
granger_sum = sum(granger.grangerspctrm(:, :, granger.freq >= fRange(1) & granger.freq <= fRange(2)), 3);

AC2AC   = granger_sum(1:length(channels), 1:length(channels));
AC2PFC  = granger_sum(1:length(channels), length(channels) + 1:end);
PFC2AC  = granger_sum(length(channels) + 1:end, 1:length(channels));
PFC2PFC = granger_sum(length(channels) + 1:end, length(channels) + 1:end);

Fig1 = figure;
maximizeFig;
screenSize = get(0, "ScreenSize");
adjIdx = screenSize(4) / screenSize(3);
rightShift = 0.3;
paddings = [(1 - adjIdx + 0.13 + rightShift) / 2, (1 - adjIdx + 0.13 - rightShift) / 2, 0.08, 0.05];

mSubplot(2, 1, 1, [0.35, 1], "alignment", "center-left");
h = histogram(granger_sum, 'BinWidth', 0.01, "DisplayName", "All");
ub = h.BinEdges(find(cumsum(h.Values) >= borderPercentage * sum(h.Values), 1));
ylabel('Count');
title(labelStr);
lines = [];
lines.X = ub;
lines.legend = [num2str(borderPercentage * 100), '% upper border at ', num2str(ub)];
addLines2Axes(lines);

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
scaleAxes([a1, a2], "x", [0, ub]);
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
cb.Label.String = 'Granger spectrum';
cb.Label.FontSize = 15;
cb.Label.FontWeight = 'bold';
cb.Label.Rotation = -90;
cb.Label.VerticalAlignment = 'bottom';
colormap('jet');
scaleAxes("c", [0, inf], [0, ub]);

mPrint(Fig1, [SAVEPATH, labelStr, '_connectivityplot.jpg'], "-djpeg", "-r600");

%% diff plot
Fig2 = figure;
maximizeFig;
mSubplot(1, 1, 1, "shape", "square-min");
imagesc("XData", areaAC, "YData", areaPFC, "CData", AC2PFC' - PFC2AC);
xlim([areaAC(1) - 0.5, areaAC(end) + 0.5]);
ylim([areaPFC(1) - 0.5, areaPFC(end) + 0.5]);
xlabel('AC', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('PFC', 'FontSize', 16, 'FontWeight', 'bold');
xticks(areaAC);
yticks(areaPFC);
title(labelStr, 'FontSize', 15, 'FontWeight', 'bold');
set(gca, "Box", "on");
set(gca, "BoxStyle", "full");
set(gca, "LineWidth", 3);

cb = colorbar('position', [0.75, 0.12, 0.01, 0.8]);
cb.Label.String = '\Delta Granger spectrum (Red: AC as source / Blue: PFC as source)';
cb.Label.FontSize = 14;
cb.Label.FontWeight = 'bold';
cb.Label.Rotation = -90;
cb.Label.VerticalAlignment = 'bottom';
colormap('jet');
scaleAxes("c", "on", "symOpts", "max");

mPrint(Fig2, [SAVEPATH, labelStr, '_diffplot.jpg'], "-djpeg", "-r600");

%% diff plot topo
shiftFromCenter = 0.5;

Fig3 = figure;
maximizeFig;

% AC topo
mAxe = mSubplot(topoSize(1) / nSmooth, topoSize(2) / nSmooth, 1, [topoSize(1) / nSmooth, topoSize(2) / nSmooth], "margins", zeros(1, 4), "paddings", [(1 - adjIdx + 0.13 - shiftFromCenter) / 2, (1 - adjIdx + 0.13 + shiftFromCenter) / 2, 0.09, 0.04], "alignment", "top-left");
text(mAxe, 0.5, 1.02, ['AC | ', labelStr], "FontSize", 15, "FontWeight", "bold", "HorizontalAlignment", "center");
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
text(mAxe, 0.5, 1.02, ['PFC | ', labelStr], "FontSize", 15, "FontWeight", "bold", "HorizontalAlignment", "center");
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
cb.Label.String = '\Delta Granger spectrum (Red: AC as source / Blue: PFC as source)';
cb.Label.FontSize = 14;
cb.Label.FontWeight = 'bold';
cb.Label.VerticalAlignment = 'top';
colormap('jet');
scaleAxes("c", "on", "symOpts", "max", "cutoffRange", [-ub, ub]);

mPrint(Fig3, [SAVEPATH, labelStr, '_diffplot_topo.jpg'], "-djpeg", "-r600");

%% Grangerspectrm topo
Fig4 = figure;
maximizeFig;

% AC topo
mAxe = mSubplot(topoSize(1) / nSmooth, topoSize(2) / nSmooth, 1, [topoSize(1) / nSmooth, topoSize(2) / nSmooth], "margins", zeros(1, 4), "paddings", [(1 - adjIdx + 0.13 - shiftFromCenter) / 2, (1 - adjIdx + 0.13 + shiftFromCenter) / 2, 0.09, 0.04], "alignment", "top-left");
text(mAxe, 0.5, 1.02, ['AC | ', labelStr], "FontSize", 15, "FontWeight", "bold", "HorizontalAlignment", "center");
set(mAxe, "Visible", "off");
temp = rowFcn(@(x) flip(reshape(x, [topoSize(1) / nSmooth, topoSize(2) / nSmooth])', 1), AC2PFC, "UniformOutput", false);
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
text(mAxe, 0.5, 1.02, ['PFC | ', labelStr], "FontSize", 15, "FontWeight", "bold", "HorizontalAlignment", "center");
set(mAxe, "Visible", "off");
temp = rowFcn(@(x) flip(reshape(x, [topoSize(1) / nSmooth, topoSize(2) / nSmooth])', 1), PFC2AC, "UniformOutput", false);
for index = 1:length(temp)
    mSubplot(topoSize(1) / nSmooth, topoSize(2) / nSmooth, index, "margins", ones(1, 4) * 0.01, "paddings", [(1 - adjIdx + 0.13 + shiftFromCenter) / 2, (1 - adjIdx + 0.13 - shiftFromCenter) / 2, 0.09, 0.04]);
    imagesc("XData", 1:topoSize(1) / nSmooth, "YData", 1:topoSize(2) / nSmooth, "CData", temp{index});
    xlim([0.5, 4.5]);
    ylim([0.5, 4.5]);
    xticklabels('');
    yticklabels('');
end

cb = colorbar('Location', 'south', 'position', [0.2, 0.06, 0.6, 0.02]);
cb.Label.String = 'Granger spectrum';
cb.Label.FontSize = 14;
cb.Label.FontWeight = 'bold';
cb.Label.VerticalAlignment = 'top';
colormap('jet');
scaleAxes("c", "on", "symOpts", "max", "cutoffRange", [-ub, ub]);

mPrint(Fig4, [SAVEPATH, labelStr, '_topo.jpg'], "-djpeg", "-r600");