close all; clc; clear;

% MATPATH{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Basic_ICI4\cc20220713\cc20220713_AC.mat';
% MATPATH{2} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\Basic_ICI4\xx20220711\xx20220711_AC.mat';
% MATPATH{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Add_on_Basic_ICI4\cc20221015\cc20221015_AC.mat';
% MATPATH{2} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\Add_on_Basic_ICI4\xx20221015\xx20221015_AC.mat';
MATPATH{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Basic_NormSqrt\cc20220827\cc20220827_AC.mat';
MATPATH{2} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\Basic_NormSqrt\xx20220829\xx20220829_AC.mat';
monkeyStr = ["CC", "XX"];
ROOTPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\Basic\";
params.posIndex = 1; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;

CRIMethod = 2; 
CRIMethodStr = ["Resp_devided_by_Spon", "R_minus_S_devide_R_plus_S"];
CRIScale = [0.8, 2; -0.1 0.8];
CRITest = [1, 0];

flp = 400;
fhp = 0.1;
segOption = ["trial onset", "dev onset"];
s1OnsetOrS2Onset = 2; % 1, s1onset; 2, s2Onset
colors = ["#FF0000", "#FFA500", "#0000FF", "#000000"];

AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);



selectCh = [13 9];
badCh = {[], []};
yScale = [50, 90];
quantWin = [0 300];
sponWin = [-300 0];
for mIndex =  1 : 2

    temp = string(split(MATPATH{mIndex}, '\'));
    DateStr = temp(end - 1);
    Protocol = temp(end - 2);
FIGPATH = strcat(ROOTPATH, "\Sfigure_SqrtNorm\", DateStr, "\", CRIMethodStr(CRIMethod), "\");
mkdir(FIGPATH);
    %% process
    [trialAll, ECOGDataset] = ECOGPreprocess(MATPATH{mIndex}, params);
    % ICA
%     opts.Protocol = Protocol;
%     ICAName = strcat(FIGPATH, "comp_", AREANAME, ".mat");
%     if ~exist(ICAName, "file")
%         [~, comp] = CTLICA(ECOGDataset, trialAll, 500, opts);
%         compT = comp;
%         ICs = input("ICs to delete: ");
%         compT.topo(:, ismember(1:size(compT.topo, 2), ICs)) = 0;
%         ECOGDataset.data = compT.topo * (comp.unmixing * ECOGDataset.data);
%         save(ICAName, "compT", "comp", "ICs", "-mat");
%     else
%         load(ICAName);
%         ECOGDataset.data = compT.topo * (comp.unmixing * ECOGDataset.data);
%     end
    % align to certain duration
    run("CTLconfig.m");
    trialAll([trialAll.devOrdr] == 0) = [];
    trialAll(1) = [];
    devType = unique([trialAll.devOrdr]);
    devTemp = {trialAll.devOnset}';
    [~, ordTemp] = ismember([trialAll.ordrSeq]', devType);
    temp = cellfun(@(x, y) x + S1Duration(y), devTemp, num2cell(ordTemp), "UniformOutput", false);
    trialAll = addFieldToStruct(trialAll, temp, "devOnset");

    % filter
    ECOGFDZ = mFTHP(ECOGDataset, 0.1, 400);% filtered, dowmsampled, zoomed

    % initialize
    t = linspace(Window(1), Window(2), diff(Window) /1000 * ECOGDataset.fs + 1)';
    for ch = 1 : length(ECOGFDZ.channels)
        cdrPlot(ch).(strcat(monkeyStr(mIndex), "info")) = strcat("Ch", num2str(ch));
        cdrPlot(ch).(strcat(monkeyStr(mIndex), "Wave")) = zeros(length(t), 2 * length(devType));
    end


    % diff stim type
    for dIndex = 1:length(devType)
        tIndex = [trialAll.devOrdr] == devType(dIndex);
        trials = trialAll(tIndex);
        trialsECOG = selectEcog(ECOGFDZ, trials, segOption(s1OnsetOrS2Onset), Window);

        % exclude trial
        trialsECOG = excludeTrialsChs(trialsECOG, 0.1);
        chMean{dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOG), 'UniformOutput', false));
        chStd = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOG), 'UniformOutput', false));
        for ch = 1 : size(chMean{dIndex}, 1)
            cdrPlot(ch).(strcat(monkeyStr(mIndex), "Wave"))(:, 2 * dIndex - 1) = t';
            cdrPlot(ch).(strcat(monkeyStr(mIndex), "Wave"))(:, 2 * dIndex) = chMean{dIndex}(ch, :)';
        end

        % quantization
        [temp, amp, rmsSpon] = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trialsECOG, 'UniformOutput', false);
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_mean")) = cellfun(@mean, changeCellRowNum(temp));
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_se")) = cellfun(@(x) std(x)/sqrt(length(x)), changeCellRowNum(temp));
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_raw")) = changeCellRowNum(temp);
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_amp")) = amp;
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_rmsSpon")) = rmsSpon;
    end


   %% significance of s1 onset response
        s1Win = [-2000 2000];
        trialsECOG_S1 = selectEcog(ECOGFDZ, trialAll, "trial onset", s1Win);
        trialsECOG_S1 = excludeTrialsChs(trialsECOG_S1, 0.1);
        
       [temp, amp, rmsSpon] = cellfun(@(x) waveAmp_Norm(x, s1Win, quantWin, CRIMethod, sponWin), trialsECOG_S1, 'UniformOutput', false);
        ampNormS1.(strcat(monkeyStr(mIndex), "_S1_mean")) = cellfun(@mean, changeCellRowNum(temp));
        ampNormS1.(strcat(monkeyStr(mIndex), "_S1_se")) = cellfun(@(x) std(x)/sqrt(length(x)), changeCellRowNum(temp));
        ampNormS1.(strcat(monkeyStr(mIndex), "_S1_raw")) = changeCellRowNum(temp);
        % compare S1 Response and spon
        [S1H, S1P] = cellfun(@(x, y) ttest(x, y), changeCellRowNum(amp), changeCellRowNum(rmsSpon), "UniformOutput", false);
        S1H = num2cell(cell2mat(S1H) & cellfun(@mean, changeCellRowNum(amp)) > cellfun(@mean, changeCellRowNum(rmsSpon)));

    %% plot rawWave 

    FigWave_Reg(mIndex) = plotRawWave(chMean{1}, [], Window, titleStr, [8, 8]);
    FigWave_Irreg(mIndex) = plotRawWave(chMean{3}, [], Window, titleStr, [8, 8]);
    setLine(FigWave_Irreg, "Color", [0 0 0], "Color", [1 0 0]);

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
    scaleAxes([FigTopo_Reg(mIndex), FigTopo_Irreg(mIndex)], "c", CRIScale(CRIMethod, :));
    scaleAxes([FigWave_Reg(mIndex), FigWave_Irreg(mIndex)], "y", [-yScale(mIndex) yScale(mIndex)]);
    scaleAxes([FigWave_Reg(mIndex), FigWave_Irreg(mIndex)], "x", [-10 600]);
    setAxes([FigWave_Reg(mIndex), FigWave_Irreg(mIndex)], 'yticklabel', '');
    setAxes([FigWave_Reg(mIndex), FigWave_Irreg(mIndex)], 'xticklabel', '');
    setAxes([FigWave_Reg(mIndex), FigWave_Irreg(mIndex)], 'visible', 'off');
    setLine([FigWave_Reg(mIndex), FigWave_Irreg(mIndex)], "YData", [-yScale(mIndex) yScale(mIndex)], "LineStyle", "--");
    set([FigTopo_Reg(mIndex), FigTopo_Irreg(mIndex), FigWave_Reg(mIndex), FigWave_Irreg(mIndex)], "outerposition", [300, 100, 800, 670]);
   
    plotLayout([FigWave_Reg(mIndex), FigWave_Irreg(mIndex)], params.posIndex + 2 * (mIndex - 1), 0.3);

  
    print(FigWave_Reg(mIndex), strcat(FIGPATH, Protocol, "_Reg_Wave"), "-djpeg", "-r200");
    print(FigWave_Irreg(mIndex), strcat(FIGPATH, Protocol, "_Irreg_Wave"), "-djpeg", "-r200");
    print(FigTopo_Reg(mIndex), strcat(FIGPATH, Protocol, "_Topo_Reg"), "-djpeg", "-r200");
    print(FigTopo_Irreg(mIndex), strcat(FIGPATH, Protocol, "_Topo_Irreg"), "-djpeg", "-r200");

    %% Reg Irreg comparison, for Reg-Irreg tuning and topo
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
    topo = logg(2, logg(0.05, compare(mIndex).P));
    FigTopo= plotTopo_Raw(topo, [8, 8]);
    colormap(FigTopo, "jet");
    scaleAxes(FigTopo, "c", [0, 3]);
    set(FigTopo, "outerposition", [300, 100, 800, 670]);
