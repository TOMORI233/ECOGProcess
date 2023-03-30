    %% merge population data
    if ~exist(strcat(FIGPATH, "PopulationData.mat"), "file")
        [trialsECOG_Merge, trialsECOG_S1_Merge , ~, ~, trialAll] = mergeECOGPreprocess(MATPATH{mIndex}, AREANAME);
        save(strcat(FIGPATH, "PopulationData.mat"), "trialsECOG_S1_Merge", "trialsECOG_Merge", "trialAll");
    else
        load(strcat(FIGPATH, "PopulationData.mat"));
    end

    %% ICA
    % align to certain duration
    run("CTLconfig.m");
    ICAName = strcat(FIGPATH, "comp_", AREANAME, ".mat");
    
    trialsECOG_MergeTemp = trialsECOG_Merge;
    trialsECOG_S1_MergeTemp = trialsECOG_S1_Merge;
    if ~exist(ICAName, "file")
        [comp, ICs, FigTopoICA] = ICA_Population(trialsECOG_MergeTemp, fs, Window);
        compT = comp;
        compT.topo(:, ~ismember(1:size(compT.topo, 2), ICs)) = 0;
        trialsECOG_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_MergeTemp, "UniformOutput", false);
        trialsECOG_S1_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_S1_MergeTemp, "UniformOutput", false);
        close(FigTopoICA);
        save(ICAName, "compT", "comp", "ICs", "-mat");
    else
        load(ICAName);
        trialsECOG_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_MergeTemp, "UniformOutput", false);
        trialsECOG_S1_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_S1_MergeTemp, "UniformOutput", false);
    end

    

    %% Patch
    temp = changeCellRowNum(trialsECOG_Merge);
    temp = temp(ECOGSitePatch(AREANAME));
    trialsECOG_Merge = changeCellRowNum(temp);
    trialsECOG_Merge = interpolateBadChs(trialsECOG_Merge, badCHs{mIndex});

    temp = changeCellRowNum(trialsECOG_S1_Merge);
    temp = temp(ECOGSitePatch(AREANAME));
    trialsECOG_S1_Merge = changeCellRowNum(temp);
    trialsECOG_S1_Merge = interpolateBadChs(trialsECOG_S1_Merge, badCHs{mIndex});
    %% 
           

%% process
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
            cdrPlot(ch).(strcat(monkeyStr(mIndex), "Wave"))(:, cdrPlotIdx(dIndex) - 1) = t';
            cdrPlot(ch).(strcat(monkeyStr(mIndex), "Wave"))(:, cdrPlotIdx(dIndex)) = chMean{dIndex}(ch, :)';
        end

        %% quantization latency
        % %         [latency_mean, latency_se, latency_raw]  = Latency_Jackknife(trialsECOG, Window, chNP, latencyWin, 1, "Method","FAL", "fraction", 0.5, "thrFrac", 0.3);
        [latency_mean, latency_se, latency_raw]  = Latency_Jackknife(trialsECOG, Window, chNP, latencyWin, 1, "Method","AVL");

        %         [latency_mean, latency_se, latency_raw] = waveLatency_trough(trialsECOG, Window, latencyWin, 50, fs); %        latency(dIndex).(strcat(monkeyStr(mIndex), "_mean")) = latency_mean;
        latency(dIndex).(strcat(monkeyStr(mIndex), "_mean")) = latency_mean;
        latency(dIndex).(strcat(monkeyStr(mIndex), "_se")) = latency_se;
        latency(dIndex).(strcat(monkeyStr(mIndex), "_raw")) = latency_raw;


        % quantization
        [temp, amp, rmsSpon]  = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trialsECOG, 'UniformOutput', false);
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_mean")) = cellfun(@mean, changeCellRowNum(temp));
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_se")) = cellfun(@(x) std(x)/sqrt(length(x)), changeCellRowNum(temp));
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_raw")) = changeCellRowNum(temp);
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_amp")) = amp;
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_rmsSpon")) = rmsSpon;

        %% CRI topo
        topo_Reg = ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_mean"));
        FigTopo(dIndex) = plotTopo_Raw(topo_Reg, [8, 8]);
        colormap(FigTopo(dIndex), "jet");
        scaleAxes(FigTopo(dIndex), "c", CRIScale{mIndex}(CRIMethod, :));
        pause(1);
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
           