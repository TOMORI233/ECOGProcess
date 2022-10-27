close all; clc; clear;

MATPATH{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Basic_ICIThr\';
MATPATH{2} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\Basic_ICIThr\';
monkeyStr = ["CC", "XX"];
ROOTPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\";
params.posIndex = 1; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;

CRIMethod = 2;
CRIMethodStr = ["Resp_devided_by_Spon", "R_minus_S_devide_R_plus_S"];
CRIScale = [0.8, 2; -0.1 0.6];
CRITest = [1, 0];

colors = ["#000000", "#FFA500", "#0000FF", "#FF0000"];
stimStrs = ["4_4o01", "4_4o03", "4_4o02", "4_4o04"];
cdrPlotIdx = [8, 4, 6, 2];

AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);
fs = 500;

badCh = {[], []};
yScale = [60, 90];
quantWin = [0 300];
sponWin = [-300 0];
latencyWin = [80, 200];
for mIndex = 1 : length(MATPATH)

    temp = string(split(MATPATH{mIndex}, '\'));
    Protocol = temp(end - 1);
    FIGPATH = strcat(ROOTPATH, "Pop_Figure4\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");
    mkdir(FIGPATH);
    %% process
    disp("loading data...");
    tic
    if ~exist(strcat(FIGPATH, "PopulationData.mat"), "file")
        [trialsECOG_Merge, trialsECOG_S1_Merge , ~, ~, trialAll] = mergeECOGPreprocess(MATPATH{mIndex}, AREANAME);
        save(strcat(FIGPATH, "PopulationData.mat"), "trialsECOG_S1_Merge", "trialsECOG_Merge", "trialAll");
    else
        load(strcat(FIGPATH, "PopulationData.mat"));
    end
    toc
    % align to certain duration
    run("CTLconfig.m");

    devType = unique([trialAll.devOrdr]);

    % initialize
    t = linspace(Window(1), Window(2), diff(Window) /1000 * fs + 1)';
    for ch = 1 : 64
        cdrPlot(ch).(strcat(monkeyStr(mIndex), "info")) = strcat("Ch", num2str(ch));
        cdrPlot(ch).(strcat(monkeyStr(mIndex), "Wave")) = zeros(length(t), 2 * length(devType));
    end


    %% diff stim type
    for dIndex = 1:length(devType)
        tIndex = [trialAll.devOrdr] == devType(dIndex);
        trials = trialAll(tIndex);
        trialsECOG = trialsECOG_Merge(tIndex);

        chMean{dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOG), 'UniformOutput', false));
        chStd = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOG), 'UniformOutput', false));
        for ch = 1 : size(chMean{dIndex}, 1)
            cdrPlot(ch).(strcat(monkeyStr(mIndex), "Wave"))(:, 2 * dIndex - 1) = t';
            cdrPlot(ch).(strcat(monkeyStr(mIndex), "Wave"))(:, cdrPlotIdx(dIndex)) = chMean{dIndex}(ch, :)';
        end

        % quantization amplitude
        [temp, amp, rmsSpon] = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trialsECOG, 'UniformOutput', false);
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_mean")) = cellfun(@mean, changeCellRowNum(temp));
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_se")) = cellfun(@(x) std(x)/sqrt(length(x)), changeCellRowNum(temp));
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_raw")) = changeCellRowNum(temp);
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_amp")) = amp;
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_rmsSpon")) = rmsSpon;

        % quantization latency
        [latency_mean, latency_se, latency_raw] = waveLatency_trough(trialsECOG, Window, latencyWin, 50, fs); %        latency(dIndex).(strcat(monkeyStr(mIndex), "_mean")) = latency_mean;
        latency(dIndex).(strcat(monkeyStr(mIndex), "_mean")) = latency_mean;
        latency(dIndex).(strcat(monkeyStr(mIndex), "_se")) = latency_se;
        latency(dIndex).(strcat(monkeyStr(mIndex), "_raw")) = latency_raw;

        RegRatio(dIndex).chMean = chMean{dIndex}; RegRatio(dIndex).color = colors(dIndex);
        %% CRI topo
        topo_Reg = ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_mean"));
        if ~isempty(badCh{mIndex})
            topo_Reg(badCh{mIndex}) = CRITest(CRIMethod);
        end
        FigTopo(dIndex) = plotTopo_Raw(topo_Reg, [8, 8]);
        colormap(FigTopo(dIndex), "jet");
        scaleAxes(FigTopo(dIndex), "c", CRIScale(CRIMethod, :));
        set(FigTopo(dIndex), "outerposition", [300, 100, 800, 670]);
        print(FigTopo(dIndex), strcat(FIGPATH,  Protocol, "_", stimStrs(dIndex), "_Topo_Reg"), "-djpeg", "-r200");



    end

    %% significance of s1 onset response
    [temp, ampS1, rmsSponS1] = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trialsECOG_S1_Merge, 'UniformOutput', false);
    ampNormS1.(strcat(monkeyStr(mIndex), "_S1_mean")) = cellfun(@mean, changeCellRowNum(temp));
    ampNormS1.(strcat(monkeyStr(mIndex), "_S1_se")) = cellfun(@(x) std(x)/sqrt(length(x)), changeCellRowNum(temp));
    ampNormS1.(strcat(monkeyStr(mIndex), "_S1_raw")) = changeCellRowNum(temp);
    % compare S1Res and spon
    [S1H, S1P] = cellfun(@(x, y) ttest(x, y), changeCellRowNum(ampS1), changeCellRowNum(rmsSponS1), "UniformOutput", false);

    %% plot rawWave
    FigWave(mIndex) = plotRawWaveMulti_SPR(RegRatio, Window, titleStr, [8, 8]);
    scaleAxes(FigWave(mIndex), "y", [-yScale(mIndex) yScale(mIndex)]);
    scaleAxes(FigWave(mIndex), "x", [-10 600]);
    setAxes(FigWave(mIndex), 'yticklabel', '');
    setAxes(FigWave(mIndex), 'xticklabel', '');
    setAxes(FigWave(mIndex), 'visible', 'off');
    setLine(FigWave(mIndex), "YData", [-yScale(mIndex) yScale(mIndex)], "LineStyle", "--");
    set(FigWave(mIndex), "outerposition", [300, 100, 800, 670]);
    plotLayout(FigWave, params.posIndex + 2 * (mIndex - 1), 0.3);

    print(FigWave(mIndex), strcat(FIGPATH, Protocol, "_Wave"), "-djpeg", "-r200");



    %% p-value of CRI and sponRes
    for dIndex = 1:length(devType)
        % compare change resp and spon resp
        amp = ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_amp"));
        rmsSpon = ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_rmsSpon"));
        [sponH{dIndex}, sponP{dIndex}] = cellfun(@(x, y) ttest(x, y), changeCellRowNum(amp), changeCellRowNum(rmsSpon), "UniformOutput", false);%         % compare ampNorm and 1
        %         temp = ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_raw"));
        %         OneArray = repmat({ones(length(temp{1}), 1) * CRITest(CRIMethod)}, length(temp), 1);
        %         [sponH{dIndex}, sponP{dIndex}] = cellfun(@(x, y) ttest2(x, y), temp, OneArray, "UniformOutput", false);

        % plot p-value topo
        topo = logg(0.05, cell2mat(sponP{dIndex}) / 0.05);
        topo(isinf(topo)) = 5;
        topo(topo > 5) = 5;
        FigTopo= plotTopo_Raw(topo, [8, 8]);
        colormap(FigTopo, "jet");
        scaleAxes(FigTopo, "c", [-5 5]);
        set(FigTopo, "outerposition", [300, 100, 800, 670]);
        %         title("p-value (log(log(0.05, p)) distribution of [0 300] response and baseline");
        print(FigTopo, strcat(FIGPATH, Protocol, "_", stimStrs(dIndex), "_pValue_Topo_Reg"), "-djpeg", "-r200");
        close(FigTopo);
    end




    %% Diff ICI amplitude comparison
    sigCh= find(cell2mat(S1H));
    nSigCh = find(~cell2mat(S1H));
    %     sigCh = find(cell2mat(H));
    % nSigCh = find(~cell2mat(H));

    temp = reshape([ampNorm(1).(strcat(monkeyStr(mIndex), "_mean"))(sigCh)'; ampNorm(3).(strcat(monkeyStr(mIndex), "_mean"))(sigCh)';...
        ampNorm(2).(strcat(monkeyStr(mIndex), "_mean"))(sigCh)'; ampNorm(4).(strcat(monkeyStr(mIndex), "_mean"))(sigCh)';...
        ampNorm(1).(strcat(monkeyStr(mIndex), "_se"))(sigCh)'; ampNorm(3).(strcat(monkeyStr(mIndex), "_se"))(sigCh)';...
        ampNorm(2).(strcat(monkeyStr(mIndex), "_se"))(sigCh)'; ampNorm(4).(strcat(monkeyStr(mIndex), "_se"))(sigCh)'], 4, []) ;
    compare.amp_mean_se_S1Sig = [[1; 2; 3; 4], temp];

    temp = reshape([ampNorm(1).(strcat(monkeyStr(mIndex), "_mean"))(nSigCh)'; ampNorm(3).(strcat(monkeyStr(mIndex), "_mean"))(nSigCh)';...
        ampNorm(2).(strcat(monkeyStr(mIndex), "_mean"))(nSigCh)'; ampNorm(4).(strcat(monkeyStr(mIndex), "_mean"))(nSigCh)';...
        ampNorm(1).(strcat(monkeyStr(mIndex), "_se"))(nSigCh)'; ampNorm(3).(strcat(monkeyStr(mIndex), "_se"))(nSigCh)';...
        ampNorm(2).(strcat(monkeyStr(mIndex), "_se"))(nSigCh)'; ampNorm(4).(strcat(monkeyStr(mIndex), "_se"))(nSigCh)'], 4, []) ;
    compare.amp_mean_se_S1nSig = [[1; 2; 3; 4], temp];

    %% Diff ICI latency comparison

    temp = reshape([latency(1).(strcat(monkeyStr(mIndex), "_mean"))(sigCh)'; latency(3).(strcat(monkeyStr(mIndex), "_mean"))(sigCh)';...
        latency(2).(strcat(monkeyStr(mIndex), "_mean"))(sigCh)'; latency(4).(strcat(monkeyStr(mIndex), "_mean"))(sigCh)';...
        latency(1).(strcat(monkeyStr(mIndex), "_se"))(sigCh)'; latency(3).(strcat(monkeyStr(mIndex), "_se"))(sigCh)';...
        latency(2).(strcat(monkeyStr(mIndex), "_se"))(sigCh)'; latency(4).(strcat(monkeyStr(mIndex), "_se"))(sigCh)'], 4, []) ;
    compare.latency_mean_se_S1Sig = [[1; 2; 3; 4], temp];

    temp = reshape([latency(1).(strcat(monkeyStr(mIndex), "_mean"))(nSigCh)'; latency(3).(strcat(monkeyStr(mIndex), "_mean"))(nSigCh)';...
        latency(2).(strcat(monkeyStr(mIndex), "_mean"))(nSigCh)'; latency(4).(strcat(monkeyStr(mIndex), "_mean"))(nSigCh)';...
        latency(1).(strcat(monkeyStr(mIndex), "_se"))(nSigCh)'; latency(3).(strcat(monkeyStr(mIndex), "_se"))(nSigCh)';...
        latency(2).(strcat(monkeyStr(mIndex), "_se"))(nSigCh)'; latency(4).(strcat(monkeyStr(mIndex), "_se"))(nSigCh)'], 4, []) ;
    compare.latency_mean_se_S1nSig = [[1; 2; 3; 4], temp];

    %% latency topo

    for dIndex = 1:length(devType)
        sigCh = cell2mat(sponH{dIndex}) == 1;
        topo_Latency = latency(dIndex).(strcat(monkeyStr(mIndex), "_mean"));
        if ~isempty(badCh{mIndex})
            topo_Latency(badCh{mIndex}) = quantWin(2);
        end
        topo_Latency(~sigCh) = quantWin(2);
        topo_Latency = ((quantWin(2) - topo_Latency)/quantWin(2)).^2;
        FigTopo_Latency(dIndex) = plotTopo_Raw(topo_Latency, [8, 8]);
        colormap(FigTopo_Latency(dIndex), "jet");
        scaleAxes(FigTopo_Latency(dIndex), "c", [0 0.5]);
        set(FigTopo_Latency(dIndex), "outerposition", [300, 100, 800, 670]);
        print(FigTopo_Latency(dIndex), strcat(FIGPATH,  Protocol, "_", stimStrs(dIndex), "_Latency_Topo_Reg"), "-djpeg", "-r200");
    end

    drawnow

end

close all
