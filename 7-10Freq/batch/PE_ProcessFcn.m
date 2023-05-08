function PE_ProcessFcn(params)
close all;
parseStruct(params);

alpha = 0.05; % For ANOVA
alpha_log = 0.01; % For log scale
margins = [0.05, 0.05, 0.1, 0.1];
paddings = [0.1, 0.1, 0.01, 0.01];
colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

mkdir(MONKEYPATH);
mkdir(PrePATH);

%% Data loading
try
    load([MONKEYPATH, AREANAME, '_PE_Data.mat']);
catch
    trialsECOG = [];
    trialAll = [];
    dRatioAll = [];
    badCHs = [];
    chMeanBase = [];
    chStdBase = [];

    if exist("SINGLEPATH", "var") % For population batch after daily process
        for index = 1:length(SINGLEPATH)
            dataSingle(index) = load(SINGLEPATH{index});
            trialsECOG = [trialsECOG; dataSingle(index).trialsECOG];
            dRatioAll = [dRatioAll, dataSingle(index).dRatioAll];
            badCHs = [badCHs; dataSingle(index).badCHs];
            chMeanBase = [chMeanBase; dataSingle(index).chMeanBase];
            chStdBase = [chStdBase; dataSingle(index).chStdBase];
        end
        dRatio = unique(dRatioAll);
        badCHs = unique(badCHs);
        fs = dataSingle(1).fs;
        channels = dataSingle(1).channels;
        ISI = dataSingle(1).ISI;
        windowBase = dataSingle(1).windowBase;
    else
        for index = 1:length(DATESTRs)
            MATPATHs{index, 1} = [ROOTPATH, DATESTRs{index}, '\', DATESTRs{index}, '_', AREANAME];
        end

        try
            idxAC = load([PrePATH, 'AC_excludeIdx']);
            idxPFC = load([PrePATH, 'PFC_excludeIdx']);
        catch
            Pre_ProcessFcn(params);
            idxAC = load([PrePATH, 'AC_excludeIdx']);
            idxPFC = load([PrePATH, 'PFC_excludeIdx']);
        end

        excludeIdxAll = cellfun(@(x, y) [x; y], idxAC.excludeIdx, idxPFC.excludeIdx, "UniformOutput", false);

        if posIndex == 1
            badCHsAll = idxAC.badChIdx;
        else
            badCHsAll = idxPFC.badChIdx;
        end

        for mIndex = 1:length(MATPATHs)
            [trialAll_temp, ECOGDataset] = ECOGPreprocess(MATPATHs{mIndex}, params);
            trials = trialAll_temp(~cellfun(@(x) isequal(x, true), {trialAll_temp.interrupt}));
            trialsECOG_temp = selectEcog(ECOGDataset, trials, "dev onset", windowICA);
            
            % Normalization
            if strcmpi(normOpt, "on")
                chMeanBase{mIndex, 1} = cellfun(@(x) mean(x, "all"), changeCellRowNum(selectEcog(ECOGDataset, trials, "trial onset", windowBase)));
                chStdBase{mIndex, 1} = cellfun(@(x) std(x, [], "all"), changeCellRowNum(selectEcog(ECOGDataset, trials, "trial onset", windowBase)));
                trialsECOG_temp = cellfun(@(x) (x - chMeanBase{mIndex}) ./ chStdBase{mIndex}, trialsECOG_temp, "UniformOutput", false);
            else
                chMeanBase = [];
                chStdBase = [];
            end

            trials(excludeIdxAll{mIndex}) = [];
            trialsECOG_temp(excludeIdxAll{mIndex}) = [];
            trialAll = [trialAll; trials];
            trialsECOG = [trialsECOG; trialsECOG_temp];
            badCHs = [badCHs; badCHsAll{mIndex}];
        end

        badCHs = unique(badCHs);
        fs = ECOGDataset.fs;
        channels = ECOGDataset.channels;

        chs2doICA = channels;
        chs2doICA(ismember(chs2doICA, badCHs)) = [];

        % Perform ICA on good channels
        if strcmp(icaOpt, "on")
            try
                load([PrePATH, AREANAME, '_ICA'], "-mat", "comp", "ICs", "badCHs", "chs2doICA");
            catch
                [comp, ICs, FigTopoICA] = ICA_Population(trialsECOG, fs, windowICA, chs2doICA);
                mPrint(FigTopoICA, strcat(PrePATH, AREANAME, "_Topo_ICA"), "-djpeg", "-r400");
                mSave([PrePATH, AREANAME, '_ICA.mat'], "comp", "ICs", "badCHs", "chs2doICA");
            end
            trialsECOG = cellfun(@(x) x(chs2doICA, :), trialsECOG, "UniformOutput", false);
            trialsECOG = reconstructData(trialsECOG, comp, ICs);
            trialsECOG = cellfun(@(x) insertRows(x, channels(ismember(channels, badCHs) & ~ismember(channels, chs2doICA))), trialsECOG, "UniformOutput", false);
        end

        % Replace bad chs by averaging neighbour chs
        trialsECOG = interpolateBadChs(trialsECOG, badCHs);

        [dRatioAll, dRatio] = computeDevRatio(trialAll(~cellfun(@(x) isequal(x, false), {trialAll.correct})));

        startIdx = fix((windowPE(1) - windowICA(1)) / 1000 * fs);
        endIdx = fix((windowPE(2) - windowICA(1)) / 1000 * fs);
        trialsECOG = cellfun(@(x) x(:, startIdx:endIdx), trialsECOG(~cellfun(@(x) isequal(x, false), {trialAll.correct})), "UniformOutput", false);
        ISI = roundn(mean([trialAll.ISI]), 0);
    end

    mSave([MONKEYPATH, AREANAME, '_PE_Data.mat'], ...
          "windowPE", "windowMMN", "trialsECOG", "ISI", ...
          "dRatioAll", "dRatio", "fs", "channels", "badCHs", ...
          "windowBase", "chMeanBase", "chStdBase");
end

if strcmpi(dataOnlyOpt, "on")
    return;
end

%% Categorization
% MMN
tIdx1 = (-ISI + windowMMN(1) - windowPE(1)) / 1000 * fs + 1:(windowMMN(1) - windowPE(1)) / 1000 * fs + 1;
tIdx2 = (windowMMN(1) - windowPE(1)) / 1000 * fs + 1:(windowMMN(2) - windowPE(1)) / 1000 * fs + 1;
trialsECOG_MMN = cellfun(@(x) x(:, tIdx2) - x(:, tIdx1), trialsECOG, "UniformOutput", false);

for dIndex = 1:length(dRatio)
    temp = trialsECOG(dRatioAll == dRatio(dIndex));
    chData(dIndex).chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(temp), "UniformOutput", false));
    chData(dIndex).dataNorm = cellfun(@(x) x - chData(1).chMean, temp, "UniformOutput", false);
    chData(dIndex).color = colors{dIndex};

    chDataMMN(dIndex).chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(trialsECOG_MMN(dRatioAll == dRatio(dIndex))), "UniformOutput", false));
    chDataMMN(dIndex).color = colors{dIndex};
