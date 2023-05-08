function DM_ProcessFcn(params)
close all;
parseStruct(params);

alpha = 0.05; % For ANOVA
alpha_log = 0.01; % For log scale
margins = [0.05, 0.05, 0.1, 0.1];
paddings = [0.01, 0.03, 0.01, 0.01];

nIter = 1e3; % For DRP
step = 50;
binSize = 100;

mkdir(MONKEYPATH);
mkdir(PrePATH);

%% Data loading
try
    load([MONKEYPATH, AREANAME, '_DM_Data.mat']);
catch
    badCHs = [];
    resultC = [];
    resultW = [];
    trialsECOG_correct = [];
    trialsECOG_wrong = [];

    if exist("SINGLEPATH", "var") % For population batch after daily process
        for index = 1:length(SINGLEPATH)
            dataSingle(index) = load(SINGLEPATH{index});
            trialsECOG_correct = [trialsECOG_correct; dataSingle(index).trialsECOG_correct];
            trialsECOG_wrong = [trialsECOG_wrong; dataSingle(index).trialsECOG_wrong];
            resultC = [resultC; dataSingle(index).resultC];
            resultW = [resultW; dataSingle(index).resultW];
            badCHs = [badCHs; dataSingle(index).badCHs];
        end
        badCHs = unique(badCHs);
        fs = dataSingle(1).fs;
        channels = dataSingle(1).channels;
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

        trialsECOG = [];
        trialAll = [];
        for mIndex = 1:length(MATPATHs)
            [trialAll_temp, ECOGDataset] = ECOGPreprocess(MATPATHs{mIndex}, params);
            trials = trialAll_temp(~[trialAll_temp.interrupt]);
            trialsECOG_temp = selectEcog(ECOGDataset, trials, "dev onset", windowICA);
            trials(excludeIdxAll{mIndex}) = [];
            trialsECOG_temp(excludeIdxAll{mIndex}) = [];
            trialAll = [trialAll; trials];
            trialsECOG = [trialsECOG; trialsECOG_temp];
            badCHs = [badCHs; badCHsAll{mIndex}];
        end

        badCHs = unique(badCHs);
        FigB = plotBehaviorOnly(trialAll, "r", "legendStr", "7-10 Freq", "xlabelStr", "DEV / STD frequency difference ratio");
        mPrint(FigB, strcat(MONKEYPATH, "Behavior"), "-djpeg", "-r400");

        fs = ECOGDataset.fs;
        channels = ECOGDataset.channels;

        chs2doICA = channels;
        chs2doICA(ismember(chs2doICA, badCHs)) = [];

        % ICA
        if strcmp(icaOpt, "on")
            load([PrePATH, AREANAME, '_ICA'], "-mat", "comp", "ICs", "badCHs", "chs2doICA");
            trialsECOG = cellfun(@(x) x(chs2doICA, :), trialsECOG, "UniformOutput", false);
            trialsECOG = reconstructData(trialsECOG, comp, ICs);
            trialsECOG = cellfun(@(x) insertRows(x, channels(ismember(channels, badCHs) & ~ismember(channels, chs2doICA))), trialsECOG, "UniformOutput", false);
        end

        % Replace bad chs by averaging neighbour chs
        trialsECOG = interpolateBadChs(trialsECOG, badCHs);

        [dRatioAll, dRatio] = computeDevRatio(trialAll);
        startIdx = fix((windowDM(1) - windowICA(1)) / 1000 * fs);
        endIdx = fix((windowDM(2) - windowICA(1)) / 1000 * fs);
        trialsECOG = cellfun(@(x) x(:, startIdx:endIdx), trialsECOG, "UniformOutput", false);

        % Z-score
        for dIndex = 2:4
            trials = trialAll(dRatioAll == dRatio(dIndex));
            result = trialsECOG(dRatioAll == dRatio(dIndex));
            trialsECOG_correct = [trialsECOG_correct; result([trials.correct])];
            trialsECOG_wrong = [trialsECOG_wrong; result(~[trials.correct] & ~[trials.interrupt])];
            result = changeCellRowNum(cellfun(@zscore, changeCellRowNum(result), "UniformOutput", false));
            resultC = [resultC; result([trials.correct])];
            resultW = [resultW; result(~[trials.correct] & ~[trials.interrupt])];
        end
    end

    mSave([MONKEYPATH, AREANAME, '_DM_Data.mat'], "windowDM", "trialsECOG_correct", "trialsECOG_wrong", "resultC", "resultW", "fs", "channels", "badCHs");
