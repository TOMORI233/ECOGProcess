function Fig = checkRawWave(trialsECoG, ch, window)
Fig = figure;
maximizeFig(Fig);
for tIndex = 1 : length(trialsECoG)
    t = linspace(window(1), window(2), size(trialsECoG{1}, 2));
    plot(t, trialsECoG{tIndex}(ch, :), "Color", "#AAAAAA", "LineWidth", 0.5); hold on;
end
temp = cellfun(@(x) mean(x), changeCellRowNum(trialsECoG), "UniformOutput", false);
plot(t, temp{ch}, "Color", "red", "LineWidth", 1.5); hold on
end