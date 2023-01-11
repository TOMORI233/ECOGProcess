close all; clc; clear;

monkeyId = 1;  % 1：chouchou; 2：xiaoxiao

if monkeyId == 1
    MATPATH{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Rhythm_Ratio_ICI24\cc20221103\cc20221103_AC.mat';
    MATPATH{2} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Rhythm_Ratio_ICI36\cc20221103\cc20221103_AC.mat';
    MATPATH{3} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Rhythm_Ratio_ICI48\cc20221103\cc20221103_AC.mat';

elseif monkeyId == 2

end

stimSelect = 5; % "control", "1o1", "1o5", "2", "3", "8", "offset"
selectCh = 9;
stimStrs = ["control", "1o1", "1o5", "2", "3", "8", "offset"];

protStr = ["ICI24", "ICI36", "ICI48"];
ROOTPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\Rhythm\";
params.posIndex = 1; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;

CRIMethod = 2;
CRIMethodStr = ["Resp_devided_by_Spon", "R_minus_S_devide_R_plus_S"];
CRIScale = [0.8, 2; -0.1 0.5];
CRITest = [1, 0];
pBase = 0.01;

% colors = ["#FF0000", "#FFA500", "#0000FF", "#000000", "#AAAAAA"];
% colors = ["#AAAAAA", "#000000", "#0000FF", "#FFA500", "#FF0000"];
colors = ["#0000FF", "#FFA500", "#FF0000"];
AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);
fs = 500;

badCh = {[], []};
yScale = [50, 40];
quantWin = [0 300];
sponWin = [-300 0];
latencyWin = [80 200];
correspFreq = 1000./([24, 36, 48]' * [1, 1.1, 1.5, 2, 2.5, ]);
for mIndex = 1 : length(MATPATH)
    disp(strcat("processing ", protStr(mIndex), "..."));
    temp = string(split(MATPATH{mIndex}, '\'));
    Protocol = temp(end - 2);
    Protocols(mIndex) = Protocol;
    FIGPATH = strcat(ROOTPATH, "Figure3\", CRIMethodStr(CRIMethod), "\", temp(4), "\");
    mkdir(FIGPATH);
    %% process
    tic
    [trialAll, trialsECOG_Merge, trialsECOG_S1_Merge] =  mergeCTLTrialsECOG(MATPATH{mIndex}, params.posIndex);
    toc

    %% ICA
    % align to certain duration
    run("CTLconfig.m");


    FFTWin = [-2900 -100];
    ICAName = strcat(FIGPATH, "comp_", AREANAME, "_", protStr(mIndex), ".mat");
    trialsECOG_MergeTemp = trialsECOG_Merge;
    trialsECOG_S1_MergeTemp = trialsECOG_S1_Merge;

    if ~exist(ICAName, "file")
        [comp, ICs, FigTopoICA, FigWave] = ICA_Population(trialsECOG_MergeTemp, fs, Window);
        compT = comp;
        compT.topo(:, ~ismember(1:size(compT.topo, 2), ICs)) = 0;
        trialsECOG_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_MergeTemp, "UniformOutput", false);
        trialsECOG_S1_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_S1_MergeTemp, "UniformOutput", false);
        close(FigTopoICA);
        close(FigWave);
        save(ICAName, "compT", "comp", "ICs", "-mat");
    else
        load(ICAName);
%         [~, ICs, FigTopoICA] = ICA_Exclude(trialsECOG_MergeTemp, comp, Window);
        trialsECOG_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_MergeTemp, "UniformOutput", false);
        trialsECOG_S1_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_S1_MergeTemp, "UniformOutput", false);
    end

    %% process
    devType = unique([trialAll.devOrdr]);

    % initialize
    t = linspace(Window(1), Window(2), diff(Window) /1000 * fs + 1)';
    for ch = 1 : 64
        cdrPlot(ch).(strcat(protStr(mIndex), "info")) = strcat("Ch", num2str(ch));
        cdrPlot(ch).(strcat(protStr(mIndex), "Wave")) = zeros(length(t), 2 * length(devType));
    end

    %% diff stim type
    for dIndex = 1:length(devType)
        tIndex = [trialAll.devOrdr] == devType(dIndex);
        trials = trialAll(tIndex);
        trialsECOG = trialsECOG_Merge(tIndex);

        chMean{mIndex, dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOG), 'UniformOutput', false));
        chStd = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOG), 'UniformOutput', false));
        % FFT during S1
        tIdx = find(t > FFTWin(1) & t < FFTWin(2));
        [ff, PMean{mIndex, dIndex}, trialsFFT]  = trialsECOGFFT(trialsECOG, fs, tIdx, [], 2);
        for ch = 1 : size(chMean{mIndex, dIndex}, 1)
            cdrPlot(ch).(strcat(protStr(mIndex), "Wave"))(:, 2 * dIndex - 1) = t';
            cdrPlot(ch).(strcat(protStr(mIndex), "Wave"))(:, 2 * dIndex) = chMean{mIndex, dIndex}(ch, :)';
            cdrPlot(ch).(strcat(protStr(mIndex), "FFT"))(:, 2 * dIndex - 1) =ff;
            cdrPlot(ch).(strcat(protStr(mIndex), "FFT"))(:, 2 * dIndex) = PMean{mIndex, dIndex}(ch, :)';
        end

        % quantization amplitude
        [temp, amp, rmsSpon] = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trialsECOG, 'UniformOutput', false);
        ampNorm(dIndex).(strcat(protStr(mIndex), "_mean")) = cellfun(@mean, changeCellRowNum(temp));
        ampNorm(dIndex).(strcat(protStr(mIndex), "_se")) = cellfun(@(x) std(x)/sqrt(length(x)), changeCellRowNum(temp));
        ampNorm(dIndex).(strcat(protStr(mIndex), "_raw")) = changeCellRowNum(temp);
        ampNorm(dIndex).(strcat(protStr(mIndex), "_amp")) = amp;
        ampNorm(dIndex).(strcat(protStr(mIndex), "_rmsSpon")) = rmsSpon;

        % quantization latency
        [latency_mean, latency_se, latency_raw] = waveLatency_trough(trialsECOG, Window, latencyWin, 50, fs); %
        % thr = 0.5;
        %         [latency_mean, latency_se, latency_raw] = waveLatency_cumThreshold(trialsECOG, Window, quantWin, thr, fs, sponWin); %
        latency(dIndex).(strcat(protStr(mIndex), "_mean")) = latency_mean;
        latency(dIndex).(strcat(protStr(mIndex), "_se")) = latency_se;
        latency(dIndex).(strcat(protStr(mIndex), "_raw")) = latency_raw;


    end



    %% significance of s1 onset response
    [temp, ampS1{mIndex}, rmsSponS1{mIndex}] = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trialsECOG_S1_Merge, 'UniformOutput', false);
    ampNormS1.(strcat(protStr(mIndex), "_S1_mean")) = cellfun(@mean, changeCellRowNum(temp));
    ampNormS1.(strcat(protStr(mIndex), "_S1_se")) = cellfun(@(x) std(x)/sqrt(length(x)), changeCellRowNum(temp));
    ampNormS1.(strcat(protStr(mIndex), "_S1_raw")) = changeCellRowNum(temp);
    % compare S1Res and spon
    [S1H{mIndex}, S1P{mIndex}] = cellfun(@(x, y) ttest2(x, y), changeCellRowNum(ampS1{mIndex}), changeCellRowNum(rmsSponS1{mIndex}), "UniformOutput", false);

