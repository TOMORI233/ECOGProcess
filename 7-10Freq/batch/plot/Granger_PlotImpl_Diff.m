%% diff plot
Fig2 = figure;
maximizeFig;
mSubplot(1, 1, 1, "shape", "square-min");
imagesc("XData", areaAC, "YData", areaPFC, "CData", AC2PFC' - PFC2AC);
set(gca, "XLimitMethod", "tight");
set(gca, "YLimitMethod", "tight");
xlabel('AC', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('PFC', 'FontSize', 16, 'FontWeight', 'bold');
xticklabels('');
yticklabels('');
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