end

if strcmpi(dataOnlyOpt, "on")
    return;
end

% Raw
chData0(1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(trialsECOG_correct), "UniformOutput", false));
chData0(1).color = "r";
chData0(2).chMean = cell2mat(cellfun(@mean, changeCellRowNum(trialsECOG_wrong), "UniformOutput", false));
chData0(2).color = "k";

% Z-score
chData(1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultC), "UniformOutput", false));
chData(1).color = "r";
chData(2).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultW), "UniformOutput", false));
chData(2).color = "k";

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
    mSave([MONKEYPATH, AREANAME, '_DM_CBPT.mat'], "stat");
end

%% Plot raw wave, z-scored wave and CBPT res of z-scored wave
run("DM_PlotImpl_CBPT.m");

%% DRP
run("DM_PlotImpl_DRP.m");

%% Topo-DRP & p
run("DM_PlotImpl_Topo.m");

%% Example
% t = linspace(windowDM(1), windowDM(2), size(trialsECOG_correct{1}, 2))';
% ch = input('Input example channel: ');
% 
% % Z-scored wave
% plotRawWaveMulti(chData, windowDM, '', [1, 1], ch);
% scaleAxes("x", [0, 800]);
% yRange = scaleAxes("y");
% hold on;
% tTemp = t(V0(ch, :) > 0);
% bar(tTemp, repmat(yRange(1), [length(tTemp), 1]), 1, 'FaceColor', [0 0 0], 'EdgeColor', 'none', 'FaceAlpha', 0.1, 'ShowBaseLine', 'off');
% bar(tTemp, repmat(yRange(2), [length(tTemp), 1]), 1, 'FaceColor', [0 0 0], 'EdgeColor', 'none', 'FaceAlpha', 0.1, 'ShowBaseLine', 'off');
% 
% a = ones(length(t), 1) * (-100);
% a(V0(ch, :) ~= 0) = 100;
% resultZscore = [t, ...
%                 chData(1).chMean(ch, :)', ...
%                 chData(2).chMean(ch, :)', ...
%                 a];
% 
% % Raw wave
% resultRawWave = [t, ...
%                  chData0(1).chMean(ch, :)', ...
%                  chData0(2).chMean(ch, :)'];
% plotRawWaveMulti(chData0, windowDM, '', [1, 1], ch);
% 
% % DRP
% figure;
% maximizeFig(gcf);
% V_s = [];
% W_s = [];
% V_ns = [];
% W_ns = [];
% for wIndex = 1:length(resDP)
%     if resDP(wIndex).p(ch) < alpha
%         V_s = [V_s; resDP(wIndex).v(ch)];
%         W_s = [W_s; mean(resDP(wIndex).window)];
%     else
%         V_ns = [V_ns; resDP(wIndex).v(ch)];
%         W_ns = [W_ns; mean(resDP(wIndex).window)];
%     end
% end
% scatter(W_s, V_s, sz, "black", "filled");
% hold on;
% scatter(W_ns, V_ns, sz, "black");
% X = cellfun(@mean, {resDP.window});
% Y = cellfun(@(x) x(ch), {resDP.v});
% plot(X, Y, "k", "LineWidth", 1);
% resultDRP_s = [W_s, V_s];
% resultDRP_ns = [W_ns, V_ns];
% resultDRP_line = [X', Y'];