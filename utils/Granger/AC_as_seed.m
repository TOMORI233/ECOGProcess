ccc;

MATPATHs = dir("std\granger result\*.mat");
SAVEROOTPATH = 'std\Figures';
temp = arrayfun(@(x) split(x.name, '_'), MATPATHs, "UniformOutput", false);
temp = cellfun(@(x) x(2), temp, "UniformOutput", false);
temp = cellfun(@(x) split(x, '-'), temp, "UniformOutput", false);
temp = cellfun(@(x) str2double(x{2}), temp);
chsAC = unique(temp);

mkdir(SAVEROOTPATH);

% AC as seed
for cIndexAC = 1:length(chsAC)
    close all force;

    PATHs = dir(['std\granger result\grangerres_AC-', num2str(chsAC(cIndexAC)), '_*.mat']);
    data = arrayfun(@(x) load(fullfile(x.folder, x.name)).res, PATHs);
    f = data(1).freq;
    t = data(1).time;
    coi = data(1).coi;

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

    Fig = figure;
    maximizeFig;
    plotSize = autoPlotSize(size(channelcmbAC, 1));
    for index = 1:size(channelcmbAC, 1)
        mSubplot(plotSize(1), plotSize(2), index, "margins", [0.05, 0.05, 0.08, 0.08], "paddings", [0.02, 0.05, 0.02, 0.02]);
        imagesc("XData", t, "YData", f(1:end - 1), "CData", squeeze(grangerspctrmAC(index, 1:end - 1, :)));
        set(gca, "YScale", "log");
        yticks([0, 2.^(0:nextpow2(max(f)) - 1)]);
        set(gca, "XLimitMethod", "tight");
        set(gca, "YLimitMethod", "tight");
        title(['From ', channelcmbAC{index, 1}, ' to ', channelcmbAC{index, 2}]);
    end
    colormap('jet');
    scaleAxes("c", "on");
    scaleAxes("y", [f(end - 1), 70]);
    addLines2Axes(struct("X", {0; t}, "Y", {[]; coi}, "color", "w", "width", 1.5));
    colorbar('position', [0.96, 0.1, 0.5 * 0.03, 0.8]);
    mPrint(Fig, fullfile(SAVEROOTPATH, ['From seed AC-', num2str(chsAC(cIndexAC)), ' to target PFC-all.jpg']), "-djpeg", "-r200");

    % PFC as source
    [~, idx] = sort(temp(2:2:end, 1), "ascend");
    grangerspctrmPFC = grangerspctrm(2:2:end, :, :);
    grangerspctrmPFC = grangerspctrmPFC(idx, :, :);
    channelcmbPFC = channelcmb(2:2:end, :);
    channelcmbPFC = channelcmbPFC(idx, :);

    Fig = figure;
    maximizeFig;
    plotSize = autoPlotSize(size(channelcmbPFC, 1));
    for index = 1:size(channelcmbPFC, 1)
        mSubplot(plotSize(1), plotSize(2), index, "margins", [0.05, 0.05, 0.08, 0.08], "paddings", [0.02, 0.05, 0.02, 0.02]);
        imagesc("XData", t, "YData", f(1:end - 1), "CData", squeeze(grangerspctrmPFC(index, 1:end - 1, :)));
        set(gca, "YScale", "log");
        yticks([0, 2.^(0:nextpow2(max(f)) - 1)]);
        set(gca, "XLimitMethod", "tight");
        set(gca, "YLimitMethod", "tight");
        title(['From ', channelcmbPFC{index, 1}, ' to ', channelcmbPFC{index, 2}]);
    end
    colormap('jet');
    scaleAxes("c", "on");
    scaleAxes("y", [f(end - 1), 70]);
    addLines2Axes(struct("X", {0; t}, "Y", {[]; coi}, "color", "w", "width", 1.5));
    colorbar('position', [0.96, 0.1, 0.5 * 0.03, 0.8]);
    mPrint(Fig, fullfile(SAVEROOTPATH, ['From target PFC-all to seed AC-', num2str(chsAC(cIndexAC)), '.jpg']), "-djpeg", "-r200");
end