end

    %% plot FFT
for mIndex = 1 : length(MATPATH)
    for dIndex = 1 : length(devType)
    FigFFT = plotRawWave(PMean{mIndex, dIndex}, [], [ff(1), ff(end)], strcat("FFT ", stimStrs(dIndex)));
    deleteLine(FigFFT, "LineStyle", "--");
    lines(1).X = correspFreq(mIndex, dIndex); lines(1).color = "k";
    addLines2Axes(FigFFT, lines);
    orderLine(FigFFT, "LineStyle", "--", "bottom");
    % rescale FFT Plot
    scaleAxes(FigFFT, "y", [0 400]);
    scaleAxes(FigFFT, "x", [0 150]);
    setAxes(FigFFT, 'yticklabel', '');
    setAxes(FigFFT, 'xticklabel', '');
    setAxes(FigFFT, 'visible', 'off');
    setLine(FigFFT, "YData", [0 400], "LineStyle", "--");
    pause(1);
    set(FigFFT, "outerposition", [300, 100, 800, 670]);
    plotLayout(FigFFT, params.posIndex + 2 * (monkeyId - 1), 0.3);
%     print(FigFFT, strcat(FIGPATH, Protocols(mIndex), "_FFT_", stimStrs(dIndex)), "-djpeg", "-r200");
%     close(FigFFT);
    end
end


%% plot raw wave
for dIndex = 1 : length(devType)
    DiffICI = [];
    for mIndex = 1 : length(MATPATH)
        % for raw wave
        DiffICI(mIndex).chMean = chMean{mIndex, dIndex};
        DiffICI(mIndex).color = colors(mIndex);
    end
        FigWave = plotRawWaveMulti_SPR(DiffICI, Window, titleStr, [8, 8]);
        scaleAxes(FigWave, "y", [-yScale(monkeyId) yScale(monkeyId)]);
        scaleAxes(FigWave, "x", [-1000 600]);
        setAxes(FigWave, 'yticklabel', '');
        setAxes(FigWave, 'xticklabel', '');
        setAxes(FigWave, 'visible', 'off');
        setLine(FigWave, "YData", [-yScale(monkeyId) yScale(monkeyId)], "LineStyle", "--");
        pause(1);
        set(FigWave, "outerposition", [300, 100, 800, 670]);
        plotLayout(FigWave, params.posIndex + 2 * (monkeyId - 1), 0.3);
