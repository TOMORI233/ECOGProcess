close all; clc; clear;

MATPATH{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Add_on_Basic_NormSqrt_ICI4\';
MATPATH{2} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\Add_on_Basic_NormSqrt_ICI4\';
monkeyStr = ["CC", "XX"];
ROOTPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\";
params.posIndex = 1; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;

CRIMethod = 2;
CRIMethodStr = ["Resp_devided_by_Spon", "R_minus_S_devide_R_plus_S"];
CRIScale = [0.8, 2; -0.1 0.7];
CRITest = [1, 0];

colors = ["#FF0000", "#FFA500", "#0000FF", "#000000"];

AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);
fs = 500;
pBase = 0.01;

selectCh = [13 9];
badCh = {[], []};
yScale = [50, 90];
quantWin = [0 300];
sponWin = [-300 0];
for mIndex =  1 : length(MATPATH)
 
    temp = string(split(MATPATH{mIndex}, '\'));
    Protocol = temp(end - 1);
    FIGPATH = strcat(ROOTPATH, "\Pop_Sfigure2_Norm_Sqrt\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");
    mkdir(FIGPATH);
    
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
                


    %% plot rawWave
    FigWave_Reg(mIndex) = plotRawWave(chMean{1}, [], Window, titleStr, [8, 8]);
    FigWave_Irreg(mIndex) = plotRawWave(chMean{3}, [], Window, titleStr, [8, 8]);
    FigWave_Whole_Reg(mIndex) = plotRawWave(chMean{1}, [], Window, titleStr, [8, 8]);
    FigWave_Whole_Irreg(mIndex) = plotRawWave(chMean{3}, [], Window, titleStr, [8, 8]);
    setLine([FigWave_Whole_Irreg, FigWave_Irreg], "Color", [0 0 0], "Color", [1 0 0]);


    topo_Reg = ampNorm(1).(strcat(monkeyStr(mIndex), "_mean"));
    topo_Irreg = ampNorm(3).(strcat(monkeyStr(mIndex), "_mean"));

    if ~isempty(badCh{mIndex})
        topo_Reg(badCh{mIndex}) = 1;
        topo_Irreg(badCh{mIndex}) = 1;
    end

    FigTopo_Reg(mIndex) = plotTopo_Raw(topo_Reg, [8, 8]);
    FigTopo_Irreg(mIndex) = plotTopo_Raw(topo_Irreg, [8, 8]);
    colormap(FigTopo_Reg(mIndex), "jet");
    colormap(FigTopo_Irreg(mIndex), "jet");

    %% change figure scale
    scaleAxes([FigWave_Whole_Reg(mIndex), FigWave_Whole_Irreg(mIndex), FigTopo_Reg(mIndex), FigTopo_Irreg(mIndex)], "c", CRIScale(CRIMethod, :));
    scaleAxes([FigWave_Whole_Reg(mIndex), FigWave_Whole_Irreg(mIndex), FigWave_Reg(mIndex), FigWave_Irreg(mIndex)], "y", [-yScale(mIndex) yScale(mIndex)]);
    
    setAxes([FigWave_Whole_Reg(mIndex), FigWave_Whole_Irreg(mIndex), FigWave_Reg(mIndex), FigWave_Irreg(mIndex)], 'yticklabel', '');
    setAxes([FigWave_Whole_Reg(mIndex), FigWave_Whole_Irreg(mIndex), FigWave_Reg(mIndex), FigWave_Irreg(mIndex)], 'xticklabel', '');
    setAxes([FigWave_Whole_Reg(mIndex), FigWave_Whole_Irreg(mIndex), FigWave_Reg(mIndex), FigWave_Irreg(mIndex)], 'visible', 'off');
    setLine([FigWave_Whole_Reg(mIndex), FigWave_Whole_Irreg(mIndex), FigWave_Reg(mIndex), FigWave_Irreg(mIndex)], "YData", [-yScale(mIndex) yScale(mIndex)], "LineStyle", "--");
    
    set([FigWave_Whole_Reg(mIndex), FigWave_Whole_Irreg(mIndex), FigTopo_Reg(mIndex), FigTopo_Irreg(mIndex), FigWave_Reg(mIndex), FigWave_Irreg(mIndex)], "outerposition", [300, 100, 800, 670]);
   
    scaleAxes([FigWave_Reg(mIndex), FigWave_Irreg(mIndex)], "x", [-10 600]);    
    plotLayout([FigWave_Whole_Reg(mIndex), FigWave_Whole_Irreg(mIndex), FigWave_Reg(mIndex), FigWave_Irreg(mIndex)], params.posIndex + 2 * (mIndex - 1), 0.3);

    print(FigWave_Whole_Reg(mIndex), strcat(FIGPATH, Protocol, "_whole_Reg_Wave"), "-djpeg", "-r200");
    print(FigWave_Whole_Irreg(mIndex), strcat(FIGPATH, Protocol, "_whole_Irreg_Wave"), "-djpeg", "-r200");
    
    
    print(FigWave_Reg(mIndex), strcat(FIGPATH, Protocol, "_Reg_Wave"), "-djpeg", "-r200");
    print(FigWave_Irreg(mIndex), strcat(FIGPATH, Protocol, "_Irreg_Wave"), "-djpeg", "-r200");

    print(FigTopo_Reg(mIndex), strcat(FIGPATH, Protocol, "_Topo_Reg"), "-djpeg", "-r200");
    print(FigTopo_Irreg(mIndex), strcat(FIGPATH, Protocol, "_Topo_Irreg"), "-djpeg", "-r200");

    %% Reg Irreg comparison, for Reg-Irreg tuning and topo
    % ttest between 4ms Reg and 4ms Irreg
    temp1 = ampNorm(1).(strcat(monkeyStr(mIndex), "_raw")); % 4ms Reg
    temp2 = ampNorm(3).(strcat(monkeyStr(mIndex), "_raw")); % 4ms Irreg
    [H, P] = cellfun(@(x, y) ttest2(x, y), temp1, temp2, "UniformOutput", false);

    sigCh{mIndex} = find(cell2mat(S1H));
    nSigCh{mIndex} = find(~cell2mat(S1H));
%     sigCh{mIndex} = find(cell2mat(H));
% nSigCh{mIndex} = find(~cell2mat(H));

    compare(mIndex).info = monkeyStr(mIndex);
    temp = reshape([ampNorm(1).(strcat(monkeyStr(mIndex), "_mean"))'; ampNorm(3).(strcat(monkeyStr(mIndex), "_mean"))';...
        ampNorm(1).(strcat(monkeyStr(mIndex), "_se"))'; ampNorm(3).(strcat(monkeyStr(mIndex), "_se"))'], 2, []) ;
    compare(mIndex).mean_se = [[1; 2], temp];
    compare(mIndex).mean_scatter = [[1; 2] [ampNorm(1).(strcat(monkeyStr(mIndex), "_mean"))'; ampNorm(3).(strcat(monkeyStr(mIndex), "_mean"))']];
    compare(mIndex).H = cell2mat(H);
    compare(mIndex).P = cell2mat(P);

    temp = reshape([ampNorm(1).(strcat(monkeyStr(mIndex), "_mean"))(sigCh{mIndex})'; ampNorm(3).(strcat(monkeyStr(mIndex), "_mean"))(sigCh{mIndex})';...
        ampNorm(1).(strcat(monkeyStr(mIndex), "_se"))(sigCh{mIndex})'; ampNorm(3).(strcat(monkeyStr(mIndex), "_se"))(sigCh{mIndex})'], 2, []) ;
    compare(mIndex).selectMean_SE_S1Sig = [[1; 2], temp];

    temp = reshape([ampNorm(1).(strcat(monkeyStr(mIndex), "_mean"))(nSigCh{mIndex})'; ampNorm(3).(strcat(monkeyStr(mIndex), "_mean"))(nSigCh{mIndex})';...
        ampNorm(1).(strcat(monkeyStr(mIndex), "_se"))(nSigCh{mIndex})'; ampNorm(3).(strcat(monkeyStr(mIndex), "_se"))(nSigCh{mIndex})'], 2, []) ;
    compare(mIndex).selectMean_SE_S1nSig = [[1; 2], temp];

    % plot reg vs irreg topo
    topo = logg(0.05, compare(mIndex).P / 0.05);
        topo(isinf(topo)) = 5;
        topo(topo > 5) = 5;
        FigTopo = plotTopo_Raw(topo, [8, 8]);
    colormap(FigTopo, "jet");
    scaleAxes(FigTopo, "c", [-5, 5]);
    set(FigTopo, "outerposition", [300, 100, 800, 670]);
    %     title("p-value (log(log(0.05, p)) distribution of Reg vs Irreg");

    print(FigTopo, strcat(FIGPATH, Protocol, "Reg_Irreg_pValue_Topo_Reg"), "-djpeg", "-r200");
    close(FigTopo);

    %% p-value of CRI and sponRes
    stiStr = ["4_4o06msReg", "4o06_4msReg", "4_4o06msIrreg", "4o06_4msIrreg"];
    for dIndex = [1 3]
        % compare change resp and spon resp
        amp = ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_amp"));
        rmsSpon = ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_rmsSpon"));
        [sponH, sponP] = cellfun(@(x, y) ttest(x, y), changeCellRowNum(amp), changeCellRowNum(rmsSpon), "UniformOutput", false);
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
        set(FigTopo, "outerposition", [300, 100, 800, 670]);
        %         title("p-value (log(log(0.05, p)) distribution of [0 300] response and baseline");

        print(FigTopo, strcat(FIGPATH, Protocol, "_", stiStr(dIndex), "_pValue_Topo_Reg"), "-djpeg", "-r200");
        close(FigTopo);
    end
drawnow
end

close all
