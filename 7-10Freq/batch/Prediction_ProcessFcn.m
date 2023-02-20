function Prediction_ProcessFcn(params)
close all;
parseStruct(params);

margins = [0.05, 0.05, 0.1, 0.1];
paddings = [0.01, 0.03, 0.01, 0.01];

mkdir(MONKEYPATH);
mkdir(PrePATH);

%% Data loading
try
    load([MONKEYPATH, AREANAME, '_Prediction_Data.mat']);
catch
    windowP = [-3000, 7000];
    windowT0 = [0, 500];

    trialAll = [];
    trialsECOG = [];
    badCHs = [];
    
    if exist("SINGLEPATH", "var") % For population batch after daily process
        for index = 1:length(SINGLEPATH)
            dataSingle(index) = load(SINGLEPATH{index});
            trialsECOG = [trialsECOG; dataSingle(index).trialsECOG];
            badCHs = [badCHs; dataSingle(index).badCHs];
        end
        badCHs = unique(badCHs);
        fs = dataSingle(1).fs;
        channels = dataSingle(1).channels;
    else
        for sIndex = 1:length(DATESTRs)
            MATPATHs{sIndex, 1} = [ROOTPATH, DATESTRs{sIndex}, '\', DATESTRs{sIndex}, '_', AREANAME];
        end

        try
            idxAC = load([PrePATH, 'AC_excludeIdx']);
            idxPFC = load([PrePATH, 'PFC_excludeIdx']);
        catch
            Pre_ProcessFcn(params);
            idxAC = load([PrePATH, 'AC_excludeIdx']);
            idxPFC = load([PrePATH, 'PFC_excludeIdx']);
        end

        excludeIdxAll = cellfun(@(x, y) [x, y], idxAC.excludeIdx, idxPFC.excludeIdx, "UniformOutput", false);

        if posIndex == 1
            badCHsAll = idxAC.badChIdx;
        else
            badCHsAll = idxPFC.badChIdx;
        end

        for mIndex = 1:length(MATPATHs)
            [trialAll_temp, ECOGDataset] = ECOGPreprocess(MATPATHs{mIndex}, params);
            trials = trialAll_temp(~[trialAll_temp.interrupt]);
            trialsECOG_temp = selectEcog(ECOGDataset, trials, "trial onset", windowP);
            trials(excludeIdxAll{mIndex}) = [];
            trialAll = [trialAll; trials];
            trialsECOG_temp(excludeIdxAll{mIndex}) = [];
            % trialsECOG_temp = cellfun(@(x) cell2mat(rowFcn(@(y) y * length(y) ./ norm(y), x)), trialsECOG_temp, "UniformOutput", false);
            trialsECOG = [trialsECOG; trialsECOG_temp];
            badCHs = [badCHs; badCHsAll{mIndex}];
        end

        badCHs = unique(badCHs);
        fs = ECOGDataset.fs;
        channels = ECOGDataset.channels;

        chs2doICA = channels;
        chs2doICA(ismember(chs2doICA, badCHs)) = [];

        % ICA
        if strcmp(icaOpt, "on")
            load([PrePATH, AREANAME, '_ICA'], "-mat", "comp", "ICs", "badCHs");
            trialsECOG = cellfun(@(x) x(chs2doICA, :), trialsECOG, "UniformOutput", false);
            trialsECOG = reconstructData(trialsECOG, comp, ICs);
            trialsECOG = cellfun(@(x) insertRows(x, badCHs), trialsECOG, "UniformOutput", false);
        end

        % Replace bad chs by averaging neighbour chs
        trialsECOG = interpolateBadChs(trialsECOG, badCHs);
    end
    mSave([MONKEYPATH, AREANAME, '_Prediction_Data.mat'], "windowP", "windowT0", "trialsECOG", "trialAll", "channels", "fs", "badCHs");
end

t = (0:size(trialsECOG{1}, 2) - 1)' / fs * 1000 + windowP(1);
nCh = size(trialsECOG{1}, 1);
ISI = fix(mean(cellfun(@(x, y) (x(end) - x(1)) / y, {trialAll.soundOnsetSeq}, {trialAll.stdNum})));
fRange = [1000 / ISI - 0.1, 1000 / ISI + 0.1]; % 2 ± 0.1 Hz
nStdAll = unique([trialAll.stdNum]);
nStd = nStdAll(end);

%% Raw
[~, chMean] = joinSTD(trialAll, trialsECOG, fs);
FigWave = plotRawWave(chMean, [], windowP);
FigTFA = plotTFA(chMean, fs, [], windowP);
scaleAxes([FigWave, FigTFA], "x", [0, ISI * nStd]);
scaleAxes(FigWave, "y", "on", "symOpts", "max");
scaleAxes(FigTFA, "c", "on", "cutoffRange", [0, 10]);
lines = struct("X", mat2cell((0:nStd - 1)' * ISI, ones(nStd, 1)));
addLines2Axes(FigWave, lines);
lines = struct("X", mat2cell((0:nStd - 1)' * ISI, ones(nStd, 1)), "color", repmat({"w"}, nStd, 1));
addLines2Axes(FigTFA, lines);
drawnow;

%% CWT
% smooth
try
    load([MONKEYPATH, AREANAME, '_CWT_Smooth_Prediction_CHAll']);
catch
    nSmooth = 20;
    resultCWTSmooth = [];
    stdNumSmooth = [];

    for sIndex = nStdAll(1):nStd
        trialsECOG_temp = trialsECOG([trialAll.stdNum] == sIndex);
        startIdx = max([0, (0:(floor(length(trialsECOG_temp) / nSmooth) - 1))]) * nSmooth + 1;
        endIdx = [startIdx(1:end - 1) + nSmooth - 1, length(trialsECOG_temp)];
        temp = arrayfun(@(x, y) cell2mat(cellfun(@mean, changeCellRowNum(trialsECOG_temp(x:y)), "UniformOutput", false)), startIdx, endIdx, "UniformOutput", false);

        tic
        result_temp = cell(length(startIdx), 1);
        parfor index = 1:length(startIdx)
            result_temp{index} = gather(cwtMulti_mex(temp{index}', fs, fRange))';
        end
        resultCWTSmooth = [resultCWTSmooth; result_temp];
        stdNumSmooth = [stdNumSmooth; ones(length(startIdx), 1) * sIndex];
        toc
    end

    resultCWTSmooth = changeCellRowNum(resultCWTSmooth);
    mSave([MONKEYPATH, AREANAME, '_CWT_Smooth_Prediction_CHAll'], "resultCWTSmooth", "stdNumSmooth", "fRange");
end

AoiMean = zeros(nCh, nStd);
AoiSE = zeros(nCh, nStd);
resultTuning = cell(nStd, 1);
for sIndex = 1:nStd
    tIdx = fix(((sIndex - 1) * ISI + windowT0(1) - windowP(1)) / 1000 * fs) + 1:fix(((sIndex - 1) * ISI + windowT0(2) - windowP(1)) / 1000 * fs);
    resultTuning{sIndex} = cell2mat(cellfun(@(x) mean(x(stdNumSmooth >= sIndex, tIdx), 2)', resultCWTSmooth, "UniformOutput", false));
    AoiMean(:, sIndex) = mean(resultTuning{sIndex}, 2);
    AoiSE(:, sIndex) = SE(resultTuning{sIndex}, 2);
end

%% Prediction-TFR
FigTuning = figure;
maximizeFig;
for cIndex = 1:nCh
    mSubplot(FigTuning, 8, 8, cIndex, 1, margins, paddings);
    errorbar(AoiMean(cIndex, :), AoiSE(cIndex, :), "k.-", "LineWidth", 1);
    xlim([0.5, nStd + 0.5])
    xticks(1:nStd);

    if ismember(cIndex, badCHs)
        title(['CH ', num2str(cIndex), ' (bad)']);
    else
        title(['CH ', num2str(cIndex)]);
    end

    if cIndex < 57
        xticklabels('');
    end
end
scaleAxes("y", "on");
mPrint(FigTuning, [MONKEYPATH, AREANAME, '_Prediction_tuning.jpg'], "-djpeg", "-r600");

FigAOITopo = figure;
maximizeFig;
mSubplot(1, 1, 1, "shape", "square-min");
if params.posIndex == 1
    temp = rowFcn(@(x) mean(x(7:9)) - mean(x(1:3)), AoiMean);
    mAxe = plotTopo(temp);
    title('AOIF Topography of AC | mean AOIF_{7,8,9} - mean AOIF_{1,2,3}');
    plotLayout(gca, 2 * (monkeyID - 1) + params.posIndex);
else
    temp = rowFcn(@(x) mean(x(7:9)) - mean(x(3:5)), AoiMean);
    mAxe = plotTopo(temp);
    title('AOIF Topography of PFC | mean AOIF_{7,8,9} - mean AOIF_{3,4,5}');
    plotLayout(gca, 2 * (monkeyID - 1) + params.posIndex);
end
colormap('jet');
cb = colorbar(mAxe, 'position', [0.75, 0.12, 0.01, 0.8]);
cb.Label.String = '\Delta Amplitude of interested frequency band';
cb.Label.FontSize = 12;
cb.Label.VerticalAlignment = 'bottom';
cb.Label.Rotation = -90;
mPrint(FigAOITopo, [MONKEYPATH, AREANAME, '_AOIF_Topo.jpg'], "-djpeg", "-r600");

%% Example
% ch = input('Input example channel: ');
%
% resultTFR = [AoiMean(ch, :)', AoiSE(ch, :)'];
% resultWave = [t / 1000, chMean(ch, :)'];
%
% FigWaveExample = plotRawWave(chMean, [], windowP, [], [1, 1], ch);
% FigTFAExample = plotTFA(chMean, fs, [], windowP, [], [1, 1], ch);
% scaleAxes([FigTFAExample, FigWaveExample], "x", [0, ISI * nStd]);
% % scaleAxes(FigTFAExample, "c", [0, 8]);
% lines = struct("X", mat2cell((0:nStd - 1)' * ISI, ones(nStd, 1)));
% addLines2Axes(FigWaveExample, lines);
% mPrint(FigTFAExample, [MONKEYPATH, AREANAME, '_TFR_CH', num2str(ch), '.jpg'], "-djpeg", "-r600");
%
% idx = [trialAll.oddballType] == "STD" & [trialAll.correct];
% [~, temp, ~, window] = joinSTD(trialAll(idx), trialsECOG(idx), fs, "reserveTail", true);
% resultSTD = [t / 1000, temp(ch, :)'];
% Fig1 = plotRawWave(temp, [], window, 'STD', [1, 1], ch);
% Fig2 = plotTFA(temp, fs, [], window, 'STD', [1, 1], ch);
% lines = [];
% lines(1).X = nStd * ISI;
% lines(2).X = (nStd + 1) * ISI;
% addLines2Axes(Fig1, lines);
% lines(1).color = [1, 1, 1];
% lines(2).color = [1, 1, 1];
% addLines2Axes(Fig2, lines);
% scaleAxes([Fig1, Fig2], "x", [0, (nStd + 1) * ISI + 1000]);
% mPrint(Fig1, [MONKEYPATH, AREANAME, '_Wave_STD_CH', num2str(ch), '.jpg'], "-djpeg", "-r600");
% mPrint(Fig2, [MONKEYPATH, AREANAME, '_TFR_STD_CH', num2str(ch), '.jpg'], "-djpeg", "-r600");