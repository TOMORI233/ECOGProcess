%% Histogram
Fig1 = figure;
maximizeFig;
screenSize = get(0, "ScreenSize");
adjIdx = screenSize(4) / screenSize(3);
rightShift = 0.3;
paddings = [(1 - adjIdx + 0.13 + rightShift) / 2, (1 - adjIdx + 0.13 - rightShift) / 2, 0.08, 0.05];

mSubplot(2, 1, 1, [0.35, 1], "alignment", "center-left");
h = histogram(grangerIndex, "DisplayName", "All");
ub = h.BinEdges(find(cumsum(h.Values) >= borderPercentage * sum(h.Values), 1));
ylabel('Count');
title(labelStr);
lines = [];
lines.X = ub;
lines.legend = [num2str(borderPercentage * 100), '% upper border at ', num2str(ub)];
addLines2Axes(lines);

a1 = mSubplot(2, 1, 2, [0.35, 0.5], "alignment", "top-left");
histogram(AC2PFC, "DisplayName", "From AC to PFC", "FaceColor", "r");
legend;
ylabel('Count');
xticklabels('');
a2 = mSubplot(2, 1, 2, [0.35, 0.5], "alignment", "bottom-left");
histogram(PFC2AC, "DisplayName", "From PFC to AC", "FaceColor", "b");
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
yticklabels('');
ylabel('To PFC', 'FontSize', 12, 'FontWeight', 'bold');
set(gca, "Box", "on");
set(gca, "BoxStyle", "full");
set(gca, "LineWidth", 3);

mSubplot(2, 2, 3, "shape", "fill", "paddings", paddings);
imagesc("XData", areaAC, "YData", areaAC, "CData", AC2AC');
xlim([areaAC(1) - 0.5, areaAC(end) + 0.5]);
ylim([areaAC(1) - 0.5, areaAC(end) + 0.5]);
xticklabels('');
yticklabels('');
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
xticklabels('');
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