end

%% Multiple comparison
t = linspace(windowPE(1), windowPE(2), size(trialsECOG{1}, 2))';
tMMN = linspace(windowMMN(1), windowMMN(2), size(trialsECOG_MMN{1}, 2))';

pool = 2:length(dRatio); % include std group

try
    load([MONKEYPATH, AREANAME, '_PE_CBPT'], "stat", "-mat");
catch
    data = [];
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
    mSave([MONKEYPATH, AREANAME, '_PE_CBPT.mat'], "stat");
end

try
    load([MONKEYPATH, AREANAME, '_PE_MMN_CBPT'], "statMMN", "-mat");
catch
    dataMMN = [];
    for dIndex = 1:length(pool)
        tempMMN = trialsECOG_MMN(dRatioAll == dRatio(pool(dIndex)));
        % time 1*nSample
        dataMMN(dIndex).time = tMMN' / 1000;
        % label nCh*1 cell
        dataMMN(dIndex).label = cellfun(@(x) num2str(x), num2cell(channels)', 'UniformOutput', false);
        % trial nTrial*nCh*nSample
        dataMMN(dIndex).trial = cell2mat(cellfun(@(x) permute(x, [3, 1, 2]), tempMMN, "UniformOutput", false));
        % trialinfo nTrial*1
        dataMMN(dIndex).trialinfo = repmat(dIndex, [length(tempMMN), 1]);
    end
    statMMN = CBPT(dataMMN);
    mSave([MONKEYPATH, AREANAME, '_PE_MMN_CBPT.mat'], "statMMN");
end

%% Raw wave CBPT
run("PE_PlotImpl_RawCBPT.m");

%% Topo-tuning & p of raw wave
run("PE_PlotImpl_RawTopo.m");

%% MMN CBPT
run("PE_PlotImpl_MMN_CBPT.m");

%% Topo-tuning & p of MMN
run("PE_PlotImpl_MMN_Topo.m");

%% Example
ch = input('Input example channel: ');
t = linspace(windowPE(1), windowPE(2), size(trialsECOG{1}, 2))';
tMMN = linspace(windowMMN(1), windowMMN(2), size(trialsECOG_MMN{1}, 2))';

plotRawWaveMulti(chData, windowPE, 'Raw', [1, 1], ch);
scaleAxes("x", [0, 800]);
yRange = scaleAxes("y");
hold on;
tTemp = t(V0(ch, :) > 0);
bar(tTemp, repmat(yRange(1), [length(tTemp), 1]), 1, 'FaceColor', [0 0 0], 'EdgeColor', 'none', 'FaceAlpha', 0.1, 'ShowBaseLine', 'off');
bar(tTemp, repmat(yRange(2), [length(tTemp), 1]), 1, 'FaceColor', [0 0 0], 'EdgeColor', 'none', 'FaceAlpha', 0.1, 'ShowBaseLine', 'off');

plotRawWaveMulti(chDataMMN, windowMMN, 'MMN', [1, 1], ch);
yRange = scaleAxes("y");
hold on;
tTemp = tMMN(V0_MMN(ch, :) > 0);
bar(tTemp, repmat(yRange(1), [length(tTemp), 1]), 1, 'FaceColor', [0 0 0], 'EdgeColor', 'none', 'FaceAlpha', 0.1, 'ShowBaseLine', 'off');
bar(tTemp, repmat(yRange(2), [length(tTemp), 1]), 1, 'FaceColor', [0 0 0], 'EdgeColor', 'none', 'FaceAlpha', 0.1, 'ShowBaseLine', 'off');

a = ones(length(t), 1) * (-100);
a(V0(ch, :) > 0) = 100;
resultWave = [t, ...
              chData(1).chMean(ch, :)', ...
              chData(2).chMean(ch, :)', ...
              chData(3).chMean(ch, :)', ...
              chData(4).chMean(ch, :)', ...
              chData(5).chMean(ch, :)', ...
              a];

a = ones(length(tMMN), 1) * (-100);
a(V0_MMN(ch, :) > 0) = 100;
resultWaveMMN = [tMMN, ...
                 chDataMMN(1).chMean(ch, :)', ...
                 chDataMMN(2).chMean(ch, :)', ...
                 chDataMMN(3).chMean(ch, :)', ...
                 chDataMMN(4).chMean(ch, :)', ...
                 chDataMMN(5).chMean(ch, :)', ...
                 a];

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

resultTuningMMN = cellfun(@(x, y) [x(:, ch), y(:, ch)], tuningMeanMMN, tuningSEMMN, "UniformOutput", false);
figure;
maximizeFig;
plotSize = autoPlotSize(length(resultTuningMMN));
for wIndex = 1:length(resultTuningMMN)
    mSubplot(plotSize(1), plotSize(2), wIndex, 1, margins, paddings);
    errorbar(resultTuningMMN{wIndex}(:, 1), resultTuningMMN{wIndex}(:, 2), "k-", "LineWidth", 1);
    title(['[', num2str(edgeMMN(wIndex)), ', ', num2str(edgeMMN(wIndex + 1)), '] | p=', num2str(P_MMN(ch, wIndex))]);
    xlim([0.5, 5.5]);
    xticks(1:5);
    xticklabels(num2str(dRatio'));
end
scaleAxes;