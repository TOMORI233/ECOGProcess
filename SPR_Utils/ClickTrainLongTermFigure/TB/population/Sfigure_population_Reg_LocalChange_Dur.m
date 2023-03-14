close all; clc; clear;
MATPATH{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\TB\Add_on_Reg_Rep1_Dur\';
MATPATH{2} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\TB\Add_on_Reg_Rep1_Dur\';
monkeyStr = ["CC", "XX"];
ROOTPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\Basic\";
params.posIndex = 1; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;
icaOpt = "off";
CRIMethod = 2;
CRIMethodStr = ["Resp_devided_by_Spon", "R_minus_S_devide_R_plus_S"];
CRIScale = {[0.8, 2; -0.1 0.4], [0.8, 2; -0.1 0.5]};
CRITest = [1, 0];

plotWhole = false;
colors = ["#FF0000", "#FFA500", "#0000FF", "#000000"];
AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);
fs = 600;
pBase = 0.01;

selectCh = [13 9];
% badCHs = {[49], [49]};
yScale = [40, 50];
quantWin = [0 300];
sponWin = [-300 0];
tTh = 0.2;
chTh = 0.2;
for mIndex =  1 : length(MATPATH)

    temp = string(split(MATPATH{mIndex}, '\'));
    Protocol = temp(end - 1);
    FIGPATH = strcat(ROOTPATH, "\Pop_Sfigure2_Reg_Insert_Rep1\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");
    mkdir(FIGPATH);

    %% merge population data
    if ~exist(strcat(FIGPATH, "PopulationData.mat"), "file")
        [trialsECOG_Merge, trialsECOG_S1_Merge , ~, ~, trialAll, badCHs] = mergeECOGPreprocess(MATPATH{mIndex}, AREANAME);
        save(strcat(FIGPATH, "PopulationData.mat"), "trialsECOG_S1_Merge", "trialsECOG_Merge", "trialAll", "badCHs");

    else
        load(strcat(FIGPATH, "PopulationData.mat"));
    end

    disp(strcat("bad channels are:", strjoin(string(badCHs), ",")));



    %% ICA
    % align to certain duration
    run("CTLconfig.m");
    ICAName = strcat(FIGPATH, "comp_", AREANAME, ".mat");

    trialsECOG_MergeTemp = trialsECOG_Merge;
    trialsECOG_S1_MergeTemp = trialsECOG_S1_Merge;
    channels = 1 : size(trialsECOG_Merge{1}, 1);
    if ~exist(ICAName, "file")
        chs2doICA = channels;
        chs2doICA(ismember(chs2doICA, badCHs)) = [];
        [comp, ICs, FigTopoICA] = ICA_Population(trialsECOG_MergeTemp, fs, Window, chs2doICA);
        %         temp = validateInput(['Input bad channel number (empty for default: ', num2str(badCHs'), '): '], @(x) validateattributes(x, {'numeric'}, {'2d', 'integer', 'positive'}));
        %         if ~isempty(temp)
        %             badCHs = unique([badCHs; reshape(temp, [numel(temp), 1])]);
        %         end
        compT = comp;
        compT.topo(:, ~ismember(1:size(compT.topo, 2), ICs)) = 0;
        if length(chs2doICA) < length(channels)
            icaOpt = "on";
            trialsECOG_Merge = cellfun(@(x) x(chs2doICA, :), trialsECOG_Merge, "UniformOutput", false);
            trialsECOG_Merge = reconstructData(trialsECOG_Merge, comp, ICs);
            trialsECOG_Merge = cellfun(@(x) insertRows(x, channels(ismember(channels, badCHs) & ~ismember(channels, chs2doICA))), trialsECOG_Merge, "UniformOutput", false);

            trialsECOG_S1_Merge = cellfun(@(x) x(chs2doICA, :), trialsECOG_S1_Merge, "UniformOutput", false);
            trialsECOG_S1_Merge = reconstructData(trialsECOG_S1_Merge, comp, ICs);
            trialsECOG_S1_Merge = cellfun(@(x) insertRows(x, channels(ismember(channels, badCHs) & ~ismember(channels, chs2doICA))), trialsECOG_S1_Merge, "UniformOutput", false);
        else
            trialsECOG_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_MergeTemp, "UniformOutput", false);
            trialsECOG_S1_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_S1_MergeTemp, "UniformOutput", false);
        end
        close(FigTopoICA);
        save(ICAName, "compT", "comp", "ICs", "icaOpt", "chs2doICA", "-mat");
    else
        load(ICAName);
        if strcmpi(icaOpt, "on")
            trialsECOG_Merge = cellfun(@(x) x(chs2doICA, :), trialsECOG_Merge, "UniformOutput", false);
            trialsECOG_Merge = reconstructData(trialsECOG_Merge, comp, ICs);
            trialsECOG_Merge = cellfun(@(x) insertRows(x, channels(ismember(channels, badCHs) & ~ismember(channels, chs2doICA))), trialsECOG_Merge, "UniformOutput", false);

            trialsECOG_S1_Merge = cellfun(@(x) x(chs2doICA, :), trialsECOG_S1_Merge, "UniformOutput", false);
            trialsECOG_S1_Merge = reconstructData(trialsECOG_S1_Merge, comp, ICs);
            trialsECOG_S1_Merge = cellfun(@(x) insertRows(x, channels(ismember(channels, badCHs) & ~ismember(channels, chs2doICA))), trialsECOG_S1_Merge, "UniformOutput", false);
        else
            trialsECOG_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_MergeTemp, "UniformOutput", false);
            trialsECOG_S1_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_S1_MergeTemp, "UniformOutput", false);
        end
    end

    % badCH
    trialsECOG_Merge = interpolateBadChs(trialsECOG_Merge,  badCHs);
    trialsECOG_S1_Merge = interpolateBadChs(trialsECOG_S1_Merge, badCHs);

    %% process
    devType = unique([trialAll.devOrdr]);


    % initialize
    t = linspace(Window(1), Window(2), diff(Window) /1000 * fs + 1)';
    for ch = 1 : 64
        cdrPlot(ch).(strcat(monkeyStr(mIndex), "info")) = strcat("Ch", num2str(ch));
        cdrPlot(ch).(strcat(monkeyStr(mIndex), "Wave")) = zeros(length(t), 2 * length(devType));
    end

    % diff stim type
    for dIndex = 1:length(devType)
        tIndex = [trialAll.devOrdr] == devType(dIndex);
        trials = trialAll(tIndex);
        trialsECOG = trialsECOG_Merge(tIndex);
        chMean{dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOG), 'UniformOutput', false));
        chStd = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOG), 'UniformOutput', false));
        for ch = 1 : size(chMean{dIndex}, 1)
            cdrPlot(ch).(strcat(monkeyStr(mIndex), "Wave"))(:, 2 * dIndex - 1) = t';
            cdrPlot(ch).(strcat(monkeyStr(mIndex), "Wave"))(:, 2 * dIndex) = chMean{dIndex}(ch, :)';
        end

        % quantization
        [temp, amp, rmsSpon]  = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trialsECOG, 'UniformOutput', false);
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_mean")) = cellfun(@mean, changeCellRowNum(temp));
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_se")) = cellfun(@(x) std(x)/sqrt(length(x)), changeCellRowNum(temp));
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_raw")) = changeCellRowNum(temp);
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_amp")) = amp;
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_rmsSpon")) = rmsSpon;
    end

    %% significance of s1 onset response
    [temp, ampS1, rmsSponS1] = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trialsECOG_S1_Merge, 'UniformOutput', false);
    ampNormS1.(strcat(monkeyStr(mIndex), "_S1_mean")) = cellfun(@mean, changeCellRowNum(temp));
    ampNormS1.(strcat(monkeyStr(mIndex), "_S1_se")) = cellfun(@(x) std(x)/sqrt(length(x)), changeCellRowNum(temp));
    ampNormS1.(strcat(monkeyStr(mIndex), "_S1_raw")) = changeCellRowNum(temp);
    % compare S1Res and spon
    [S1H, S1P] = cellfun(@(x, y) ttest(x, y), changeCellRowNum(ampS1), changeCellRowNum(rmsSponS1), "UniformOutput", false);



    %% plot single wave
    for dIndex = 1 : length(devType)
        singleStim.chMean = chMean{dIndex}; singleStim.color = colors(dIndex);
        FigWave(dIndex) = plotRawWaveMulti_SPR(singleStim, Window, stimStr(1), [8, 8]);
    end
    setAxes(FigWave, 'yticklabel', '');
    setAxes(FigWave, 'xticklabel', '');
    setAxes(FigWave, 'visible', 'off');
    setLine(FigWave, "YData", [-yScale(mIndex) yScale(mIndex)], "LineStyle", "--");
    pause(1);
    set(FigWave, "outerposition", [300, 100, 800, 670]);
    scaleAxes(FigWave, "x", [-10 600]);
    plotLayout(FigWave, params.posIndex + 2 * (mIndex - 1), 0.3);
    for dIndex = 1 : length(devType)
        print(FigWave(dIndex), strcat(FIGPATH,  stimStr(dIndex), "_CRI_Wave"), "-djpeg", "-r200");
    end

    % whole wave
    if plotWhole
        for dIndex = 1 : length(devType)
            singleStim.chMean = chMean{dIndex}; singleStim.color = colors(dIndex);
            FigWave_Whole(dIndex) = plotRawWaveMulti_SPR(singleStim, Window, stimStr(1), [8, 8]);
        end
        setAxes(FigWave_Whole, 'yticklabel', '');
        setAxes(FigWave_Whole, 'xticklabel', '');
        setAxes(FigWave_Whole, 'visible', 'off');
        setLine(FigWave_Whole, "YData", [-yScale(mIndex) yScale(mIndex)], "LineStyle", "--");
        pause(1);
        set(FigWave_Whole, "outerposition", [300, 100, 800, 670]);
        scaleAxes(FigWave, "x", [-10 600]);
        plotLayout(FigWave_Whole, params.posIndex + 2 * (mIndex - 1), 0.3);
        for dIndex = 1 : length(devType)
            print(FigWave_Whole(dIndex), strcat(FIGPATH, stimStr(dIndex), "_CRI_Wave_Whole"), "-djpeg", "-r200");
        end
    end


    %% Reg Irreg comparison, for Reg-Irreg tuning and topo
    % ttest between 4ms Reg and 4ms Irreg
    temp1 = ampNorm(1).(strcat(monkeyStr(mIndex), "_raw")); % 4ms Reg
    temp2 = ampNorm(3).(strcat(monkeyStr(mIndex), "_raw")); % 4ms Irreg
    [H, P] = cellfun(@(x, y) ttest2(x, y), temp1, temp2, "UniformOutput", false);

    sigCh{mIndex} = find(cell2mat(S1H));
    nSigCh{mIndex} = find(~cell2mat(S1H));
    %     sigCh{mIndex} = find(cell2mat(H));
    % nSigCh{mIndex} = find(~cell2mat(H));

    compare.info = monkeyStr(mIndex);
    temp = reshape([ampNorm(1).(strcat(monkeyStr(mIndex), "_mean"))'; ampNorm(3).(strcat(monkeyStr(mIndex), "_mean"))';...
        ampNorm(1).(strcat(monkeyStr(mIndex), "_se"))'; ampNorm(3).(strcat(monkeyStr(mIndex), "_se"))'], 2, []) ;
    compare.mean_se = [[1; 2], temp];
    compare.mean_scatter = [[1; 2] [ampNorm(1).(strcat(monkeyStr(mIndex), "_mean"))'; ampNorm(3).(strcat(monkeyStr(mIndex), "_mean"))']];
    compare.H = cell2mat(H);
    compare.P = cell2mat(P);

    temp = reshape([ampNorm(1).(strcat(monkeyStr(mIndex), "_mean"))(sigCh{mIndex})'; ampNorm(3).(strcat(monkeyStr(mIndex), "_mean"))(sigCh{mIndex})';...
        ampNorm(1).(strcat(monkeyStr(mIndex), "_se"))(sigCh{mIndex})'; ampNorm(3).(strcat(monkeyStr(mIndex), "_se"))(sigCh{mIndex})'], 2, []) ;
    compare.selectMean_SE_S1Sig = [[1; 2], temp];

    temp = reshape([ampNorm(1).(strcat(monkeyStr(mIndex), "_mean"))(nSigCh{mIndex})'; ampNorm(3).(strcat(monkeyStr(mIndex), "_mean"))(nSigCh{mIndex})';...
        ampNorm(1).(strcat(monkeyStr(mIndex), "_se"))(nSigCh{mIndex})'; ampNorm(3).(strcat(monkeyStr(mIndex), "_se"))(nSigCh{mIndex})'], 2, []) ;
    compare.selectMean_SE_S1nSig = [[1; 2], temp];

    % plot reg vs irreg topo
    topo = logg(pBase, compare.P / pBase);
    topo(isinf(topo)) = 5;
    topo(topo > 5) = 5;
    FigTopo = plotTopo_Raw(topo, [8, 8]);
    colormap(FigTopo, "jet");
    scaleAxes(FigTopo, "c", [-5, 5]);
    pause(1);
    set(FigTopo, "outerposition", [300, 100, 800, 670]);
    %     title("p-value (log(log(pBase, p)) distribution of Reg vs Irreg");

    print(FigTopo, strcat(FIGPATH, Protocol, "Reg_Irreg_pValue_Topo_Reg"), "-djpeg", "-r200");
    close(FigTopo);

    %% p-value of CRI and sponRes
    for dIndex = [1 3]
        % compare change resp and spon resp
        amp = ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_amp"));
        rmsSpon = ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_rmsSpon"));
        [sponH, sponP] = cellfun(@(x, y) ttest(x, y), changeCellRowNum(amp), changeCellRowNum(rmsSpon), "UniformOutput", false);
        compare.sponRsp(dIndex).info = stimStr(dIndex);
        compare.sponRsp(dIndex).H = sponH;
        compare.sponRsp(dIndex).P = sponP;
        % compare ampNorm and 1
        %         temp = ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_raw"));
        %         OneArray = repmat({ones(length(temp{1}) , 1) * CRITest(CRIMethod)}, length(temp), 1);
        %         [sponH, sponP] = cellfun(@(x, y) ttest2(x, y), temp, OneArray, "UniformOutput", false);

        % plot p-value topo
        topo = logg(pBase, cell2mat(sponP) / pBase);
        topo(isinf(topo)) = 5;
        topo(topo > 5) = 5;
        FigTopo= plotTopo_Raw(topo, [8, 8]);
        colormap(FigTopo, "jet");
        scaleAxes(FigTopo, "c", [-5 5]);
        pause(1);
        set(FigTopo, "outerposition", [300, 100, 800, 670]);
        %         title("p-value (log(log(pBase, p)) distribution of [0 300] response and baseline");
        pause(2);
        print(FigTopo, strcat(FIGPATH, Protocol, "_", stimStr(dIndex), "_pValue_Topo_Reg"), "-djpeg", "-r200");
        close(FigTopo);
    end
    drawnow

    ResName = strcat(FIGPATH, "cdrPlot_", AREANAME, ".mat");
    save(ResName, "cdrPlot", "compare", "chMean", "Protocol", "-mat");
end

close all
