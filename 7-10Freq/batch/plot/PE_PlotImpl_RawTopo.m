%% Tuning topo of raw wave
FigTopo = figure;
maximizeFig(FigTopo);

step = 50;
binSize = 100;
edge = 0:step:650 - binSize;
tuning = cell(length(chData), length(edge)); % row-dRatio, col-edge number
tuningMean = cell(length(edge), 1);
tuningSE = cell(length(edge), 1);
tuningSlope = zeros(numel(channels), length(edge));

P = zeros(numel(channels), length(edge));

subplotNumDiff = [1:6, 13:18];
subplotNumP = [7:12, 19:24];

for wIndex = 1:length(edge)
    windowT = [edge(wIndex), edge(wIndex) + binSize];
    tT = linspace(windowT(1), windowT(2), fix((windowT(2) - windowT(1)) / 1000 * fs));
    idxT = (fix((windowT(1) - windowPE(1)) / 1000 * fs):(fix((windowT(1) - windowPE(1)) / 1000 * fs) + length(tT) - 1)) + 1;

    for dIndex = 1:length(chData)
        tuning{dIndex, wIndex} = cellfun(@(x) mean(x(:, idxT), 2), changeCellRowNum(chData(dIndex).dataNorm), "UniformOutput", false);
        tuningMean{wIndex, 1}(dIndex, :) = cellfun(@mean, tuning{dIndex, wIndex})';
        tuningSE{wIndex, 1}(dIndex, :) = cellfun(@(x) SE(x, 1), tuning{dIndex, wIndex})';
    end

    % tuning value
    mAxesDiff(wIndex) = mSubplot(FigTopo, 4, 6, subplotNumDiff(wIndex), 1, "paddings", paddings, "shape", "square-min");
    tuningSlope(:, wIndex) = (tuningMean{wIndex}(end, :) - tuningMean{wIndex}(2, :))';
    plotTopo(tuningSlope(:, wIndex), "contourOpt", "on");
    hold on;
    plotLayout(gca, (monkeyID - 1) * 2 + posIndex, 0.4);
    title(mAxesDiff(wIndex), ['PEI topo [', num2str(windowT(1)), ' ', num2str(windowT(2)), ']']);

    % p
    mAxesP(wIndex) = mSubplot(FigTopo, 4, 6, subplotNumP(wIndex), 1, "paddings", paddings, "shape", "square-min");
    P(:, wIndex) = cellfun(@(x1, x2, x3, x4) anova1([x1; x2; x3; x4], [ones(length(x1), 1); 2 * ones(length(x2), 1); 3 * ones(length(x3), 1); 4 * ones(length(x4), 1)], "off"), tuning{2, wIndex}, tuning{3, wIndex}, tuning{4, wIndex}, tuning{5, wIndex});
    temp = log(P(:, wIndex) / alpha) / log(alpha_log);
    plotTopo(temp, "contourOpt", "on");
    hold on;
    plotLayout(gca, (monkeyID - 1) * 2 + posIndex, 0.4);
    title(mAxesP(wIndex), ['p topo [', num2str(edge(wIndex)), ' ', num2str(edge(wIndex) + binSize), ']']);
    colormap(mAxesP(wIndex), cmSig);
end
scaleAxes(mAxesDiff, "c", "symOpts", "max");
scaleAxes(mAxesP, "c", "symOpts", "max", "cutoffRange", [-2, 2]);
cb1 = colorbar(mAxesDiff(end), 'position', [0.95, 0.1, 0.01, 0.8]);
cb1.Label.String = "Tuning difference between ratio 1.08 & 1.02";
cb1.Label.FontSize = 15;
cb1.Label.VerticalAlignment = 'bottom';
cb1.Label.Rotation = -90;
cb2 = colorbar(mAxesP(end), 'position', [0.05, 0.1, 0.01, 0.8]);
cb2.Label.String = ['ANOVA p=log_{', num2str(alpha_log), '}(p/', num2str(alpha), ')'];
cb2.Label.FontSize = 15;

setAxes(FigTopo, "visible", "off");
mPrint(FigTopo, [MONKEYPATH, AREANAME, '_PE_Topo.jpg'], "-djpeg", "-r600");
PEI = chData(end).chMean - chData(2).chMean;
mSave([MONKEYPATH, AREANAME, '_PE_tuning.mat'], "windowPE", "PEI", "tuningSlope", "V0", "chIdx", "mask", "P");