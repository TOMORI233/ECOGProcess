function Granger_ProcessFcn(params)
close all;
ft_setPath2Top;
parseStruct(params);

dataAC  = load(DATAPATH{1});
dataPFC = load(DATAPATH{2});

%% Load
if protocolType == 1 % PE
    protocolStr = 'PE';
    window = dataAC.windowPE;
    dRatioAll = dataAC.dRatioAll;
    dRatio = dataAC.dRatio;
    if trialType == 1
        trialTypeStr = 'dev';
        dRatio0 = dRatio(2:end);
    else
        trialTypeStr = 'std';
        dRatio0 = dRatio(1);
    end
    idx = ismember(dRatioAll, dRatio0);
    trialsECOG_AC  = dataAC.trialsECOG(idx);
    trialsECOG_PFC = dataPFC.trialsECOG(idx);
    titleStr = 'Dev onset';
    windowGranger = [0, 500];
elseif protocolType == 2 % DM
    protocolStr = 'DM';
    window = dataAC.windowDM;
    if trialType == 1
        trialTypeStr = 'correct';
        trialsECOG_AC  = dataAC.trialsECOG_correct;
        trialsECOG_PFC = dataPFC.trialsECOG_correct;
        dRatio0 = [1.02, 1.04, 1.06, 1.08];
    else
        trialTypeStr = 'wrong';
        trialsECOG_AC  = dataAC.trialsECOG_wrong;
        trialsECOG_PFC = dataPFC.trialsECOG_wrong;
        dRatio0 = 1;
    end
    titleStr = 'Dev onset';
    windowGranger = [0, 500];
else % Prediction
    protocolStr = 'Prediction';
    window = dataAC.windowP;
    dRatio0 = 1;
    trialsECOG_AC  = dataAC.trialsECOG;
    trialsECOG_PFC = dataPFC.trialsECOG;
    titleStr = 'Trial onset';
    if trialType == 1
        nStd = 1; % No.[nStd] std sound
    else
        nStd = 7;
    end
    windowGranger = [500 * (nStd - 1), 500 * nStd];
end

mkdir(MONKEYPATH);

fs = dataAC.fs;
channels = dataAC.channels;
topoSize = [8, 8]; % nx * ny

%% Parameter settings
nSmooth = 2;
channels = mat2cell(reshape(channels, topoSize), nSmooth * ones(topoSize(1) / nSmooth, 1), nSmooth * ones(topoSize(1) / nSmooth, 1));
channels = reshape(channels, [numel(channels), 1]);
channels = cellfun(@(x) reshape(x, [1, numel(x)]), channels, "UniformOutput", false);

areaAC = 1:length(channels);
areaPFC = 1:length(channels);

borderPercentage = 0.95; % for scaling granger spectrum

fRange = [0, fs / 2]; % sum granger spectrum within this freq range

%% Perform Granger
try

    if protocolType == 3
        load([MONKEYPATH, 'GrangerData_', protocolStr, '_nStd', num2str(nStd), '.mat']);
    else
        load([MONKEYPATH, 'GrangerData_', protocolStr, '_', trialTypeStr, '.mat']);
    end
    
catch
    tIdx = fix((windowGranger(1) - window(1)) / 1000 * fs) + 1:fix((windowGranger(2) - window(1)) / 1000 * fs);
    
    idxAC = load([PrePATH, 'AC_excludeIdx']);
    idxPFC = load([PrePATH, 'PFC_excludeIdx']);
    chsAC = cellfun(@(x) x(~ismember(x, vertcat(idxAC.badChIdx{:}))), channels, "UniformOutput", false);
    chsPFC = cellfun(@(x) x(~ismember(x, vertcat(idxPFC.badChIdx{:}))), channels, "UniformOutput", false);
    trialsECOG_AC  = cellfun(@(x) cell2mat(cellfun(@(y) mean(x(y, tIdx), 1), chsAC, "UniformOutput", false)), trialsECOG_AC, "UniformOutput", false);
    trialsECOG_PFC = cellfun(@(x) cell2mat(cellfun(@(y) mean(x(y, tIdx), 1), chsPFC, "UniformOutput", false)), trialsECOG_PFC, "UniformOutput", false);
    
    [granger, coh, cohm] = mGranger(trialsECOG_AC, trialsECOG_PFC, window, fs);

    if protocolType == 3
        mSave([MONKEYPATH, 'GrangerData_', protocolStr, '_nStd', num2str(nStd), '.mat'], "granger", "coh", "cohm");
    else
        mSave([MONKEYPATH, 'GrangerData_', protocolStr, '_', trialTypeStr, '.mat'], "granger", "coh", "cohm");
    end
    
end

%% ft plot
cfg           = [];
cfg.parameter = 'grangerspctrm';
cfg.zlim      = [0 0.1];
ftcpFig = figure;
maximizeFig;
ft_connectivityplot(cfg, granger);