%     title("p-value (log(log(0.05, p)) distribution of Reg vs Irreg");
    print(FigTopo, strcat(FIGPATH, DateStr, "_", Protocol, "Reg_Irreg_pValue_Topo_Reg"), "-djpeg", "-r200");
    close(FigTopo);

    %% p-value of CRI and 1
    stiStr = ["4_4o06msReg", "4o06_4msReg", "4_4o06msIrreg", "4o06_4msIrreg"];
    for dIndex = [1 3]
       % compare change resp and spon resp
        amp = ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_amp"));
        rmsSpon = ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_rmsSpon"));
        [sponH, sponP] = cellfun(@(x, y) ttest(x, y), changeCellRowNum(amp), changeCellRowNum(rmsSpon), "UniformOutput", false);
%         % compare ampNorm and 1
%         temp = ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_raw"));
%         OneArray = repmat({ones(length(temp{1}) , 1) * CRITest(CRIMethod)}, length(temp), 1);
%         [sponH, sponP] = cellfun(@(x, y) ttest2(x, y), temp, OneArray, "UniformOutput", false);

        % plot p-value topo
        topo = logg(0.05, cell2mat(sponP) / 0.05);
        topo(isinf(topo)) = 5;
        topo(topo > 5) = 5;
        FigTopo= plotTopo_Raw(topo, [8, 8]);
        colormap(FigTopo, "jet");
        scaleAxes(FigTopo, "c", [-5 5]);
        set(FigTopo, "outerposition", [300, 100, 800, 670]);
%         title("p-value (log(log(0.05, p)) distribution of [0 300] response and baseline");
        print(FigTopo, strcat(FIGPATH, DateStr, "_", Protocol, "_", stiStr(dIndex), "_pValue_Topo_Reg"), "-djpeg", "-r200");
        close(FigTopo);
    end
end

close all
