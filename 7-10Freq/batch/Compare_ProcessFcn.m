function Compare_ProcessFcn(params)
close all;
parseStruct(params);

tuningPE_AC  = load(DATAPATH{1});
tuningPE_PFC = load(DATAPATH{2});
tuningDM_AC  = load(DATAPATH{3});
tuningDM_PFC = load(DATAPATH{4});

mkdir(MONKEYPATH);

windowView = 600; % ms
timeLim = 400; % ms

fs = 500; % Hz
neighbours = mPrepareNeighbours;

windowPE = tuningPE_AC.windowPE;
windowDM = tuningDM_AC.windowDM;
tPE = linspace(windowPE(1), windowPE(2), size(tuningPE_AC.V0, 2));
tDM = linspace(windowDM(1), windowDM(2), size(tuningDM_AC.V0, 2));

idxAC_PE  = tuningPE_AC.chIdx;
idxAC_DM  = tuningDM_AC.chIdx;
maskAC_PE = -1 * (tuningPE_AC.PEI(idxAC_PE, :) < 0) + 1 * (tuningPE_AC.PEI(idxAC_PE, :) >= 0);
resultAC_PE_V = mMapminmax(tuningPE_AC.V0 (idxAC_PE, :), 1) .* maskAC_PE;
resultAC_PEI  = mMapminmax(tuningPE_AC.PEI(idxAC_PE, :), 1);
resultAC_DM_V = mMapminmax(tuningDM_AC.V0 (idxAC_DM, :), 1);
resultAC_DMI  = mMapminmax(tuningDM_AC.DMI(idxAC_DM, :), 1);

idxPFC_PE  = tuningPE_PFC.chIdx;
idxPFC_DM  = tuningDM_PFC.chIdx;
maskPFC_PE = -1 * (tuningPE_PFC.PEI(idxPFC_PE, :) < 0) + 1 * (tuningPE_PFC.PEI(idxPFC_PE, :) >= 0);
resultPFC_PE_V = mMapminmax(tuningPE_PFC.V0 (idxPFC_PE, :), 1) .* maskPFC_PE;
resultPFC_PEI  = mMapminmax(tuningPE_PFC.PEI(idxPFC_PE, :), 1);
resultPFC_DM_V = mMapminmax(tuningDM_PFC.V0 (idxPFC_DM, :), 1);
resultPFC_DMI  = mMapminmax(tuningDM_PFC.DMI(idxPFC_DM, :), 1);

%% PE vs DM in AC
figure;
maximizeFig;
% p
subplot(1, 2, 1);
imagesc("XData", tDM, "YData", (1:64) - 0.5, "CData", resultAC_DM_V);
hold on;
imagesc("XData", tPE, "YData", (0:-1:-63) - 0.5, "CData", resultAC_PE_V);
ylim([-64, 64]);
xlim([0, windowView]);
plot([0, windowView], [0, 0], 'k-', 'LineWidth', 1.2);
title('Auditory cortex', 'FontSize', 15, 'FontWeight', 'bold');
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
imagesc("XData", tDM, "YData", (1:64) - 0.5, "CData", resultAC_DMI);
hold on;
imagesc("XData", tPE, "YData", (0:-1:-63) - 0.5, "CData", resultAC_PEI);
ylim([-64, 64]);
xlim([0, windowView]);
plot([0, windowView], [0, 0], 'k-', 'LineWidth', 1.2);
title('Auditory cortex', 'FontSize', 15, 'FontWeight', 'bold');
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

mPrint(gcf, [MONKEYPATH, 'AC_PE&DM.jpg'], "-djpeg", "-r600");

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

%% PE in AC vs in PFC
figure;
maximizeFig;
% p
subplot(1, 2, 1);
imagesc("XData", tPE, "YData", (1:64) - 0.5, "CData", resultPFC_PE_V);
hold on;
imagesc("XData", tPE, "YData", (0:-1:-63) - 0.5, "CData", resultAC_PE_V);
ylim([-64, 64]);
xlim([0, windowView]);
plot([0, windowView], [0, 0], 'k-', 'LineWidth', 1.2);
title('Prediction error', 'FontSize', 15, 'FontWeight', 'bold');
yticklabels([]);
xlabel('Time from deviant sound onset (ms)');
scaleAxes(gca, "c", [], [], "max");
cb = colorbar;
cb.Label.String = 'Normalized statistic value';
cb.Label.FontSize = 12;
cb.Label.FontWeight = 'bold';
cb.Label.Rotation = -90;
cb.Label.VerticalAlignment = 'bottom';
text(-50, 29, 'PFC', 'FontSize', 15, 'FontWeight', 'bold', 'Rotation', 90);
text(-50, -29, 'AC', 'FontSize', 15, 'FontWeight', 'bold', 'Rotation', 90);
cm = colormap(gca, 'jet');
cm(127:129, :) = repmat([1 1 1], 3, 1); % white
colormap(gca, cm);

