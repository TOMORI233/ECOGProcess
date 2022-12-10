%% PE
clear; close all; clc;

%% Parameter settings
monkeyID = 1; % 1-CC, 2-XX

AREANAME = 'AC';
% AREANAME = 'PFC';

AREANAMEs = ["AC", "PFC"];
params.posIndex = find(AREANAMEs == AREANAME); % 1-AC, 2-PFC
params.choiceWin = [100, 600];
params.processFcn = @ActiveProcess_7_10Freq;
alpha = 0.01; % For ANOVA
margins = [0.05, 0.05, 0.1, 0.1];
paddings = [0.1, 0.1, 0.01, 0.01];
colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

if monkeyID == 1
    ROOTPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\CC\7-10Freq Active\';
    DATESTRs = {'cc20220520', 'cc20220706', 'cc20220801', 'cc20221014', 'cc20221015'};
    MONKEYPATH = 'CC\PE\';
    PrePATH = 'CC\Preprocess\';
elseif monkeyID == 2
    ROOTPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\XX\7-10Freq Active\';
    DATESTRs = {'xx20220711', 'xx20220720', 'xx20220812', 'xx20220820', 'xx20220822', 'xx20220913'};
    MONKEYPATH = 'XX\PE\';
    PrePATH = 'XX\Preprocess\';
else
    error("Invalid monkey ID");
end

mkdir(MONKEYPATH);
mkdir(PrePATH);
badCHs = [];

try
    load([MONKEYPATH, AREANAME, '_PE_Data.mat']);
catch

    for index = 1:length(DATESTRs)
        MATPATHs{index, 1} = [ROOTPATH, DATESTRs{index}, '\', DATESTRs{index}, '_', AREANAME];
    end

    %% Load
    windowPE = [-500, 800];
    windowICA = [-2000, 1000];
    trialsECOG = [];
    trialAll = [];

    try
        idxAC = load([PrePATH, 'AC_excludeIdx']);
        idxPFC = load([PrePATH, 'PFC_excludeIdx']);
        excludeIdxAll = cellfun(@(x, y) [x, y], idxAC.excludeIdx, idxPFC.excludeIdx, "UniformOutput", false);
    end

    for mIndex = 1:length(MATPATHs)
        [trialAll_temp, ECOGDataset] = ECOGPreprocess(MATPATHs{mIndex}, params);
        trials = trialAll_temp(~[trialAll_temp.interrupt]);
        trialsECOG_temp = selectEcog(ECOGDataset, trials, "dev onset", windowICA);
        if ~exist("excludeIdxAll", "var")
            excludeIdx{mIndex} = excludeTrials(trialsECOG_temp);
        else
            excludeIdx = excludeIdxAll;
        end
        trials(excludeIdx{mIndex}) = [];
        trialsECOG_temp(excludeIdx{mIndex}) = [];
        trialAll = [trialAll; trials];
        trialsECOG = [trialsECOG; trialsECOG_temp];
    end

    save([PrePATH, AREANAME, '_excludeIdx'], "excludeIdx");

    fs = ECOGDataset.fs;
    channels = ECOGDataset.channels;

    %% ICA
    try
        load([PrePATH, AREANAME, '_ICA'], "-mat", "comp", "ICs");
    catch
        [comp, ICs, FigTopoICA] = ICA_Population(trialsECOG, fs, windowICA);
        print(FigTopoICA, strcat(PrePATH, AREANAME, "_Topo_ICA"), "-djpeg", "-r400");
        save([PrePATH, AREANAME, '_ICA.mat'], "comp", "ICs");
    end

    trialsECOG = trialsECOG([trialAll.correct]);
    trialAll = trialAll([trialAll.correct]);
    startIdx = fix((windowPE(1) - windowICA(1)) / 1000 * fs);
    endIdx = fix((windowPE(2) - windowICA(1)) / 1000 * fs);
    trialsECOG = cellfun(@(x) x(:, startIdx:endIdx), trialsECOG, "UniformOutput", false);
    trialsECOG = reconstructData(trialsECOG, comp, ICs);

    [dRatioAll, dRatio] = computeDevRatio(trialAll);
    save([MONKEYPATH, AREANAME, '_PE_Data.mat'], "windowPE", "trialsECOG", "dRatioAll", "dRatio", "fs", "channels", "-mat");
end

for dIndex = 1:length(dRatio)
    chData(dIndex).chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(trialsECOG(dRatioAll == dRatio(dIndex))), "UniformOutput", false));
    chData(dIndex).chStd = cell2mat(cellfun(@(x) std(x, [], 1), changeCellRowNum(trialsECOG(dRatioAll == dRatio(dIndex))), "UniformOutput", false));
    chData(dIndex).dataNorm = cellfun(@(x) x - chData(1).chMean, trialsECOG(dRatioAll == dRatio(dIndex)), "UniformOutput", false);
    chData(dIndex).color = colors{dIndex};
