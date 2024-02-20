ccc;

%%
windowNew = [0, 500];
fRange = [0, 70];

%%
MATPATHs = dir("F:\Lab\Projects\ECOG\Granger Causality\DATA\std\granger result\*.mat");

temp = arrayfun(@(x) split(x.name, '_'), MATPATHs, "UniformOutput", false);
temp = cellfun(@(x) x(2), temp, "UniformOutput", false);
temp = cellfun(@(x) split(x, '-'), temp, "UniformOutput", false);
temp = cellfun(@(x) str2double(x{2}), temp);
chsAC = unique(temp);

temp = arrayfun(@(x) split(x.name, '_'), MATPATHs, "UniformOutput", false);
temp = cellfun(@(x) obtainArgoutN(@fileparts, 2, x(3)), temp, "UniformOutput", false);
temp = cellfun(@(x) split(x, '-'), temp, "UniformOutput", false);
temp = cellfun(@(x) str2double(x{2}), temp);
chsPFC = unique(temp);

AC2PFC = zeros(length(chsAC), length(chsPFC));
PFC2AC = zeros(length(chsPFC), length(chsAC));

%%
% AC as seed
for cIndexAC = 1:length(chsAC)
    close all force;

    PATHs = dir(['F:\Lab\Projects\ECOG\Granger Causality\DATA\std\granger result\grangerres_AC-', num2str(chsAC(cIndexAC)), '_*.mat']);
    data = arrayfun(@(x) load(fullfile(x.folder, x.name)).res, PATHs);
    f = data(1).freq;
    t = data(1).time;
    coi = data(1).coi;

    tIdx = find(t >= windowNew(1), 1):find(t >= windowNew(2), 1);
    fIdx = find(f <= fRange(2), 1):find(f >= fRange(1), 1, "last");
    t = t(tIdx);
    f = f(fIdx);

    grangerspctrm = cat(1, data.grangerspctrm);
    channelcmb = cat(1, data.channelcmb);

    temp = cellfun(@(x) split(x, '-'), channelcmb, "UniformOutput", false);
    temp = cellfun(@(x) str2double(x{2}), temp);

    % AC as source
    [~, idx] = sort(temp(1:2:end, 2), "ascend");
    grangerspctrmAC = grangerspctrm(1:2:end, :, :);
    grangerspctrmAC = grangerspctrmAC(idx, :, :);
    channelcmbAC = channelcmb(1:2:end, :);
    channelcmbAC = channelcmbAC(idx, :);

    AC2PFC(cIndexAC, :) = mean(grangerspctrmAC(:, fIdx, tIdx), [2, 3]);

    % PFC as source
    [~, idx] = sort(temp(2:2:end, 1), "ascend");
    grangerspctrmPFC = grangerspctrm(2:2:end, :, :);
    grangerspctrmPFC = grangerspctrmPFC(idx, :, :);
    channelcmbPFC = channelcmb(2:2:end, :);
    channelcmbPFC = channelcmbPFC(idx, :);

    PFC2AC(:, cIndexAC) = mean(grangerspctrmPFC(:, fIdx, tIdx), [2, 3]);
end

%%
figure;
maximizeFig;
mSubplot(1, 1, 1, "shape", "square-min");
imagesc("XData", 1:64, "YData", 1:64, "CData", AC2PFC');
set(gca, "XLimitMethod", "tight");
set(gca, "YLimitMethod", "tight");
xticklabels('');
yticklabels('');
xlabel('From AC', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('To PFC', 'FontSize', 12, 'FontWeight', 'bold');
title('GC matrix', 'FontSize', 12, 'FontWeight', 'bold');
set(gca, "Box", "on");
set(gca, "BoxStyle", "full");
set(gca, "LineWidth", 3);
scaleAxes("c", "on");
colorbar;
colormap('jet');

%%
AC2PFC_topo_AC = mean(AC2PFC, 2);
AC2PFC_topo_PFC = mean(AC2PFC, 1);

PFC2AC_topo_AC = mean(PFC2AC, 1);
PFC2AC_topo_PFC = mean(PFC2AC, 2);

figure;
maximizeFig;
mAxes(1) = mSubplot(2, 2, 1, "shape", "square-min");
plotTopo(AC2PFC_topo_AC);
title('AC topo | From AC to PFC', 'FontSize', 12, 'FontWeight', 'bold');
plotLayout(gca, 1);

mAxes(2) = mSubplot(2, 2, 2, "shape", "square-min");
plotTopo(PFC2AC_topo_AC);
title('AC topo | From PFC to AC', 'FontSize', 12, 'FontWeight', 'bold');
plotLayout(gca, 1);

mAxes(3) = mSubplot(2, 2, 3, "shape", "square-min");
plotTopo(AC2PFC_topo_PFC);
title('PFC topo', 'FontSize', 12, 'FontWeight', 'bold');
plotLayout(gca, 2);

mAxes(4) = mSubplot(2, 2, 4, "shape", "square-min");
plotTopo(PFC2AC_topo_PFC);
title('PFC topo', 'FontSize', 12, 'FontWeight', 'bold');
plotLayout(gca, 2);

scaleAxes(mAxes, "c", "on");
cb = colorbar(mAxes(end), 'position', [0.9, 0.1, 0.015, 0.8]);
cb.Label.String = 'Granger spectrum';
cb.Label.FontSize = 15;
cb.Label.FontWeight = 'bold';
cb.Label.Rotation = -90;
cb.Label.VerticalAlignment = 'bottom';
colormap('jet');
