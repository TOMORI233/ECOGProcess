%% PE vs DM in each channel in PFC
figure;
maximizeFig;
mSubplot(2, 2, 1);
sTimePFC_DM = rowFcn(@(x) find(x ~= 0, 1) / fs * 1000, tuningDM_PFC.V0(:, tDM >= 0), "UniformOutput", false);
sTimePFC_PE = rowFcn(@(x) find(x ~= 0, 1) / fs * 1000, tuningPE_PFC.V0_MMN(:, tPE >= 0), "UniformOutput", false);
channels = (1:length(idxPFC_DM))';
chIdxDM = cellfun(@(x) ~isempty(x) && x < timeLim, sTimePFC_DM);
chIdxPE = cellfun(@(x) ~isempty(x) && x < timeLim, sTimePFC_PE);
sTimePFC_DM(~chIdxDM) = {[]};
sTimePFC_PE(~chIdxPE) = {[]};
plot(channels(chIdxDM), cell2mat(sTimePFC_DM'), 'b.-', 'LineWidth', 1.5, 'MarkerSize', 15, 'DisplayName', 'DM');
hold on;
plot(channels(chIdxPE), cell2mat(sTimePFC_PE'), 'r.-', 'LineWidth', 1.5, 'MarkerSize', 15, 'DisplayName', 'PE');
xlim([0, max(channels) + 1]);
xlabel('Channel Number', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Time (ms)', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'northwest');
title('Time of the first significant sample in PFC' , 'FontSize', 12, 'FontWeight', 'bold');
lines = [];
lines(1).Y = min(cell2mat(sTimePFC_DM'));
lines(1).color = 'b';
lines(2).Y = min(cell2mat(sTimePFC_PE'));
lines(2).color = 'r';
addLines2Axes(gca, lines);

mSubplot(2, 2, 2);
diffTimePFC = cellfun(@(x, y) y - x, sTimePFC_PE, sTimePFC_DM, "UniformOutput", false);
histogram(cell2mat(diffTimePFC'), 'FaceColor', [0.5 0.5 0.5], 'BinWidth', 25);
xlabel('Time (ms)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Count', 'FontSize', 12, 'FontWeight', 'bold');
title('DM - PE' , 'FontSize', 12, 'FontWeight', 'bold');
lines = [];
lines.X = 0;
addLines2Axes(gca, lines);

mSubplot(2, 1, 2, [0.3, 1], "alignment", "top-left", "margin_top", 0.2, "shape", "square-min");
sTimePFC_DM = cellfun(@(x) replaceVal(x, inf), sTimePFC_DM);
while any(isinf(sTimePFC_DM))
    for tIndex = 1:length(sTimePFC_DM)
        if isinf(sTimePFC_DM(tIndex))
            idx = cellfun(@str2double, neighbours(tIndex).neighblabel);
            sTimePFC_DM(tIndex) = mean(sTimePFC_DM(idx(sTimePFC_DM(idx) ~= inf)));
        end
    end
end
plotTopo(sTimePFC_DM);
title('DM in PFC' , 'FontSize', 12, 'FontWeight', 'bold');
colorbar("Position", [0.265, 0.12, 0.01, 0.3]);
hold on;
plotLayout(gca, (monkeyID - 1) * 2 + 2, 0.4);

mSubplot(2, 1, 2, [0.3, 1], "alignment", "top-center", "margin_top", 0.2, "shape", "square-min");
sTimePFC_PE = cellfun(@(x) replaceVal(x, inf), sTimePFC_PE);
while any(isinf(sTimePFC_PE))
    for tIndex = 1:length(sTimePFC_PE)
        if isinf(sTimePFC_PE(tIndex))
            idx = cellfun(@str2double, neighbours(tIndex).neighblabel);
            sTimePFC_PE(tIndex) = mean(sTimePFC_PE(idx(sTimePFC_PE(idx) ~= inf)));
        end
    end
end
plotTopo(sTimePFC_PE);
title('PE in PFC' , 'FontSize', 12, 'FontWeight', 'bold');
scaleAxes("c", [0, inf]);
colorbar("Position", [0.6, 0.12, 0.01, 0.3]);
hold on;
plotLayout(gca, (monkeyID - 1) * 2 + 2, 0.4);

mSubplot(2, 1, 2, [0.3, 1], "alignment", "top-right", "margin_top", 0.2, "shape", "square-min");
diffTimePFC = sTimePFC_DM - sTimePFC_PE;
plotTopo(diffTimePFC);
scaleAxes(gca, "c", "symOpts", "max");
title('DM - PE' , 'FontSize', 12, 'FontWeight', 'bold');
colorbar("Position", [0.935, 0.12, 0.01, 0.3]);
hold on;
plotLayout(gca, (monkeyID - 1) * 2 + 2, 0.4);
colormap(flip(colormap('jet')));

mPrint(gcf, [MONKEYPATH, 'PFC_PE&DM_Topo.jpg'], "-djpeg", "-r600");