close all; clc; clear;

MATPATH{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Basic_ICI4\';
MATPATH{2} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\Basic_ICI4\';
monkeyStr = ["CC", "XX"];
ROOTPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\Basic\";
params.posIndex = 1; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;

CRIMethod = 2;
CRIMethodStr = ["Resp_devided_by_Spon", "R_minus_S_devide_R_plus_S"];
CRIScale = {[0.8, 2; -0.1 0.7], [0.8, 2; -0.1 0.6]};
CRITest = [1, 0];
pBase = 0.01;

colors = ["#FF0000", "#FFA500", "#0000FF", "#000000"];

AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);
fs = 500;


selectCh = [13 9];
badCh = {[], []};
yScale = [40, 60];
S1Frac = [1.5 1.7];
quantWin = [0 300];
sponWin = [-300 0];
for mIndex =  1 : length(MATPATH)
    if isempty(MATPATH{mIndex})
        continue
    end
    temp = string(split(MATPATH{mIndex}, '\'));
    Protocol = temp(end - 1);
    FIGPATH = strcat(ROOTPATH, "\Pop_Figure2_RegIrreg\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");
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
        trialsECOG_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_MergeTemp, "UniformOutput", false);
        trialsECOG_S1_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_S1_MergeTemp, "UniformOutput", false);
    end

        %% Patch
    temp = changeCellRowNum(trialsECOG_Merge);
    temp = temp(ECOGSitePatch(AREANAME));
    trialsECOG_Merge = changeCellRowNum(temp);

    temp = changeCellRowNum(trialsECOG_S1_Merge);
    temp = temp(ECOGSitePatch(AREANAME));
    trialsECOG_S1_Merge = changeCellRowNum(temp);
    
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
        trialsECOG_S1 = trialsECOG_S1_Merge(tIndex);
        
        chMean{dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOG), 'UniformOutput', false));
        chMean_S1{dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOG_S1), 'UniformOutput', false));
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
    FigWave_Reg_S1(mIndex) = plotRawWave(chMean_S1{1}, [], Window, titleStr, [8, 8]);
    FigWave_Irreg_S1(mIndex) = plotRawWave(chMean_S1{3}, [], Window, titleStr, [8, 8]);

    FigWave_Whole_Reg(mIndex) = plotRawWave(chMean{1}, [], Window, titleStr, [8, 8]);
    FigWave_Whole_Irreg(mIndex) = plotRawWave(chMean{3}, [], Window, titleStr, [8, 8]);
    
    setLine([FigWave_Whole_Irreg, FigWave_Irreg, FigWave_Irreg_S1], "Color", [0 0 0], "Color", [1 0 0]);


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
    scaleAxes([FigWave_Whole_Reg(mIndex), FigWave_Whole_Irreg(mIndex), FigTopo_Reg(mIndex), FigTopo_Irreg(mIndex)], "c", CRIScale{mIndex}(CRIMethod, :));
    scaleAxes([FigWave_Whole_Reg(mIndex), FigWave_Whole_Irreg(mIndex), FigWave_Reg(mIndex), FigWave_Irreg(mIndex)], "y", [-yScale(mIndex) yScale(mIndex)]);
    scaleAxes([FigWave_Reg_S1(mIndex), FigWave_Irreg_S1(mIndex)], "y", [-yScale(mIndex)*S1Frac(mIndex) yScale(mIndex)*S1Frac(mIndex)]);


    setAxes([FigWave_Whole_Reg(mIndex), FigWave_Whole_Irreg(mIndex), FigWave_Reg(mIndex), FigWave_Irreg(mIndex), FigWave_Reg_S1(mIndex), FigWave_Irreg_S1(mIndex)], 'yticklabel', '');
    setAxes([FigWave_Whole_Reg(mIndex), FigWave_Whole_Irreg(mIndex), FigWave_Reg(mIndex), FigWave_Irreg(mIndex), FigWave_Reg_S1(mIndex), FigWave_Irreg_S1(mIndex)], 'xticklabel', '');
    setAxes([FigWave_Whole_Reg(mIndex), FigWave_Whole_Irreg(mIndex), FigWave_Reg(mIndex), FigWave_Irreg(mIndex), FigWave_Reg_S1(mIndex), FigWave_Irreg_S1(mIndex)], 'visible', 'off');
    setLine([FigWave_Whole_Reg(mIndex), FigWave_Whole_Irreg(mIndex), FigWave_Reg(mIndex), FigWave_Irreg(mIndex)], "YData", [-yScale(mIndex) yScale(mIndex)], "LineStyle", "--");
    setLine([FigWave_Reg_S1(mIndex), FigWave_Irreg_S1(mIndex)], "YData", [-yScale(mIndex)*S1Frac(mIndex) yScale(mIndex)*S1Frac(mIndex)], "LineStyle", "--");

    pause(1);
    set([FigWave_Whole_Reg(mIndex), FigWave_Whole_Irreg(mIndex), FigTopo_Reg(mIndex), FigTopo_Irreg(mIndex), FigWave_Reg(mIndex), FigWave_Irreg(mIndex), FigWave_Reg_S1(mIndex), FigWave_Irreg_S1(mIndex)], "outerposition", [300, 100, 800, 670]);
   
    scaleAxes([FigWave_Reg(mIndex), FigWave_Irreg(mIndex), FigWave_Reg_S1(mIndex), FigWave_Irreg_S1(mIndex)], "x", [-10 600]);    
      

    plotLayout([FigWave_Whole_Reg(mIndex), FigWave_Whole_Irreg(mIndex), FigWave_Reg(mIndex), FigWave_Irreg(mIndex), FigWave_Reg_S1(mIndex), FigWave_Irreg_S1(mIndex)], params.posIndex + 2 * (mIndex - 1), 0.3);

    print(FigWave_Whole_Reg(mIndex), strcat(FIGPATH, Protocol, "_whole_Reg_Wave"), "-djpeg", "-r200");
    print(FigWave_Whole_Irreg(mIndex), strcat(FIGPATH, Protocol, "_whole_Irreg_Wave"), "-djpeg", "-r200");
    
    print(FigWave_Reg_S1(mIndex), strcat(FIGPATH, Protocol, "_Reg_Wave_S1"), "-djpeg", "-r200");
    print(FigWave_Irreg_S1(mIndex), strcat(FIGPATH, Protocol, "_Irreg_Wave_S1"), "-djpeg", "-r200");

    
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
    topo = logg(pBase, compare(mIndex).P / pBase);
        topo(isinf(topo)) = 5;
        topo(topo > 5) = 5;
        FigTopo = plotTopo_Raw(topo, [8, 8]);
    colormap(FigTopo, "jet");
    scaleAxes(FigTopo, "c", [-5, 5]);
    pause(1);
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
        pause(1);
        set(FigTopo, "outerposition", [300, 100, 800, 670]);
        %         title("p-value (log(log(0.05, p)) distribution of [0 300] response and baseline");
        
        print(FigTopo, strcat(FIGPATH, Protocol, "_", stiStr(dIndex), "_pValue_Topo_Reg"), "-djpeg", "-r200");
        close(FigTopo);
    end
