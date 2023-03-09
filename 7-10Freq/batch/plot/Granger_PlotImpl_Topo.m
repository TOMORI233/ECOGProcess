%% Granger topo
FigTopo = figure;
maximizeFig;

% AC topo
mAxe1 = mSubplot(topoSize(1) / nSmooth, topoSize(2) / nSmooth, 1, [topoSize(1) / nSmooth, topoSize(2) / nSmooth], "margins", zeros(1, 4), "paddings", [(1 - adjIdx + 0.13 - shiftFromCenter) / 2, (1 - adjIdx + 0.13 + shiftFromCenter) / 2, 0.09, 0.04], "alignment", "top-left");
text(mAxe1, 0.5, 1.02, ['AC | ', labelStr], "FontSize", 15, "FontWeight", "bold", "HorizontalAlignment", "center");
set(mAxe1, "Visible", "off");
temp = rowFcn(@(x) flip(reshape(x, [topoSize(1) / nSmooth, topoSize(2) / nSmooth])', 1), AC2PFC, "UniformOutput", false);
for index = 1:length(temp)
    mSubplot(topoSize(1) / nSmooth, topoSize(2) / nSmooth, index, "margins", ones(1, 4) * 0.01, "paddings", [(1 - adjIdx + 0.13 - shiftFromCenter) / 2, (1 - adjIdx + 0.13 + shiftFromCenter) / 2, 0.09, 0.04]);
    imagesc("XData", 1:topoSize(1) / nSmooth, "YData", 1:topoSize(2) / nSmooth, "CData", temp{index});
    set(gca, "XLimitMethod", "tight");
    set(gca, "YLimitMethod", "tight");
    xticklabels('');
    yticklabels('');
end

% PFC topo
mAxe2 = mSubplot(topoSize(1) / nSmooth, topoSize(2) / nSmooth, 1, [topoSize(1) / nSmooth, topoSize(2) / nSmooth], "margins", zeros(1, 4), "paddings", [(1 - adjIdx + 0.13 + shiftFromCenter) / 2, (1 - adjIdx + 0.13 - shiftFromCenter) / 2, 0.09, 0.04], "alignment", "top-left");
text(mAxe2, 0.5, 1.02, ['PFC | ', labelStr], "FontSize", 15, "FontWeight", "bold", "HorizontalAlignment", "center");
set(mAxe2, "Visible", "off");
temp = rowFcn(@(x) flip(reshape(x, [topoSize(1) / nSmooth, topoSize(2) / nSmooth])', 1), PFC2AC, "UniformOutput", false);
for index = 1:length(temp)
    mSubplot(topoSize(1) / nSmooth, topoSize(2) / nSmooth, index, "margins", ones(1, 4) * 0.01, "paddings", [(1 - adjIdx + 0.13 + shiftFromCenter) / 2, (1 - adjIdx + 0.13 - shiftFromCenter) / 2, 0.09, 0.04]);
    imagesc("XData", 1:topoSize(1) / nSmooth, "YData", 1:topoSize(2) / nSmooth, "CData", temp{index});
    set(gca, "XLimitMethod", "tight");
    set(gca, "YLimitMethod", "tight");
    xticklabels('');
    yticklabels('');
end

cb = colorbar('Location', 'south', 'position', [0.2, 0.06, 0.6, 0.02]);
cb.Label.String = 'Granger spectrum';
cb.Label.FontSize = 14;
cb.Label.FontWeight = 'bold';
cb.Label.VerticalAlignment = 'top';
cm = colormap('jet');
cm(1:128, :) = repmat([1 1 1], [128, 1]);
colormap(cm);
scaleAxes("c", "on", "symOpts", "max", "cutoffRange", [-ub, ub]);

plotLayout(mAxe1, (monkeyID - 1) * 2 + 1, 0.4);
plotLayout(mAxe2, (monkeyID - 1) * 2 + 2, 0.4);

mPrint(FigTopo, [SAVEPATH, labelStr, '_topo.jpg'], "-djpeg", "-r600");