if protocolType == 3
    mPrint(ftcpFig, [MONKEYPATH, protocolStr, '_ftconnectivityplot_nStd', num2str(nStd), '.jpg'], "-djpeg", "-r600");
else
    mPrint(ftcpFig, [MONKEYPATH, protocolStr, '_', trialTypeStr, '_ftconnectivityplot.jpg'], "-djpeg", "-r600");
end

%% plot
granger_sum = sum(granger.grangerspctrm(:, :, granger.freq >= fRange(1) & granger.freq <= fRange(2)), 3);

Fig1 = figure;
maximizeFig;
screenSize = get(0, "ScreenSize");
adjIdx = screenSize(4) / screenSize(3);
rightShift = 0.3;
paddings = [(1 - adjIdx + 0.13 + rightShift) / 2, (1 - adjIdx + 0.13 - rightShift) / 2, 0.08, 0.05];

mSubplot(2, 1, 1, [0.35, 1], "alignment", "center-left");
h = histogram(granger_sum, 'BinWidth', 0.01, "DisplayName", "All");
ub = h.BinEdges(find(cumsum(h.Values) >= borderPercentage * sum(h.Values), 1));
lines = [];
lines.X = ub;
lines.legend = [num2str(borderPercentage * 100), '% upper border at ', num2str(ub)];
addLines2Axes(lines);
ylabel('Count');
title(['[', num2str(windowGranger(1)), ', ', num2str(windowGranger(2)), '] ms (dRatio = ', char(join(string(num2str(dRatio0')), ', ')), ' | Each averaged by a ', num2str(nSmooth), '*', num2str(nSmooth), ' area)']);

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
cb.Label.String = 'Granger spectrem';
cb.Label.FontSize = 15;
cb.Label.FontWeight = 'bold';
cb.Label.Rotation = -90;
cb.Label.VerticalAlignment = 'bottom';
colormap('jet');
scaleAxes("c", [0, inf], [0, ub]);

if protocolType == 3
    mPrint(Fig1, [MONKEYPATH, protocolStr, '_connectivityplot_nStd', num2str(nStd), '.jpg'], "-djpeg", "-r600");
else
    mPrint(Fig1, [MONKEYPATH, protocolStr, '_', trialTypeStr, '_connectivityplot.jpg'], "-djpeg", "-r600");
end

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
title([titleStr, ' [', num2str(windowGranger(1)), ', ', num2str(windowGranger(2)), '] ms (dRatio = ', char(join(string(num2str(dRatio0')), ', ')), ' | Each averaged by a ', num2str(nSmooth), '*', num2str(nSmooth), ' area)'], 'FontSize', 15, 'FontWeight', 'bold');
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
scaleAxes("c", "on", "symOpts", "max");

if protocolType == 3
    mPrint(Fig2, [MONKEYPATH, protocolStr, '_diffplot_nStd', num2str(nStd), '.jpg'], "-djpeg", "-r600");
else
    mPrint(Fig2, [MONKEYPATH, protocolStr, '_', trialTypeStr, '_diffplot.jpg'], "-djpeg", "-r600");
end

%% diff plot topo
shiftFromCenter = 0.5;

Fig3 = figure;
maximizeFig;

% AC topo
mAxe = mSubplot(topoSize(1) / nSmooth, topoSize(2) / nSmooth, 1, [topoSize(1) / nSmooth, topoSize(2) / nSmooth], "margins", zeros(1, 4), "paddings", [(1 - adjIdx + 0.13 - shiftFromCenter) / 2, (1 - adjIdx + 0.13 + shiftFromCenter) / 2, 0.09, 0.04], "alignment", "top-left");
text(mAxe, 0.5, 1.02, ['AC | ', titleStr, ' [', num2str(windowGranger(1)), ', ', num2str(windowGranger(2)), '] ms (dRatio = ', char(join(string(num2str(dRatio0')), ', ')), ')'], ...
     "FontSize", 15, "FontWeight", "bold", "HorizontalAlignment", "center");
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
text(mAxe, 0.5, 1.02, ['PFC | ', titleStr, ' [', num2str(windowGranger(1)), ', ', num2str(windowGranger(2)), '] ms (dRatio = ', char(join(string(num2str(dRatio0')), ', ')), ')'], ...
     "FontSize", 15, "FontWeight", "bold", "HorizontalAlignment", "center");set(mAxe, "Visible", "off");
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
scaleAxes("c", "on", "symOpts", "max", "cutoffRange", [-ub, ub]);

if protocolType == 3
    mPrint(Fig3, [MONKEYPATH, protocolStr, '_diffplot_topo_nStd', num2str(nStd), '.jpg'], "-djpeg", "-r600");
else
    mPrint(Fig3, [MONKEYPATH, protocolStr, '_', trialTypeStr, '_diffplot_topo.jpg'], "-djpeg", "-r600");
end
