%% PE vs DM in PFC
figure;
maximizeFig;
% p
subplot(1, 2, 1);
imagesc("XData", tDM, "YData", (1:64) - 0.5, "CData", resultPFC_DM_V);
hold on;
imagesc("XData", tPE, "YData", (0:-1:-63) - 0.5, "CData", resultPFC_PE_V);
ylim([-64, 64]);
xlim([0, windowView]);
plot([0, windowView], [0, 0], 'k-', 'LineWidth', 1.2);
title('Prefrontal cortex', 'FontSize', 15, 'FontWeight', 'bold');
yticklabels([]);
xlabel('Time from deviant sound onset (ms)');
scaleAxes(gca, "c", [], [], "max");
cb = colorbar;
cb.Label.String = 'Normalized statistic value';
cb.Label.FontSize = 12;
cb.Label.FontWeight = 'bold';
cb.Label.Rotation = -90;
cb.Label.VerticalAlignment = 'bottom';
text(-50, 29, 'DM', 'FontSize', 15, 'FontWeight', 'bold', 'Rotation', 90);
text(-50, -29, 'PE', 'FontSize', 15, 'FontWeight', 'bold', 'Rotation', 90);
cm = colormap(gca, 'jet');
cm(127:129, :) = repmat([1 1 1], 3, 1); % white
colormap(gca, cm);

% PEI & DMI
subplot(1, 2, 2);
imagesc("XData", tDM, "YData", (1:64) - 0.5, "CData", resultPFC_DMI);
hold on;
imagesc("XData", tPE, "YData", (0:-1:-63) - 0.5, "CData", resultPFC_PEI);
ylim([-64, 64]);
xlim([0, windowView]);
plot([0, windowView], [0, 0], 'k-', 'LineWidth', 1.2);
title('Prefrontal cortex', 'FontSize', 15, 'FontWeight', 'bold');
yticklabels([]);
xlabel('Time from deviant sound onset (ms)');
scaleAxes(gca, "c", [], [], "max");
cb = colorbar;
cb.Label.String = 'Normalized PEI & DMI';
cb.Label.FontSize = 12;
cb.Label.FontWeight = 'bold';
cb.Label.Rotation = -90;
cb.Label.VerticalAlignment = 'bottom';
text(-50, 29, 'DM', 'FontSize', 15, 'FontWeight', 'bold', 'Rotation', 90);
text(-50, -29, 'PE', 'FontSize', 15, 'FontWeight', 'bold', 'Rotation', 90);
colormap(gca, 'jet');

mPrint(gcf, [MONKEYPATH, 'PFC_PE&DM.jpg'], "-djpeg", "-r600");