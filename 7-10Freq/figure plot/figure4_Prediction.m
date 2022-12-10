%% Prediction-smooth
clear; close all; clc;

%% Parameter settings
monkeyID = 1; % 1-CC, 2-XX

AREANAME = 'AC';
% AREANAME = 'PFC';

AREANAMEs = ["AC", "PFC"];
params.posIndex = find(AREANAMEs == AREANAME); % 1-AC, 2-PFC
params.choiceWin = [100, 600];
params.processFcn = @ActiveProcess_7_10Freq;

margins = [0.05, 0.05, 0.1, 0.1];
paddings = [0.01, 0.03, 0.01, 0.01];

if monkeyID == 1
    ROOTPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\CC\7-10Freq Active\';
    DATESTRs = {'cc20220520', 'cc20220706', 'cc20220801', 'cc20221014', 'cc20221015'};
    MONKEYPATH = 'CC\Prediction\';
    PrePATH = 'CC\Preprocess\';
elseif monkeyID == 2
    ROOTPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\XX\7-10Freq Active\';
    DATESTRs = {'xx20220711', 'xx20220720', 'xx20220812', 'xx20220820', 'xx20220822', 'xx20220913'};
    MONKEYPATH = 'XX\Prediction\';
    PrePATH = 'XX\Preprocess\';
else
    error("Invalid monkey ID");
end

mkdir(MONKEYPATH);
mkdir(PrePATH);
badCHs = [];

try
    load([MONKEYPATH, AREANAME, '_Prediction_Data.mat']);
