clc; close all;
MATPATH = MATPATHS{mIndex};
if contains(MATPATH, "CC")
    monkeyId = 1;  % 1：chouchou; 2：xiaoxiao
    monkeyStr = "CC";
elseif contains(MATPATH, "XX")
    monkeyId = 2;
    monkeyStr = "XX";
end

AREANAME = ["AC", "PFC"];
params.posIndex = find(matches(AREANAME, areaSel)); % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;
AREANAME = AREANAME(params.posIndex);

%% load parameters
OffsetParams = ME_ParseOffsetParams(protocolStr);
parseStruct(OffsetParams)

fs = 600;
OffsetParams.fs = fs;
correspFreq = 1000./ICI2;



%% process
temp = string(split(MATPATH, '\'));
DateStr = temp(end - 1);
Protocol = temp(end - 2);
FIGPATH = strcat(rootPathFig, "Figure_", protStr,"\", DateStr, "_", AREANAME, "\Figures\");
if exist(FIGPATH, "dir")
    return
end

tic
[trialAll, trialsECOG_Merge, trialsECOG_S1_Merge] =  mergeCTLTrialsECOG(MATPATH, params.posIndex, OffsetParams);
toc

%% ICA
% align to certain duration
ICPATH = strrep(FIGPATH, "Figures", "ICA");
mkdir(ICPATH);
ICAName = strcat(ICPATH, "comp.mat");
trialsECOG_MergeTemp = trialsECOG_Merge;
trialsECOG_S1_MergeTemp = trialsECOG_S1_Merge;

if ~exist(ICAName, "file")
    [comp, ICs, FigTopoICA, FigWave, FigIC] = ICA_Population(trialsECOG_MergeTemp, fs, Window);
    compT = comp;
    compT.topo(:, ~ismember(1:size(compT.topo, 2), ICs)) = 0;
    trialsECOG_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_MergeTemp, "UniformOutput", false);
    trialsECOG_S1_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_S1_MergeTemp, "UniformOutput", false);
    print(FigWave(2), strcat(ICPATH, "_IC_Rescutction_", protStr), "-djpeg", "-r200");
    print(FigTopoICA, strcat(ICPATH, "_IC_Topo_", protStr), "-djpeg", "-r200");
    print(FigIC, strcat(ICPATH, "_IC_Raw_", protStr), "-djpeg", "-r200");
    close(FigTopoICA);
    close(FigWave);
    close(FigIC);
    save(ICAName, "compT", "comp", "ICs", "-mat");
else
    load(ICAName);
    %         [~, ICs, FigTopoICA] = ICA_Exclude(trialsECOG_MergeTemp, comp, Window);
    trialsECOG_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_MergeTemp, "UniformOutput", false);
    trialsECOG_S1_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_S1_MergeTemp, "UniformOutput", false);
end

%% filter
trialsECOG_Merge_Filtered = ECOGFilter(trialsECOG_Merge, fhp, flp, fs);

%% process across diff devTypes
devType = unique([trialAll.devOrdr]);
% initialize
t = linspace(Window(1), Window(2), diff(Window) /1000 * fs + 1)';
for ch = 1 : 64
    cdrPlot(ch).(strcat(monkeyStr, "info")) = strcat("Ch", num2str(ch));
end
PMean = cell(length(MATPATH), length(devType));
chMean = cell(length(MATPATH), length(devType));
chMeanS1 = cell(length(MATPATH), length(devType));
chMeanFilterd = cell(length(MATPATH), length(devType));
trialsECOGFilterd = cell(length(MATPATH), length(devType));

