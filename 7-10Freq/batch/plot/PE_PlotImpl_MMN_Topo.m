%% Tuning topo of MMN
FigTopoMMN = figure;
maximizeFig;
% step = 50;
% binSize = 50;
% edgeMMN = 0:step:windowMMN(2) - binSize;

if params.posIndex == 1 % AC
    edgeMMN = [0, 30, 80, 130, 180, 350, 500];
else % PFC
    edgeMMN = [0, 100, 300, 500];
end

tuningMMN = cell(length(chDataMMN), length(edgeMMN) - 1); % row-dRatio, col-edgeMMN number
tuningMeanMMN = cell(length(edgeMMN) - 1, 1);
tuningSEMMN = cell(length(edgeMMN) - 1, 1);
tuningSlopeMMN = zeros(numel(channels), length(edgeMMN) - 1);

P_MMN = zeros(numel(channels), length(edgeMMN) - 1);

if ceil((length(edgeMMN) - 1) / 2) <= 3
    nCols = length(edgeMMN) - 1;
    nRows = 2;
    subplotNumDiff = 1:nCols;
    subplotNumP = nCols + 1:2 * nCols;
else
    nCols = ceil((length(edgeMMN) - 1) / 2);
    nRows = 4;
    subplotNumDiff = [1:nCols, 2 * nCols + 1:3 * nCols];
    subplotNumP = [nCols + 1:2 * nCols, 3 * nCols + 1:4 * nCols];
end

for wIndex = 1:length(edgeMMN) - 1
    windowT = [edgeMMN(wIndex), edgeMMN(wIndex + 1)];
    tT = linspace(windowT(1), windowT(2), fix((windowT(2) - windowT(1)) / 1000 * fs));
    idxT = (fix(windowT(1) / 1000 * fs):(fix(windowT(1) / 1000 * fs) + length(tT) - 1)) + 1;

    for dIndex = 1:length(chDataMMN)
        tuningMMN{dIndex, wIndex} = cellfun(@(x) mean(x(:, idxT), 2), changeCellRowNum(trialsECOG_MMN(dRatioAll == dRatio(dIndex))), "UniformOutput", false);
        tuningMeanMMN{wIndex, 1}(dIndex, :) = cellfun(@mean, tuningMMN{dIndex, wIndex})';
        tuningSEMMN{wIndex, 1}(dIndex, :) = cellfun(@(x) SE(x, 1), tuningMMN{dIndex, wIndex})';
    end

    % tuning value
    mAxesDiffMMN(wIndex) = mSubplot(FigTopoMMN, nRows, nCols, subplotNumDiff(wIndex), 1, "paddings", paddings, "shape", "square-min");
    tuningSlopeMMN(:, wIndex) = (tuningMeanMMN{wIndex}(end, :) - tuningMeanMMN{wIndex}(2, :))';
    plotTopo(tuningSlopeMMN(:, wIndex), "contourOpt", "on");
    hold on;
    plotLayout(gca, (monkeyID - 1) * 2 + posIndex, 0.4);
    title(mAxesDiffMMN(wIndex), ['PEI topo [', num2str(windowT(1)), ' ', num2str(windowT(2)), ']']);

    % p
    mAxesPMMN(wIndex) = mSubplot(FigTopoMMN, nRows, nCols, subplotNumP(wIndex), 1, "paddings", paddings, "shape", "square-min");
    P_MMN(:, wIndex) = cellfun(@(x1, x2, x3, x4) anova1([x1; x2; x3; x4], [ones(length(x1), 1); 2 * ones(length(x2), 1); 3 * ones(length(x3), 1); 4 * ones(length(x4), 1)], "off"), tuningMMN{2, wIndex}, tuningMMN{3, wIndex}, tuningMMN{4, wIndex}, tuningMMN{5, wIndex});
    temp = log(P_MMN(:, wIndex) / alpha) / log(alpha_log);
    plotTopo(temp, "contourOpt", "on");
    hold on;
    plotLayout(gca, (monkeyID - 1) * 2 + posIndex, 0.4);
    title(mAxesPMMN(wIndex), ['p topo [', num2str(edgeMMN(wIndex)), ' ', num2str(edgeMMN(wIndex + 1)), ']']);
    colormap(mAxesPMMN(wIndex), cmSig);
end
scaleAxes(mAxesDiffMMN, "c", "symOpts", "max");
scaleAxes(mAxesPMMN, "c", "symOpts", "max", "cutoffRange", [-2, 2]);
cb1 = colorbar(mAxesDiffMMN(end), 'position', [0.95, 0.1, 0.01, 0.8]);
cb1.Label.String = "Tuning difference between ratio 1.08 & 1.02";
cb1.Label.FontSize = 15;
cb1.Label.VerticalAlignment = 'bottom';
cb1.Label.Rotation = -90;
cb2 = colorbar(mAxesPMMN(end), 'position', [0.05, 0.1, 0.01, 0.8]);
cb2.Label.String = ['ANOVA p=log_{', num2str(alpha_log), '}(p/', num2str(alpha), ')'];
cb2.Label.FontSize = 15;

setAxes(FigTopoMMN, "visible", "off");
mPrint(FigTopoMMN, [MONKEYPATH, AREANAME, '_PE_MMN_Topo.jpg'], "-djpeg", "-r600");
PEI_MMN = chDataMMN(end).chMean - chDataMMN(2).chMean;
mSave([MONKEYPATH, AREANAME, '_PE_MMN_tuning.mat'], "windowMMN", "PEI_MMN", "tuningSlopeMMN", "V0_MMN", "chIdxMMN", "maskMMN", "P_MMN");