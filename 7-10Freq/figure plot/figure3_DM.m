%% DM
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
paddings = [0.01, 0.03, 0.01, 0.01];

nIter = 1000; % For DRP
step = 50;
binSize = 100;

if monkeyID == 1
    ROOTPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\CC\7-10Freq Active\';
    DATESTRs = {'cc20220520', 'cc20220706', 'cc20220801', 'cc20221014', 'cc20221015'};
    MONKEYPATH = 'CC\DM\';
    PrePATH = 'CC\Preprocess\';
elseif monkeyID == 2
    ROOTPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\XX\7-10Freq Active\';
    DATESTRs = {'xx20220711', 'xx20220720', 'xx20220812', 'xx20220820', 'xx20220822', 'xx20220913'};
    MONKEYPATH = 'XX\DM\';
    PrePATH = 'XX\Preprocess\';
else
    error("Invalid monkey ID");
end

mkdir(MONKEYPATH);
mkdir(PrePATH);
badCHs = [];

try
    load([MONKEYPATH, AREANAME, '_DM_Data.mat']);
catch

    for index = 1:length(DATESTRs)
        MATPATHs{index, 1} = [ROOTPATH, DATESTRs{index}, '\', DATESTRs{index}, '_', AREANAME];
    end

    %% Load
    windowDM = [-200, 800];
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
        [trialsECOG_temp, ~, ~, sampleinfo_temp] = selectEcog(ECOGDataset, trials, "dev onset", windowICA);
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

    FigB = plotBehaviorOnly(trialAll, "r", "7-10 Freq");
    print(FigB, strcat(MONKEYPATH, "Behavior"), "-djpeg", "-r400");

    fs = ECOGDataset.fs;
    channels = ECOGDataset.channels;
    [dRatioAll, dRatio] = computeDevRatio(trialAll);

    %% ICA
    load([PrePATH, AREANAME, '_ICA'], "-mat", "comp", "ICs");

    startIdx = fix((windowDM(1) - windowICA(1)) / 1000 * fs);
    endIdx = fix((windowDM(2) - windowICA(1)) / 1000 * fs);
    trialsECOG = cellfun(@(x) x(:, startIdx:endIdx), trialsECOG, "UniformOutput", false);
    trialsECOG = reconstructData(trialsECOG, comp, ICs);

    %% Z-score
    resultC = [];
    resultW = [];
    trialsECOG_correct = [];
    trialsECOG_wrong = [];

    for dIndex = 2:4
        trials = trialAll(dRatioAll == dRatio(dIndex));
        result = trialsECOG(dRatioAll == dRatio(dIndex));
        trialsECOG_correct = [trialsECOG_correct; result([trials.correct])];
        trialsECOG_wrong = [trialsECOG_wrong; result(~[trials.correct] & ~[trials.interrupt])];
        result = changeCellRowNum(cellfun(@zscore, changeCellRowNum(result), "UniformOutput", false));
        resultC = [resultC; result([trials.correct])];
        resultW = [resultW; result(~[trials.correct] & ~[trials.interrupt])];
    end

    save([MONKEYPATH, AREANAME, '_DM_Data.mat'], "windowDM", "trialsECOG_correct", "trialsECOG_wrong", "resultC", "resultW", "fs", "channels", "-mat");
end

%% Multiple comparison
t = linspace(windowDM(1), windowDM(2), size(trialsECOG_correct{1}, 2))';

try
    load([MONKEYPATH, AREANAME, '_DM_CBPT'], "stat", "-mat");
catch
    data = [];
    
    data(1).time = t' / 1000;
    data(1).label = cellfun(@(x) num2str(x), num2cell(channels)', 'UniformOutput', false);
    data(1).trial = cell2mat(cellfun(@(x) permute(x, [3, 1, 2]), resultC, "UniformOutput", false));
    data(1).trialinfo = ones(length(resultC), 1);
    
    data(2).time = t' / 1000;
    data(2).label = cellfun(@(x) num2str(x), num2cell(channels)', 'UniformOutput', false);
    data(2).trial = cell2mat(cellfun(@(x) permute(x, [3, 1, 2]), resultW, "UniformOutput", false));
    data(2).trialinfo = 2 * ones(length(resultW), 1);
    
    stat = CBPT(data);
    save([MONKEYPATH, AREANAME, '_DM_CBPT.mat'], "stat", "-mat");
end

p = stat.stat;
mask = stat.mask;
V0 = p .* mask;
windowSortCh = [0, 400];
tIdx = fix((windowSortCh(1) - windowDM(1)) / 1000 * fs) + 1:fix((windowSortCh(2) - windowDM(1)) / 1000 * fs);
[~, chIdx] = sort(sum(abs(V0(:, tIdx)), 2), 'descend');
V = V0(chIdx, :);

figure;
maximizeFig(gcf);
mSubplot(gcf, 1, 1, 1, 1, [0, 0, 0, 0], [0.03, 0.01, 0.06, 0.03]);
imagesc("XData", t, "YData", channels, "CData", V);
xlim([0, windowDM(2)]);
ylim([0.5, 64.5]);
yticks(channels);
yticklabels(num2str(channels(chIdx)'));
cm = colormap('jet');
cm(127:129, :) = repmat([1 1 1], [3, 1]);
colormap(cm);
title('t-value of comparison between correct and wrong trials in all channels (significant)');
ylabel('Ranked channels');
xlabel('Time (ms)');
cb = colorbar;
cb.Label.String = '\bf{{\it{t}}-value}';
cb.Label.Interpreter = 'latex';
cb.Label.FontSize = 12;
cb.Label.Position = [2.5, 0];
cb.Label.Rotation = -90;
cRange = scaleAxes("c", [], [], "max");

%% Plot raw data
chMeanC0 = cell2mat(cellfun(@mean, changeCellRowNum(trialsECOG_correct), "UniformOutput", false));
chMeanW0 = cell2mat(cellfun(@mean, changeCellRowNum(trialsECOG_wrong), "UniformOutput", false));
chData0(1).chMean = chMeanC0;
chData0(1).color = "r";
chData0(2).chMean = chMeanW0;
chData0(2).color = "k";
FigDM0 = plotRawWaveMulti(chData0, windowDM, ['C', num2str(length(resultC)), 'W', num2str(length(resultW))]);
scaleAxes(FigDM0, "x", [0, windowDM(2)]);
% setAxes(FigDM0, "visible", "off");
plotLayout(FigDM0, (monkeyID - 1) * 2 + find(AREANAMEs == AREANAME), 0.4);
% print(FigDM0, '..\..\figures\DM-Wave-PFC-CC_population.jpg', "-djpeg", "-r600");

%% Plot z-scored data
chMeanC = cell2mat(cellfun(@mean, changeCellRowNum(resultC), "UniformOutput", false));
chMeanW = cell2mat(cellfun(@mean, changeCellRowNum(resultW), "UniformOutput", false));
chData(1).chMean = chMeanC;
chData(1).color = "r";
chData(2).chMean = chMeanW;
chData(2).color = "k";
FigDM = plotRawWaveMulti(chData, windowDM, ['C', num2str(length(resultC)), 'W', num2str(length(resultW))]);
scaleAxes(FigDM, "y", [], [-1, 1]);
scaleAxes(FigDM, "x", [0, windowDM(2)]);
setAxes(FigDM, "visible", "off");
plotLayout(FigDM, (monkeyID - 1) * 2 + find(AREANAMEs == AREANAME), 0.4);
% print(FigDM, [MONKEYPATH, AREANAME, '_DM_ZscoreWave.jpg'], "-djpeg", "-r600");

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
    save([MONKEYPATH, AREANAME, '_DRP.mat'], "resDP");
end

FigDRP = figure;
maximizeFig(FigDRP);
sz = 80;
for cIndex = 1:length(channels)
    if any(badCHs == cIndex)
        continue;
    end
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
    title(['CH ', num2str(cIndex), ' | p<', num2str(alpha)]);
    if cIndex < 57
        xticklabels('');
    end
end
scaleAxes(FigDRP, "y");
lines = struct("Y", 0.5);
addLines2Axes(FigDRP, lines);

P = [resDP.p];
DRP = [resDP.v];
DMI = chMeanC - chMeanW;
save([MONKEYPATH, AREANAME, '_DM_tuning.mat'], "windowDM", "DMI", "DRP", "stat", "V0", "chIdx", "mask", "P");

%% Topo-DRP & p
FigTopo = figure;
maximizeFig(FigTopo);
topoSize = [8, 8];
N = 5;
paddings = [0.1, 0.1, 0.01, 0.01];

subplotNumDRP = [1:6, 13:18];
subplotNumP = [7:12, 19:24];

for wIndex = 1:12
    % DRP
    mAxesDRP(wIndex) = mSubplot(FigTopo, 4, 6, subplotNumDRP(wIndex), 1, "paddings", paddings, "shape", "square-min");
    tuning = resDP(wIndex).v - 0.5;
    tuning(badCHs) = 0;
    plotTopo(tuning, "contourOpt", "off");
    title(['DRP topo [', num2str(resDP(wIndex).window(1)), ' ', num2str(resDP(wIndex).window(2)), ']']);

    % p
    mAxesP(wIndex) = mSubplot(FigTopo, 4, 6, subplotNumP(wIndex), 1, "paddings", paddings, "shape", "square-min");
    P = resDP(wIndex).p;
    P(P == 0) = 1 / nIter;
    P = log(P / alpha) / log(alpha);
    P(badCHs) = 0;
    plotTopo(P, "contourOpt", "off");
    title(['p topo [', num2str(resDP(wIndex).window(1)), ' ', num2str(resDP(wIndex).window(2)), '] | p=log_{', num2str(alpha), '}(p/', num2str(alpha), ')']);
end
scaleAxes(mAxesDRP, "c", [], [], "max");
scaleAxes(mAxesP, "c", [], [-2, 2], "max");
cb1 = colorbar(mAxesDRP(end), 'position', [0.95, 0.1, 0.01, 0.8]);
cb1.Label.String = "DRP value";
cb1.Label.FontSize = 15;
cb1.Label.VerticalAlignment = 'bottom';
cb1.Label.Rotation = -90;
cb2 = colorbar(mAxesP(end), 'position', [0.05, 0.1, 0.01, 0.8]);
cb2.Label.String = ['ANOVA p=log_{', num2str(alpha), '}(p/', num2str(alpha), ')'];
cb2.Label.FontSize = 15;
setAxes(FigTopo, "visible", "off");
print(FigTopo, [MONKEYPATH, AREANAME, '_DM_Topo.jpg'], "-djpeg", "-r600");

%% Example
t = linspace(windowDM(1), windowDM(2), size(trialsECOG_correct{1}, 2))';
ch = input('Input example channel: ');
% Z-scored wave
FigExampleWave = plotRawWaveMulti(chData, windowDM, '', [1, 1], ch);
scaleAxes(FigExampleWave, "x", [0, 800]);
yRange = scaleAxes(FigExampleWave, "y");
a = ones(length(t), 1) * (-100);
a(V0(ch, :) ~= 0) = yRange(2);
resultZscore = [t, ...
    chData(1).chMean(ch, :)', ...
    t, ...
    chData(2).chMean(ch, :)', ...
    t, ...
    a];
a(V0(ch, :) == 0) = [];
t(V0(ch, :) == 0) = [];
hold on;
plot(t, a, "Color", [1 0.5 0], "Marker", "square", "MarkerSize", 10, "MarkerFaceColor", [1 0.5 0]);

t = linspace(windowDM(1), windowDM(2), size(trialsECOG_correct{1}, 2))';
resultRawWave = [t, ...
    chData0(1).chMean(ch, :)', ...
    t, ...
    chData0(2).chMean(ch, :)'];
plotRawWaveMulti(chData0, windowDM, '', [1, 1], ch);

% DRP
figure;
maximizeFig(gcf);
V_s = [];
W_s = [];
V_ns = [];
W_ns = [];
for wIndex = 1:length(resDP)
    if resDP(wIndex).p(ch) < alpha
        V_s = [V_s; resDP(wIndex).v(ch)];
        W_s = [W_s; mean(resDP(wIndex).window)];
    else
        V_ns = [V_ns; resDP(wIndex).v(ch)];
        W_ns = [W_ns; mean(resDP(wIndex).window)];
    end
end
scatter(W_s, V_s, sz, "black", "filled");
hold on;
scatter(W_ns, V_ns, sz, "black");
X = cellfun(@mean, {resDP.window});
Y = cellfun(@(x) x(ch), {resDP.v});
plot(X, Y, "k", "LineWidth", 1);
resultDRP_s = [W_s, V_s];
resultDRP_ns = [W_ns, V_ns];
resultDRP_line = [X', Y'];