% process
for dIndex = devType
    tIndex = [trialAll.devOrdr] == dIndex;
    trials = trialAll(tIndex);
    trialsECOG = trialsECOG_Merge(tIndex);
    trialsECOG_S1 = trialsECOG_S1_Merge(tIndex);
    trialsECOGFilterd = trialsECOG_Merge_Filtered(tIndex);

    % FFT during S1
    tIdx = find(t > FFTWin(dIndex, 1) & t < FFTWin(dIndex, 2));
    [ff, PMean{mIndex, dIndex}, trialsFFT]  = trialsECOGFFT(trialsECOG, fs, tIdx, [], 2);

    % raw wave
    chMean{mIndex, dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOG), 'UniformOutput', false));
    chStd = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOG), 'UniformOutput', false));

    % raw wave S1
    chMeanS1{mIndex, dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOG_S1), 'UniformOutput', false));
    chStdS1 = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOG_S1), 'UniformOutput', false));

    % filter
    chMeanFilterd{mIndex, dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOGFilterd), 'UniformOutput', false));
    chStdFilter = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOGFilterd), 'UniformOutput', false));

    % data for corelDraw plot
    for ch = 1 : size(chMean{mIndex, dIndex}, 1)
        cdrPlot(ch).(strcat(monkeyStr, "Wave"))(dIndex).Data(:, 1) = t';
        cdrPlot(ch).(strcat(monkeyStr, "Wave"))(dIndex).Data(:, 2) = chMean{mIndex, dIndex}(ch, :)';
        cdrPlot(ch).(strcat(monkeyStr, "WaveS1"))(dIndex).Data(:, 1) = t';
        cdrPlot(ch).(strcat(monkeyStr, "WaveS1"))(dIndex).Data(:, 2) = chMeanS1{mIndex, dIndex}(ch, :)';
        cdrPlot(ch).(strcat(monkeyStr, "WaveFilted"))(:, 2 * dIndex - 1) = t';
        cdrPlot(ch).(strcat(monkeyStr, "WaveFilted"))(:, 2 * dIndex) = chMeanFilterd{mIndex, dIndex}(ch, :)';
        cdrPlot(ch).(strcat(monkeyStr, "FFT"))(dIndex).Data(:, 1) = ff;
        cdrPlot(ch).(strcat(monkeyStr, "FFT"))(dIndex).Data(:, 2) = PMean{mIndex, dIndex}(ch, :)';
    end



    % quantization
    [temp, amp, rmsSpon]  = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trialsECOG, 'UniformOutput', false);
    ampNorm(dIndex).(strcat(monkeyStr, "_mean")) = cellfun(@mean, changeCellRowNum(temp));
    ampNorm(dIndex).(strcat(monkeyStr, "_se")) = cellfun(@(x) std(x)/sqrt(length(x)), changeCellRowNum(temp));
    ampNorm(dIndex).(strcat(monkeyStr, "_raw")) = changeCellRowNum(temp);
    ampNorm(dIndex).(strcat(monkeyStr, "_amp")) = amp;
    ampNorm(dIndex).(strcat(monkeyStr, "_rmsSpon")) = rmsSpon;

    % quantization latency
    [latency_mean, latency_se, latency_raw] = waveLatency_trough(trialsECOG, Window, latencyWin, 50, fs); %
    % thr = 0.5;
    %         [latency_mean, latency_se, latency_raw] = waveLatency_cumThreshold(trialsECOG, Window, quantWin, thr, fs, sponWin); %
    latency(dIndex).(strcat(monkeyStr, "_mean")) = latency_mean;
    latency(dIndex).(strcat(monkeyStr, "_se")) = latency_se;
    latency(dIndex).(strcat(monkeyStr, "_raw")) = latency_raw;

end

%% significance of s1 onset response
[temp, ampS1, rmsSponS1] = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trialsECOG_S1_Merge, 'UniformOutput', false);
ampNormS1.(strcat(monkeyStr, "_S1_mean")) = cellfun(@mean, changeCellRowNum(temp));
ampNormS1.(strcat(monkeyStr, "_S1_se")) = cellfun(@(x) std(x)/sqrt(length(x)), changeCellRowNum(temp));
ampNormS1.(strcat(monkeyStr, "_S1_raw")) = changeCellRowNum(temp);
% compare S1Res and spon
[S1H, S1P] = cellfun(@(x, y) ttest(x, y), changeCellRowNum(ampS1), changeCellRowNum(rmsSponS1), "UniformOutput", false);


if ~exist(FIGPATH, "dir")
    mkdir(FIGPATH);
end
%% comparison between devTypes_ dev Onset 
for gIndex = 1 : length(group_Index)
    temp = group_Index{gIndex};
    group = [];
    for dIndex  = 1 : length(temp)
        dIdx = temp(dIndex);
        group(dIndex).chMean = chMean{mIndex, dIdx};
        group(dIndex).color = colors(dIndex);
    end
    FigGroup(gIndex) = plotRawWaveMulti_SPR(group, Window);
    addLegend2Fig(FigGroup(gIndex), stimStrs(group_Index{gIndex}));
end

%% comparison between devTypes_ sound Onset
for gIndex = 1 : length(group_Index)
    temp = group_Index{gIndex};
    groupS1 = [];
    for dIndex  = 1 : length(temp)
        dIdx = temp(dIndex);
        groupS1(dIndex).chMean = chMeanS1{mIndex, dIdx};
        groupS1(dIndex).color = colors(dIndex);
    end
    FigGroupS1(gIndex) = plotRawWaveMulti_SPR(groupS1, Window);
    addLegend2Fig(FigGroupS1(gIndex), stimStrs(group_Index{gIndex}));
end