catch

    for sIndex = 1:length(DATESTRs)
        MATPATHs{sIndex, 1} = [ROOTPATH, DATESTRs{sIndex}, '\', DATESTRs{sIndex}, '_', AREANAME];
    end

    %% Load
    windowP = [-3000, 7000];
    windowT0 = [0, 500];

    trialAll = [];
    trialsECOG = [];

    try
        idxAC = load([PrePATH, 'AC_excludeIdx']);
        idxPFC = load([PrePATH, 'PFC_excludeIdx']);
        excludeIdxAll = cellfun(@(x, y) [x, y], idxAC.excludeIdx, idxPFC.excludeIdx, "UniformOutput", false);
    end

    for mIndex = 1:length(MATPATHs)
        [trialAll_temp, ECOGDataset] = ECOGPreprocess(MATPATHs{mIndex}, params);
        trials = trialAll_temp(~[trialAll_temp.interrupt]);
        trialsECOG_temp = selectEcog(ECOGDataset, trials, "trial onset", windowP);
        if ~exist("excludeIdxAll", "var")
            excludeIdx{mIndex} = excludeTrials(trialsECOG_temp);
        else
            excludeIdx = excludeIdxAll;
        end
        trials(excludeIdx{mIndex}) = [];
        trialAll = [trialAll; trials];
        trialsECOG_temp(excludeIdx{mIndex}) = [];
        % trialsECOG_temp = cellfun(@(x) cell2mat(rowFcn(@(y) y * length(y) ./ norm(y), x)), trialsECOG_temp, "UniformOutput", false);
        trialsECOG = [trialsECOG; trialsECOG_temp];
    end

    % save([MONKEYPATH, AREANAME, '_excludeIdx'], "excludeIdx");

    fs = ECOGDataset.fs;
    channels = ECOGDataset.channels;

    %% ICA
    load([PrePATH, AREANAME, '_ICA'], "-mat", "comp", "ICs");
    trialsECOG = reconstructData(trialsECOG, comp, ICs);

    save([MONKEYPATH, AREANAME, '_Prediction_Data.mat'], "windowP", "windowT0", "trialsECOG", "trialAll", "channels", "fs", "-mat");
end

t = (0:size(trialsECOG{1}, 2) - 1)' / fs * 1000 + windowP(1);
nCh = size(trialsECOG{1}, 1);
ISI = fix(mean(cellfun(@(x, y) (x(end) - x(1)) / y, {trialAll.soundOnsetSeq}, {trialAll.stdNum})));
fRange = [1000 / ISI - 0.1, 1000 / ISI + 0.1]; % 2 ± 0.1 Hz
nStdAll = unique([trialAll.stdNum]);
nStd = nStdAll(end);

%% Raw
[~, chMean] = joinSTD(trialAll, trialsECOG, fs);
% FigWave = plotRawWave(chMean, [], windowP);
% FigTFA = plotTFA(chMean, fs, [], windowP);
% scaleAxes([FigWave, FigTFA], "x", [0, ISI * nStd]);
% scaleAxes(FigWave, "y", [], [-100, 100]);
% scaleAxes(FigTFA, "c", [], [0, 10]);
% yRange0 = scaleAxes(FigWave, "y", [], [], "max");
% lines = struct("X", mat2cell((0:nStd - 1)' * ISI, ones(nStd, 1)));
% addLines2Axes(FigWave, lines);
% lines = struct("X", mat2cell((0:nStd - 1)' * ISI, ones(nStd, 1)), "color", repmat({"w"}, nStd, 1));
% addLines2Axes(FigTFA, lines);

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
        startIdx = (0:(floor(length(trialsECOG_temp) / nSmooth) - 1)) * nSmooth + 1;
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
    save([MONKEYPATH, AREANAME, '_CWT_Smooth_Prediction_CHAll'], "resultCWTSmooth", "stdNumSmooth", "fRange");
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
    if any(badCHs == cIndex)
        title(['CH ', num2str(cIndex), ' (bad)']);
    else
        title(['CH ', num2str(cIndex)]);
    end
    if cIndex < 57
        xticklabels('');
    end
end
scaleAxes("y", "autoScale", "on");

FigAOITopo = figure;
maximizeFig;
mSubplot(1, 1, 1, "shape", "square-min");
if params.posIndex == 1
    plotTopo(rowFcn(@(x) mean(x(7:9)) - mean(x(1:3)), AoiMean));
    hold on;
    plotLayout(gca, monkeyID + params.posIndex - 1);
    title(['AOIF Topography of ', AREANAME, ' | mean AOIF_{7,8,9} - mean AOIF_{1,2,3}']);
else
    plotTopo(rowFcn(@(x) mean(x(7:9)) - mean(x(3:5)), AoiMean));
    hold on;
    plotLayout(gca, monkeyID + params.posIndex - 1);
    title(['AOIF Topography of ', AREANAME, ' | mean AOIF_{7,8,9} - mean AOIF_{3,4,5}']);
end
cb = colorbar('position', [0.75, 0.12, 0.01, 0.8]);
cb.Label.String = '\Delta Amplitude of interested frequency band';
cb.Label.FontSize = 12;
cb.Label.VerticalAlignment = 'bottom';
cb.Label.Rotation = -90;
colormap('jet');
print(FigAOITopo, [MONKEYPATH, AREANAME, '_AOIF_Topo.jpg'], "-djpeg", "-r600");

%% Example
ch = input('Input example channel: ');

resultTFR = [AoiMean(ch, :)', AoiSE(ch, :)'];
resultWave = [t / 1000, chMean(ch, :)'];

FigWaveExample = plotRawWave(chMean, [], windowP, [], [1, 1], ch);
FigTFAExample = plotTFA(chMean, fs, [], windowP, [], [1, 1], ch);
scaleAxes([FigTFAExample, FigWaveExample], "x", [0, ISI * nStd]);
% scaleAxes(FigTFAExample, "c", [0, 8]);
lines = struct("X", mat2cell((0:nStd - 1)' * ISI, ones(nStd, 1)));
addLines2Axes(FigWaveExample, lines);
print(FigTFAExample, [MONKEYPATH, AREANAME, '_TFR_CH', num2str(ch), '.jpg'], "-djpeg", "-r600");

[~, temp] = joinSTD(trialAll([trialAll.oddballType] == "STD" & [trialAll.correct]), trialsECOG([trialAll.oddballType] == "STD" & [trialAll.correct]), fs);
resultSTD = [t / 1000, temp(ch, :)'];
Fig1 = plotRawWave(temp, [], windowP, 'STD', [1, 1], ch);
Fig2 = plotTFA(temp, fs, [], windowP, 'STD', [1, 1], ch);
scaleAxes([Fig1, Fig2], "x", [0, (nStd + 2) * ISI]);
print(Fig1, [MONKEYPATH, AREANAME, '_Wave_STD_CH', num2str(ch), '.jpg'], "-djpeg", "-r600");
print(Fig2, [MONKEYPATH, AREANAME, '_TFR_STD_CH', num2str(ch), '.jpg'], "-djpeg", "-r600");