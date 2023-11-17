%% PE vs DM in each channel in AC
figure;
maximizeFig;
mSubplot(2, 2, 1);
sTimeAC_DM = rowFcn(@(x) find(x ~= 0, 1) / fs * 1000, tuningDM_AC.V0(:, tDM >= 0), "UniformOutput", false);
sTimeAC_PE = rowFcn(@(x) find(x ~= 0, 1) / fs * 1000, tuningPE_AC.V0(:, tPE >= 0), "UniformOutput", false);
channels = (1:length(idxAC_DM))';
chIdxDM = cellfun(@(x) ~isempty(x) && x < timeLim, sTimeAC_DM);
chIdxPE = cellfun(@(x) ~isempty(x) && x < timeLim, sTimeAC_PE);
sTimeAC_DM(~chIdxDM) = {[]};
sTimeAC_PE(~chIdxPE) = {[]};
plot(channels(chIdxDM), cell2mat(sTimeAC_DM'), 'b.-', 'LineWidth', 1.5, 'MarkerSize', 15, 'DisplayName', 'DM');
hold on;
plot(channels(chIdxPE), cell2mat(sTimeAC_PE'), 'r.-', 'LineWidth', 1.5, 'MarkerSize', 15, 'DisplayName', 'PE');
xlim([0, max(channels) + 1]);
xlabel('Channel Number', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Time (ms)', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'northwest');
title('Time of the first significant sample in AC' , 'FontSize', 12, 'FontWeight', 'bold');
lines = [];
lines(1).Y = min(cell2mat(sTimeAC_DM'));
lines(1).color = 'b';
lines(2).Y = min(cell2mat(sTimeAC_PE'));
lines(2).color = 'r';
addLines2Axes(gca, lines);

mSubplot(2, 2, 2);
diffTimeAC = cellfun(@(x, y) y - x, sTimeAC_PE, sTimeAC_DM, "UniformOutput", false);
histogram(cell2mat(diffTimeAC'), 'FaceColor', [0.5 0.5 0.5], 'BinWidth', 25);
xlabel('Time (ms)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Count', 'FontSize', 12, 'FontWeight', 'bold');
title('DM - PE' , 'FontSize', 12, 'FontWeight', 'bold');
lines = [];
lines.X = 0;
addLines2Axes(gca, lines);

mSubplot(2, 1, 2, [0.3, 1], "alignment", "top-left", "margin_top", 0.2, "shape", "square-min");
sTimeAC_DM = cellfun(@(x) replaceVal(x, inf, @isempty), sTimeAC_DM);
while any(isinf(sTimeAC_DM))
    for tIndex = 1:length(sTimeAC_DM)
        if isinf(sTimeAC_DM(tIndex))
            idx = cellfun(@str2double, neighbours(tIndex).neighblabel);
            sTimeAC_DM(tIndex) = mean(sTimeAC_DM(idx(sTimeAC_DM(idx) ~= inf)));
        end
    end
end
plotTopo(sTimeAC_DM);
title('DM in AC' , 'FontSize', 12, 'FontWeight', 'bold');
colorbar("Position", [0.265, 0.12, 0.01, 0.3]);
hold on;
plotLayout(gca, (monkeyID - 1) * 2 + 1, 0.4);

mSubplot(2, 1, 2, [0.3, 1], "alignment", "top-center", "margin_top", 0.2, "shape", "square-min");
sTimeAC_PE = cellfun(@(x) replaceVal(x, inf, @isempty), sTimeAC_PE);
while any(isinf(sTimeAC_PE))
    for tIndex = 1:length(sTimeAC_PE)
        if isinf(sTimeAC_PE(tIndex))
            idx = cellfun(@str2double, neighbours(tIndex).neighblabel);
            sTimeAC_PE(tIndex) = mean(sTimeAC_PE(idx(sTimeAC_PE(idx) ~= inf)));
        end
    end
end
plotTopo(sTimeAC_PE);
title('PE in AC' , 'FontSize', 12, 'FontWeight', 'bold');
scaleAxes("c", [0, inf]);
colorbar("Position", [0.6, 0.12, 0.01, 0.3]);
hold on;
plotLayout(gca, (monkeyID - 1) * 2 + 1, 0.4);

mSubplot(2, 1, 2, [0.3, 1], "alignment", "top-right", "margin_top", 0.2, "shape", "square-min");
diffTimeAC = sTimeAC_DM - sTimeAC_PE;
plotTopo(diffTimeAC);
title('DM - PE' , 'FontSize', 12, 'FontWeight', 'bold');
scaleAxes(gca, "c", "symOpts", "max");
colorbar("Position", [0.935, 0.12, 0.01, 0.3]);
hold on;
plotLayout(gca, (monkeyID - 1) * 2 + 1, 0.4);
colormap(flip(colormap('jet')));

mPrint(gcf, [MONKEYPATH, 'AC_PE&DM_Topo.jpg'], "-djpeg", "-r600");