%         print(FigWave, strcat(FIGPATH, Protocols(mIndex), "_Wave_", stimStrs(dIndex)), "-djpeg", "-r200");
%         close(FigWave);
end



%% p-value of different base ICI
toPlot_Wave = zeros(length(t), 2 * length(MATPATH));

for mIndex = 1 : length(MATPATH)

    %% plot  CRI value topo
    topo = ampNorm(stimSelect).(strcat(protStr(mIndex), "_mean"));
    if ~isempty(badCh{monkeyId})
        topo(badCh{monkeyId}) = CRITest(CRIMethod);
    end
    FigTopo = plotTopo_Raw(topo, [8, 8]);
    colormap(FigTopo, "jet");
    scaleAxes(FigTopo, "c", CRIScale(CRIMethod, :));
    pause(1);
    set(FigTopo, "outerposition", [300, 100, 800, 670]);
    print(FigTopo, strcat(FIGPATH, "_CRI_Topo_", protStr(mIndex), "_", stimStrs(stimSelect)), "-djpeg", "-r200");
    close(FigTopo);



    toPlot_Wave(:, [2 * mIndex - 1, 2 * mIndex]) = cdrPlot(selectCh).(strcat(protStr(mIndex), "Wave"))(:, [2 * stimSelect - 1, 2 * stimSelect]);

    % compare change resp and spon resp
    amp = ampNorm(1).(strcat(protStr(mIndex), "_amp"));
    rmsSpon = ampNorm(1).(strcat(protStr(mIndex), "_rmsSpon"));
    [sponH{mIndex}, sponP{mIndex}] = cellfun(@(x, y) ttest(x, y), changeCellRowNum(amp), changeCellRowNum(rmsSpon), "UniformOutput", false);

    % compare ampNorm and 1
    %     temp = ampNorm(stimSelect).(strcat(protStr(mIndex), "_raw"));
    %     OneArray = repmat({ones(length(temp{1}), 1) * CRITest(CRIMethod)}, length(temp), 1);
    %     [sponH{mIndex}, sponP{mIndex}] = cellfun(@(x, y) ttest2(x, y), temp, OneArray, "UniformOutput", false);

    % plot p-value topo
    topo = logg(pBase, cell2mat(sponP{mIndex}) / pBase);
    topo(isinf(topo)) = 5;
    topo(topo > 5) = 5;
    FigTopo(mIndex) = plotTopo_Raw(topo, [8, 8]);
    colormap(FigTopo(mIndex), "jet");
    scaleAxes(FigTopo(mIndex), "c", [-5 5]);
    pause(1);
    set(FigTopo(mIndex), "outerposition", [300, 100, 800, 670]);
    print(FigTopo(mIndex), strcat(FIGPATH, "_pValue_Topo_", protStr(mIndex), "_", stimStrs(stimSelect)), "-djpeg", "-r200");
end