% PEI
subplot(1, 2, 2);
imagesc("XData", tPE, "YData", (1:64) - 0.5, "CData", resultPFC_PEI);
hold on;
imagesc("XData", tPE, "YData", (0:-1:-63) - 0.5, "CData", resultAC_PEI);
ylim([-64, 64]);
xlim([0, windowView]);
plot([0, windowView], [0, 0], 'k-', 'LineWidth', 1.2);
title('Prediction error', 'FontSize', 15, 'FontWeight', 'bold');
yticklabels([]);
xlabel('Time from deviant sound onset (ms)');
scaleAxes(gca, "c", [], [], "max");
cb = colorbar;
cb.Label.String = 'Normalized PEI';
cb.Label.FontSize = 12;
cb.Label.FontWeight = 'bold';
cb.Label.Rotation = -90;
cb.Label.VerticalAlignment = 'bottom';
text(-50, 29, 'PFC', 'FontSize', 15, 'FontWeight', 'bold', 'Rotation', 90);
text(-50, -29, 'AC', 'FontSize', 15, 'FontWeight', 'bold', 'Rotation', 90);
colormap(gca, 'jet');

mPrint(gcf, [MONKEYPATH, 'PE_AC&PFC.jpg'], "-djpeg", "-r600");

%% DM in AC vs in PFC
figure;
maximizeFig;
% p
subplot(1, 2, 1);
imagesc("XData", tDM, "YData", (1:64) - 0.5, "CData", resultPFC_DM_V);
hold on;
imagesc("XData", tDM, "YData", (0:-1:-63) - 0.5, "CData", resultAC_DM_V);
ylim([-64, 64]);
xlim([0, windowView]);
plot([0, windowView], [0, 0], 'k-', 'LineWidth', 1.2);
title('Decision making', 'FontSize', 15, 'FontWeight', 'bold');
yticklabels([]);
xlabel('Time from deviant sound onset (ms)');
scaleAxes(gca, "c", [], [], "max");
cb = colorbar;
cb.Label.String = 'Normalized statistic value';
cb.Label.FontSize = 12;
cb.Label.FontWeight = 'bold';
cb.Label.Rotation = -90;
cb.Label.VerticalAlignment = 'bottom';
text(-50, 29, 'PFC', 'FontSize', 15, 'FontWeight', 'bold', 'Rotation', 90);
text(-50, -29, 'AC', 'FontSize', 15, 'FontWeight', 'bold', 'Rotation', 90);
cm = colormap(gca, 'jet');
cm(127:129, :) = repmat([1 1 1], 3, 1); % white
colormap(gca, cm);

% DMI
subplot(1, 2, 2);
imagesc("XData", tDM, "YData", (1:64) - 0.5, "CData", resultPFC_DMI);
hold on;
imagesc("XData", tDM, "YData", (0:-1:-63) - 0.5, "CData", resultAC_DMI);
ylim([-64, 64]);
xlim([0, windowView]);
plot([0, windowView], [0, 0], 'k-', 'LineWidth', 1.2);
title('Decision making', 'FontSize', 15, 'FontWeight', 'bold');
yticklabels([]);
xlabel('Time from deviant sound onset (ms)');
scaleAxes(gca, "c", [], [], "max");
cb = colorbar;
cb.Label.String = 'Normalized DMI';
cb.Label.FontSize = 12;
cb.Label.FontWeight = 'bold';
cb.Label.Rotation = -90;
cb.Label.VerticalAlignment = 'bottom';
text(-50, 29, 'PFC', 'FontSize', 15, 'FontWeight', 'bold', 'Rotation', 90);
text(-50, -29, 'AC', 'FontSize', 15, 'FontWeight', 'bold', 'Rotation', 90);
colormap(gca, 'jet');

mPrint(gcf, [MONKEYPATH, 'DM_AC&PFC.jpg'], "-djpeg", "-r600");

%% PE vs DM in each channel in AC and PFC
% AC
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
sTimeAC_DM = cellfun(@(x) replaceVal(x, inf), sTimeAC_DM);
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

mSubplot(2, 1, 2, [0.3, 1], "alignment", "top-center", "margin_top", 0.2, "shape", "square-min");
sTimeAC_PE = cellfun(@(x) replaceVal(x, inf), sTimeAC_PE);
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

mSubplot(2, 1, 2, [0.3, 1], "alignment", "top-right", "margin_top", 0.2, "shape", "square-min");
diffTimeAC = sTimeAC_DM - sTimeAC_PE;
plotTopo(diffTimeAC);
title('DM - PE' , 'FontSize', 12, 'FontWeight', 'bold');
scaleAxes(gca, "c", "symOpts", "max");
colorbar("Position", [0.935, 0.12, 0.01, 0.3]);
colormap(flip(colormap('jet')));

mPrint(gcf, [MONKEYPATH, 'AC_PE&DM_Topo.jpg'], "-djpeg", "-r600");

% PFC
figure;
maximizeFig;
mSubplot(2, 2, 1);
sTimePFC_DM = rowFcn(@(x) find(x ~= 0, 1) / fs * 1000, tuningDM_PFC.V0(:, tDM >= 0), "UniformOutput", false);
sTimePFC_PE = rowFcn(@(x) find(x ~= 0, 1) / fs * 1000, tuningPE_PFC.V0(:, tPE >= 0), "UniformOutput", false);
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

mSubplot(2, 1, 2, [0.3, 1], "alignment", "top-right", "margin_top", 0.2, "shape", "square-min");
diffTimePFC = sTimePFC_DM - sTimePFC_PE;
plotTopo(diffTimePFC);
title('DM - PE' , 'FontSize', 12, 'FontWeight', 'bold');
scaleAxes(gca, "c", "symOpts", "max");
colorbar("Position", [0.935, 0.12, 0.01, 0.3]);
colormap(flip(colormap('jet')));

mPrint(gcf, [MONKEYPATH, 'PFC_PE&DM_Topo.jpg'], "-djpeg", "-r600");
