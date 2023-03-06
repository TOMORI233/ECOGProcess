%% DRP
try
    load([MONKEYPATH, AREANAME, '_DRP'], 'resDP');
catch
    edge = 0:step:windowDM(2) - binSize;
    for wIndex = 1:length(edge)
        tic;
        idx = fix((edge(wIndex) - windowDM(1)) / 1000 * fs + 1):fix((edge(wIndex) - windowDM(1) + binSize) / 1000 * fs);
        tc = changeCellRowNum(cellfun(@(x) sum(x(:, idx), 2), resultC, "UniformOutput", false));
        tw = changeCellRowNum(cellfun(@(x) sum(x(:, idx), 2), resultW, "UniformOutput", false));
        tc = cellfun(@(x) [x, ones(length(x), 1)], tc, "UniformOutput", false);
        tw = cellfun(@(x) [x, zeros(length(x), 1)], tw, "UniformOutput", false);
        data = cellfun(@(x, y) [x; y], tc, tw, "UniformOutput", false);
        temp = cellfun(@(x) DPcal(x, nIter), data, "UniformOutput", false);
        resDP(wIndex, 1).v = cellfun(@(x) x.value, temp);
        resDP(wIndex, 1).p = cellfun(@(x) x.p, temp);
        resDP(wIndex, 1).window = [edge(wIndex), edge(wIndex) + binSize];
        toc;
        disp(['[', num2str(edge(wIndex)), ' ', num2str(edge(wIndex) + binSize), '] done']);
    end
    mSave([MONKEYPATH, AREANAME, '_DRP.mat'], "resDP");
end

FigDRP = figure;
maximizeFig(FigDRP);
sz = 80;
for cIndex = 1:length(channels)
    mAxe = mSubplot(FigDRP, 8, 8, cIndex, 1, margins, paddings);
    hold(mAxe, "on");
    V_s = [];
    W_s = [];
    V_ns = [];
    W_ns = [];
    for wIndex = 1:length(resDP)
        if resDP(wIndex).p(cIndex) < alpha
            V_s = [V_s; resDP(wIndex).v(cIndex)];
            W_s = [W_s; mean(resDP(wIndex).window)];
        else
            V_ns = [V_ns; resDP(wIndex).v(cIndex)];
            W_ns = [W_ns; mean(resDP(wIndex).window)];
        end
    end
    scatter(W_s, V_s, sz, "black", "filled");
    scatter(W_ns, V_ns, sz, "black");
    X = cellfun(@mean, {resDP.window});
    Y = cellfun(@(x) x(cIndex), {resDP.v});
    plot(X, Y, "k", "LineWidth", 1);

    if ~ismember(cIndex, badCHs)
        title(['CH ', num2str(cIndex), ' | p<', num2str(alpha)]);
    else
        title(['CH ', num2str(cIndex), ' | p<', num2str(alpha), ' (bad)']);
    end

    if cIndex < 57
        xticklabels('');
    end
end
scaleAxes(FigDRP, "y");
lines = struct("Y", 0.5);
addLines2Axes(FigDRP, lines);
mPrint(FigDRP, [MONKEYPATH, AREANAME, '_DM_DRP.jpg'], "-djpeg", "-r600");

P = [resDP.p];
DRP = [resDP.v];
DMI = chData(1).chMean - chData(2).chMean;
mSave([MONKEYPATH, AREANAME, '_DM_tuning.mat'], "windowDM", "DMI", "DRP", "stat", "V0", "chIdx", "mask", "P");