%% scale
scaleAxes([FigGroup, FigGroupS1] , "x", PlotWin);
scaleAxes([FigGroup, FigGroupS1], "y", "on");
for gIndex = 1 : length(FigGroup)
    print(FigGroup(gIndex), strcat(FIGPATH, group_Str(gIndex)), "-djpeg", "-r200");
    close(FigGroup(gIndex));
end
for gIndex = 1 : length(FigGroupS1)
    print(FigGroupS1(gIndex), strcat(FIGPATH, "S1", group_Str(gIndex)), "-djpeg", "-r200");
    close(FigGroupS1(gIndex));
end

% %% plot FFT
% for dIndex = devType
%     FigFFT = plotRawWave(PMean{mIndex, dIndex}, [], [ff(1), ff(end)], strcat("FFT ", stimStrs(dIndex)));
%     deleteLine(FigFFT, "LineStyle", "--");
%     lines(1).X = correspFreq(mIndex, dIndex); lines(1).color = "k";
%     addLines2Axes(FigFFT, lines);
%     orderLine(FigFFT, "LineStyle", "--", "bottom");
% 
%     % rescale FFT Plot
%     scaleAxes(FigFFT, "x", FFTPlotWin);
%     YLIM = scaleAxes(FigFFT, "y", "on");
%     setLine(FigFFT, "YData", YLIM, "LineStyle", "--");
%     pause(1);
%     set(FigFFT, "outerposition", [300, 100, 800, 670]);
%     plotLayout(FigFFT, params.posIndex + 2 * (monkeyId - 1), 0.3);
%     print(FigFFT, strcat(FIGPATH, "_", stimStrs(dIndex),  "_FFT_"), "-djpeg", "-r200");
%     close(FigFFT);
% end


% %% plot Topo
% for dIndex = devType
%     
%     % CRI Topo
%     topo = ampNorm(dIndex).(strcat(monkeyStr, "_mean"));
%     FigTopo = plotTopo_Raw(topo, [8, 8]);
%     colormap(FigTopo, "jet");
% 
%     %% change figure scale
%     scaleAxes(FigTopo, "c", CRIScale(CRIMethod, :));
%        pause(1);
%     set(FigTopo, "outerposition", [300, 100, 800, 670]);
%        print(FigTopo, strcat(FIGPATH,  stimStrs(dIndex),  "_Topo"), "-djpeg", "-r200");
% 
% %     %% p-value of CRI and sponRes
% %     % compare change resp and spon resp
% %     amp = ampNorm(dIndex).(strcat(monkeyStr, "_amp"));
% %     rmsSpon = ampNorm(dIndex).(strcat(monkeyStr, "_rmsSpon"));
% %     [sponH, sponP] = cellfun(@(x, y) ttest(x, y), changeCellRowNum(amp), changeCellRowNum(rmsSpon), "UniformOutput", false);
% % 
% %     % plot p-value topo
% %     topo = logg(pBase, cell2mat(sponP) / pBase);
% %     topo(isinf(topo)) = 5;
% %     topo(topo > 5) = 5;
% %     FigPVal= plotTopo_Raw(topo, [8, 8]);
% %     colormap(FigPVal, "jet");
% %     scaleAxes(FigPVal, "c", [-5 5]);
% %     pause(1);
% %     set(FigPVal, "outerposition", [300, 100, 800, 670]);
% %     %         title("p-value (log(log(0.05, p)) distribution of [0 300] response and baseline");
% % 
% %     print(FigPVal, strcat(FIGPATH, stimStrs(dIndex), "_pValue_Topo_Reg"), "-djpeg", "-r200");
% %     close(FigPVal);
% 
%     drawnow
%     close all
% 
% end



%% Diff ICI amplitude comparison
sigCh= find(cell2mat(S1H));
nSigCh = find(~cell2mat(S1H));

compare.amp_mean_se_S1Sig = [(1:length(devType))', CTL_Compute_Compare(ampNorm, sigCh, devType, monkeyStr)];
compare.amp_mean_se_S1nSig = [(1:length(devType))', CTL_Compute_Compare(ampNorm, nSigCh, devType, monkeyStr)];

%% Diff ICI latency comparison
compare.latency_mean_se_S1Sig = [(1:length(devType))', CTL_Compute_Compare(latency, sigCh, devType, monkeyStr)];
compare.latency_mean_se_S1nSig = [(1:length(devType))', CTL_Compute_Compare(latency, nSigCh, devType, monkeyStr)];


ResName = strcat(FIGPATH, "cdrPlot_", AREANAME, ".mat");
save(ResName, "cdrPlot", "chMean", "Protocol", "compare", "-mat");