% %% Diff ICI amplitude comparison
% sigCh = find(cell2mat(S1H{1}));
% nSigCh = find(~cell2mat(S1H{1}));
% 
% temp = reshape([ampNorm(stimSelect).(strcat(protStr(1), "_mean"))(sigCh)'; ampNorm(stimSelect).(strcat(protStr(2), "_mean"))(sigCh)';...
%     ampNorm(stimSelect).(strcat(protStr(3), "_mean"))(sigCh)'; ampNorm(stimSelect).(strcat(protStr(4), "_mean"))(sigCh)';...
%     ampNorm(stimSelect).(strcat(protStr(5), "_mean"))(sigCh)'; ampNorm(stimSelect).(strcat(protStr(1), "_se"))(sigCh)';...
%     ampNorm(stimSelect).(strcat(protStr(2), "_se"))(sigCh)'; ampNorm(stimSelect).(strcat(protStr(3), "_se"))(sigCh)';...
%     ampNorm(stimSelect).(strcat(protStr(4), "_se"))(sigCh)'; ampNorm(stimSelect).(strcat(protStr(5), "_se"))(sigCh)'], 5, []) ;
% compare.amp_mean_se_S1Sig = [[1; 2; 3; 4; 5], temp];
% 
% temp = reshape([ampNorm(stimSelect).(strcat(protStr(1), "_mean"))(nSigCh)'; ampNorm(stimSelect).(strcat(protStr(2), "_mean"))(nSigCh)';...
%     ampNorm(stimSelect).(strcat(protStr(3), "_mean"))(nSigCh)'; ampNorm(stimSelect).(strcat(protStr(4), "_mean"))(nSigCh)';...
%     ampNorm(stimSelect).(strcat(protStr(5), "_mean"))(nSigCh)'; ampNorm(stimSelect).(strcat(protStr(1), "_se"))(nSigCh)';...
%     ampNorm(stimSelect).(strcat(protStr(2), "_se"))(nSigCh)'; ampNorm(stimSelect).(strcat(protStr(3), "_se"))(nSigCh)';...
%     ampNorm(stimSelect).(strcat(protStr(4), "_se"))(nSigCh)'; ampNorm(stimSelect).(strcat(protStr(5), "_se"))(nSigCh)'], 5, []) ;
% compare.amp_mean_se_S1nSig = [[1; 2; 3; 4; 5], temp];
% 
% %% Diff ICI latency comparison
% sigCh = find(cell2mat(S1H{1}));
% nSigCh = find(~cell2mat(S1H{1}));
% 
% temp = reshape([latency(stimSelect).(strcat(protStr(1), "_mean"))(sigCh)'; latency(stimSelect).(strcat(protStr(2), "_mean"))(sigCh)';...
%     latency(stimSelect).(strcat(protStr(3), "_mean"))(sigCh)'; latency(stimSelect).(strcat(protStr(4), "_mean"))(sigCh)';...
%     latency(stimSelect).(strcat(protStr(5), "_mean"))(sigCh)'; latency(stimSelect).(strcat(protStr(1), "_se"))(sigCh)';...
%     latency(stimSelect).(strcat(protStr(2), "_se"))(sigCh)'; latency(stimSelect).(strcat(protStr(3), "_se"))(sigCh)';...
%     latency(stimSelect).(strcat(protStr(4), "_se"))(sigCh)'; latency(stimSelect).(strcat(protStr(5), "_se"))(sigCh)'], 5, []) ;
% compare.latency_mean_se_S1Sig = [[1; 2; 3; 4; 5], temp];
% 
% temp = reshape([latency(stimSelect).(strcat(protStr(1), "_mean"))(nSigCh)'; latency(stimSelect).(strcat(protStr(2), "_mean"))(nSigCh)';...
%     latency(stimSelect).(strcat(protStr(3), "_mean"))(nSigCh)'; latency(stimSelect).(strcat(protStr(4), "_mean"))(nSigCh)';...
%     latency(stimSelect).(strcat(protStr(5), "_mean"))(nSigCh)'; latency(stimSelect).(strcat(protStr(1), "_se"))(nSigCh)';...
%     latency(stimSelect).(strcat(protStr(2), "_se"))(nSigCh)'; latency(stimSelect).(strcat(protStr(3), "_se"))(nSigCh)';...
%     latency(stimSelect).(strcat(protStr(4), "_se"))(nSigCh)'; latency(stimSelect).(strcat(protStr(5), "_se"))(nSigCh)'], 5, []) ;
% compare.latency_mean_se_S1nSig = [[1; 2; 3; 4; 5], temp];


% %% plot latency value topo
% for mIndex = 1 : length(MATPATH)
%     sigCh = cell2mat(sponH{mIndex}) == 1;
%     %         latency(stimSelect).(strcat(protStr(mIndex), "_mean"))(~ismember(1 : 64, sigCh)) = quantWin(2);
%     %         latency(stimSelect).(strcat(protStr(mIndex), "_se"))(~ismember(1 : 64, sigCh)) = 0;
%     topo = latency(stimSelect).(strcat(protStr(mIndex), "_mean"));
%     if ~isempty(badCh{monkeyId})
%         topo(badCh{monkeyId}) = quantWin(2);
%     end
%     topo(~sigCh) = quantWin(2);
%     topo = ((quantWin(2) - topo)/quantWin(2)).^2;
%     FigTopo = plotTopo_Raw(topo, [8, 8]);
%     colormap(FigTopo, "jet");
%     scaleAxes(FigTopo, "c", [0 0.5]);
%     pause(1);
%     set(FigTopo, "outerposition", [300, 100, 800, 670]);
%     print(FigTopo, strcat(FIGPATH, "_latency_Topo_", protStr(mIndex), "_", stimStrs(stimSelect)), "-djpeg", "-r200");
%     close(FigTopo);
% end

% ResName = strcat(FIGPATH, "cdrPlot_", AREANAME, ".mat");
% save(ResName, "cdrPlot", "compare", "chMean", "Protocol", "-mat");
% clearvars -except toPlot_Wave compare sigch cdrPlot ampNorm latency temp
close all