end

%% Multiple comparison
t = linspace(windowPE(1), windowPE(2), size(trialsECOG{1}, 2))';

try 
    load([MONKEYPATH, AREANAME, '_PE_CBPT'], "stat", "-mat");
catch
    data = [];
    pool = 2:5;
    for dIndex = 1:length(pool)
        temp = trialsECOG(dRatioAll == dRatio(pool(dIndex)));
        % time 1*nSample
        data(dIndex).time = t' / 1000;
        % label nCh*1 cell
        data(dIndex).label = cellfun(@(x) num2str(x), num2cell(channels)', 'UniformOutput', false);
        % trial nTrial*nCh*nSample
        data(dIndex).trial = cell2mat(cellfun(@(x) permute(x, [3, 1, 2]), temp, "UniformOutput", false));
        % trialinfo nTrial*1
        data(dIndex).trialinfo = repmat(dIndex, [length(temp), 1]);
    end
    
    stat = CBPT(data);
    save([MONKEYPATH, AREANAME, '_PE_CBPT.mat'], "stat", "-mat");
end

p = stat.stat;
mask = stat.mask;
V0 = p .* mask;
windowSortCh = [0, 200];
tIdx = fix((windowSortCh(1) - windowPE(1)) / 1000 * fs) + 1:fix((windowSortCh(2) - windowPE(1)) / 1000 * fs);
[~, chIdx] = sort(sum(V0(:, tIdx), 2), 'descend');
V = V0(chIdx, :);

figure;
maximizeFig;
mSubplot(1, 1, 1, 1, [0, 0, 0, 0], [0.03, 0.01, 0.06, 0.03]);
imagesc("XData", t, "YData", channels, "CData", V);
xlim([0, windowPE(2)]);
ylim([0.5, 64.5]);
yticks(channels);
yticklabels(num2str(channels(chIdx)'));
cm = colormap('jet');
cm(127:129, :) = repmat([1 1 1], [3, 1]);
colormap(cm);
title('F-value of comparison among 4 deviant frequency ratio in all channels (significant)');
ylabel('Ranked channels');
xlabel('Time (ms)');
cb = colorbar;
cb.Label.String = '\bf{{\it{F}}-value}';
cb.Label.Interpreter = 'latex';
cb.Label.FontSize = 12;
cb.Label.Position = [2.5, 0];
cb.Label.Rotation = -90;
cRange = scaleAxes(gcf, "c", [], [], "max");

%% Raw
t = linspace(windowPE(1), windowPE(2), size(trialsECOG{1}, 2))';
FigPE = plotRawWaveMulti(chData(2:end), windowPE);
scaleAxes(FigPE, "x", [0, windowPE(2)]);
yRange = scaleAxes(FigPE);
setAxes(FigPE, "visible", "off");
mAxes = findobj(FigPE, "Type", "axes");
plotLayout(FigPE, (monkeyID - 1) * 2 + params.posIndex, 0.4);
% print(FigPE, [MONKEYPATH, AREANAME, '_PE_Wave.jpg'], "-djpeg", "-r600");

nCh = length(channels);
for cIndex = 1:nCh
    tTemp = t;
    a = V0(cIndex, :);
    a(V0(cIndex, :) > 0) = yRange(2);
    a(V0(cIndex, :) == 0) = [];
    tTemp(V0(cIndex, :) == 0) = [];
    plot(mAxes(nCh - cIndex + 1), tTemp, a, "Color", [128 128 128]/255, "Marker", "square", "MarkerSize", 5, "MarkerFaceColor", [128 128 128]/255, "LineStyle", "none");
end

%% Topo-tuning & p
FigTopo = figure;
maximizeFig(FigTopo);

topoSize = [8, 8];
N = 5;
step = 50;
binSize = 100;
edge = 0:step:650 - binSize;
tuning = cell(length(chData), length(edge)); % row-dRatio, col-edge number
tuningMean = cell(length(edge), 1);
tuningSE = cell(length(edge), 1);
tuningSlope = zeros(nCh, length(edge));

P = zeros(nCh, length(edge));

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
    tuningSlope(badCHs, wIndex) = 0;
    plotTopo(tuningSlope(:, wIndex), "contourOpt", "off");
%     plotLayout(mAxesDiff(wIndex), 2 * (monkeyID - 1) + params.posIndex);
    title(mAxesDiff(wIndex), ['Predictive error topo [', num2str(windowT(1)), ' ', num2str(windowT(2)), ']']);

    % p
    mAxesP(wIndex) = mSubplot(FigTopo, 4, 6, subplotNumP(wIndex), 1, "paddings", paddings, "shape", "square-min");
    P(:, wIndex) = cellfun(@(x1, x2, x3, x4) anova1([x1; x2; x3; x4], [ones(length(x1), 1); 2 * ones(length(x2), 1); 3 * ones(length(x3), 1); 4 * ones(length(x4), 1)], "off"), tuning{2, wIndex}, tuning{3, wIndex}, tuning{4, wIndex}, tuning{5, wIndex});
    temp = log(P(:, wIndex) / alpha) / log(alpha);
    temp(badCHs) = 0;
    plotTopo(temp, "contourOpt", "off");
%     plotLayout(mAxesP(wIndex), 2 * (monkeyID - 1) + params.posIndex);
    title(mAxesP(wIndex), ['p topo [', num2str(edge(wIndex)), ' ', num2str(edge(wIndex) + binSize), '] | p=log_{', num2str(alpha), '}(p/', num2str(alpha), ')']);
end
scaleAxes(mAxesDiff, "c", [], [], "max");
scaleAxes(mAxesP, "c", [], [-2, 2], "max");
cb1 = colorbar(mAxesDiff(end), 'position', [0.95, 0.1, 0.01, 0.8]);
cb1.Label.String = "Tuning difference between ratio 1.08 & 1.02";
cb1.Label.FontSize = 15;
cb1.Label.VerticalAlignment = 'bottom';
cb1.Label.Rotation = -90;
cb2 = colorbar(mAxesP(end), 'position', [0.05, 0.1, 0.01, 0.8]);
cb2.Label.String = ['ANOVA p=log_{', num2str(alpha), '}(p/', num2str(alpha), ')'];
cb2.Label.FontSize = 15;
setAxes(FigTopo, "visible", "off");
print(FigTopo, [MONKEYPATH, AREANAME, '_PE_Topo.jpg'], "-djpeg", "-r600");
PEI = chData(end).chMean - chData(2).chMean;
save([MONKEYPATH, AREANAME, '_PE_tuning.mat'], "windowPE", "PEI", "tuningSlope", "V0", "chIdx", "mask", "P", "-mat");

%% Example
ch = input('Input example channel: ');
t = linspace(windowPE(1), windowPE(2), size(trialsECOG{1}, 2))';
FigExampleWave = plotRawWaveMulti(chData, windowPE, '', [1, 1], ch);
scaleAxes(FigExampleWave, "x", [0, 800]);
yRange = scaleAxes(FigExampleWave, "y");
a = ones(length(t), 1) * (-100);
a(V0(ch, :) > 0) = yRange(2);
% a(V(ch, :) > 0) = 30;
resultWave = [t, ...
              chData(1).chMean(ch, :)', ...
              chData(2).chMean(ch, :)', ...
              chData(3).chMean(ch, :)', ...
              chData(4).chMean(ch, :)', ...
              chData(5).chMean(ch, :)', ...
              a];
a(V0(ch, :) == 0) = [];
t(V0(ch, :) == 0) = [];
hold on;
plot(t, a, "Color", [128 128 128]/255, "Marker", "square", "MarkerSize", 10, "MarkerFaceColor", [128 128 128]/255);

resultTuning = cellfun(@(x, y) [x(:, ch), y(:, ch)], tuningMean, tuningSE, "UniformOutput", false);
figure;
maximizeFig;
for wIndex = 1:length(resultTuning)
    mSubplot(3, 4, wIndex, 1, margins, paddings);
    errorbar(resultTuning{wIndex}(:, 1), resultTuning{wIndex}(:, 2), "k-", "LineWidth", 1);
    title(['[', num2str(edge(wIndex)), ', ', num2str(edge(wIndex) + binSize), '] | p=', num2str(P(ch, wIndex))]);
    xlim([0.5, 5.5]);
    xticks(1:5);
    xticklabels(num2str(dRatio'));
end
scaleAxes;