close all; clc; clear;

MATPATH{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Basic_ICIThr\cc20220704\cc20220704_AC.mat';
MATPATH{2} = 'E:\ECoG\MAT Data\xx\ClickTrainLongTerm\Basic_ICIThr\xx20220706\xx20220706_AC.mat';
monkeyStr = ["CC", "XX"];
ROOTPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\";
params.posIndex = 1; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;

CRIMethod = 2; 
CRIMethodStr = ["Resp_devided_by_Spon", "R_minus_S_devide_R_plus_S"];
CRIScale = [0.8, 2; -0.1 0.3];
CRITest = [1, 0];

flp = 400;
fhp = 0.1;
segOption = ["trial onset", "dev onset"];
s1OnsetOrS2Onset = 2; % 1, s1onset; 2, s2Onset
colors = ["#000000", "#FFA500", "#0000FF", "#FF0000"];
stimStrs = ["4_4o01", "4_4o03", "4_4o02", "4_4o04"];
cdrPlotIdx = [8, 4, 6, 2];

AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);



selectCh = [13 37];
badCh = {[], []};
yScale = [60, 90];
quantWin = [0 300];
sponWin = [-300 0];
for mIndex = 2 : length(MATPATH)

    temp = string(split(MATPATH{mIndex}, '\'));
    DateStr = temp(end - 1);
    Protocol = temp(end - 2);
    FIGPATH = strcat(ROOTPATH, "\Figure4\", DateStr, "\", CRIMethodStr(CRIMethod), "\");
    mkdir(FIGPATH);
    %% process
    [trialAll, ECOGDataset] = ECOGPreprocess(MATPATH{mIndex}, params);

    % align to certain duration
    run("CTLconfig.m");
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
            cdrPlot(ch).(strcat(monkeyStr(mIndex), "Wave"))(:, cdrPlotIdx(dIndex)) = chMean{dIndex}(ch, :)';
        end

        % quantization
        temp = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trialsECOG, 'UniformOutput', false);
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_mean")) = cellfun(@mean, changeCellRowNum(temp));
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_se")) = cellfun(@(x) std(x)/sqrt(length(x)), changeCellRowNum(temp));
        ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_raw")) = changeCellRowNum(temp);

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
    %% plot rawWave
    FigWave(mIndex) = plotRawWaveMulti_SPR(RegRatio, Window, titleStr, [8, 8]);
    scaleAxes(FigWave(mIndex), "y", [-yScale(mIndex) yScale(mIndex)]);
    scaleAxes(FigWave(mIndex), "x", [-10 600]);
    setAxes(FigWave(mIndex), 'yticklabel', '');
    setAxes(FigWave(mIndex), 'xticklabel', '');
    setAxes(FigWave(mIndex), 'visible', 'off');
    setLine(FigWave(mIndex), "YData", [-yScale(mIndex) yScale(mIndex)], "LineStyle", "--");
    set(FigWave(mIndex), "outerposition", [300, 100, 800, 670]);
    if contains(DateStr, "cc")
        plotLayout(FigWave(mIndex), params.posIndex, 0.3);
    elseif contains(DateStr, "xx")
        plotLayout(FigWave(mIndex), params.posIndex + 2, 0.3);
    end

    print(FigWave(mIndex), strcat(FIGPATH,  Protocol, "_Wave"), "-djpeg", "-r200");



    %% p-value of CRI and 1
    for dIndex = 1:length(devType)
        % compare change resp and spon resp
        %     [sponH{mIndex}, sponP{mIndex}] = cellfun(@(x, y) ttest(x, y), changeCellRowNum(amp(1).(protStr(mIndex))), changeCellRowNum(rmsSpon(1).(protStr(mIndex))), "UniformOutput", false);
        % compare ampNorm and 1
        temp = ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_raw"));
        OneArray = repmat({ones(length(temp{1}), 1) * CRITest(CRIMethod)}, length(temp), 1);
        [sponH{dIndex}, sponP{dIndex}] = cellfun(@(x, y) ttest2(x, y), temp, OneArray, "UniformOutput", false);

        % plot p-value topo
        topo = logg(2, logg(0.05, cell2mat(sponP{dIndex})));
        FigTopo= plotTopo_Raw(topo, [8, 8]);
        colormap(FigTopo, "jet");
        scaleAxes(FigTopo, "c", [0 3]);
        set(FigTopo, "outerposition", [300, 100, 800, 670]);
        %         title("p-value (log(log(0.05, p)) distribution of [0 300] response and baseline");
        print(FigTopo, strcat(FIGPATH, Protocol, "_", stimStrs(dIndex), "_pValue_Topo_Reg"), "-djpeg", "-r200");
        close(FigTopo);
    end




    %% Diff ICI amplitude comparison
    sigCh = find(cell2mat(sponH{4}) == 1 );
    temp = reshape([ampNorm(1).(strcat(monkeyStr(mIndex), "_mean"))(sigCh)'; ampNorm(3).(strcat(monkeyStr(mIndex), "_mean"))(sigCh)';...
        ampNorm(2).(strcat(monkeyStr(mIndex), "_mean"))(sigCh)'; ampNorm(4).(strcat(monkeyStr(mIndex), "_mean"))(sigCh)';...
        ampNorm(1).(strcat(monkeyStr(mIndex), "_se"))(sigCh)'; ampNorm(3).(strcat(monkeyStr(mIndex), "_se"))(sigCh)';...
        ampNorm(2).(strcat(monkeyStr(mIndex), "_se"))(sigCh)'; ampNorm(4).(strcat(monkeyStr(mIndex), "_se"))(sigCh)'], 4, []) ;

    compare.amp_mean_se = [[1; 2; 3; 4], temp];



end

close all