drawnow
ResName = strcat(FIGPATH, "cdrPlot_", AREANAME, ".mat");
save(ResName, "cdrPlot", "chMean", "Protocol", "compare", "-mat");

%% ANOVA between Reg and Irreg
% mAnova1()

% %% Multiple comparison
% channels = 1 : size(trialsECOG_Merge{1}, 1);
% t = linspace(Window(1), Window(2), size(trialsECOG_Merge{1}, 2))';
% ResName = strcat(FIGPATH, "CBPT_", AREANAME, ".mat");
% try
%     load(ResName, "stat", "-mat");
% catch
%     data = [];
%     pool = [1, 3];
%     for dIndex = 1:length(pool)
%         temp = trialsECOG_Merge([trialAll.devOrdr] == devType(pool(dIndex)));
%         % time 1*nSample
%         data(dIndex).time = t' / 1000;
%         % label nCh*1 cell
%         data(dIndex).label = cellfun(@(x) num2str(x), num2cell(channels)', 'UniformOutput', false);
%         % trial nTrial*nCh*nSample
%         data(dIndex).trial = cell2mat(cellfun(@(x) permute(x, [3, 1, 2]), temp, "UniformOutput", false));
%         % trialinfo nTrial*1
%         data(dIndex).trialinfo = repmat(dIndex, [length(temp), 1]);
%     end
% 
%     stat = CBPT(data);
%     save(ResName, "stat", "-mat");
% end
% 
% p = stat.stat;
% mask = stat.mask;
% V0 = p .* mask;
% windowSortCh = [0, 400];
% tIdx = fix((windowSortCh(1) - Window(1)) / 1000 * fs) + 1:fix((windowSortCh(2) - Window(1)) / 1000 * fs);
% [~, chIdx] = sort(sum(V0(:, tIdx), 2), 'descend');
% V = V0(chIdx, :);
% 
% figure;
% maximizeFig;
% mSubplot(1, 1, 1, 1, [0, 0, 0, 0], [0.03, 0.01, 0.06, 0.03]);
% imagesc("XData", t, "YData", channels, "CData", V);
% xlim(windowSortCh);
% % xlim([0, Window(2)]);
% ylim([0.5, 64.5]);
% yticks(channels);
% yticklabels(num2str(channels(chIdx)'));
% cm = colormap('jet');
% cm(127:129, :) = repmat([1 1 1], [3, 1]);
% colormap(cm);
% title('F-value of comparison among 4 deviant frequency ratio in all channels (significant)');
% ylabel('Ranked channels');
% xlabel('Time (ms)');
% cb = colorbar;
% cb.Label.String = '\bf{{\it{F}}-value}';
% cb.Label.Interpreter = 'latex';
% cb.Label.FontSize = 12;
% cb.Label.Position = [2.5, 0];
% cb.Label.Rotation = -90;
% cRange = scaleAxes(gcf, "c", [], [], "max");

end

close all
