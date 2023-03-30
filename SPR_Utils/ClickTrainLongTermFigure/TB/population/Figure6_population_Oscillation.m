close all; clc; clear;

MATPATH{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\TB\Add_on_Basic_Oscillation_control_500_250_125_60_30\';
MATPATH{2} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\TB\Add_on_Basic_Oscillation_control_500_250_125_60_30\';
monkeyStr = ["CC", "XX"];
ROOTPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\Basic\";
params.posIndex = 1; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;

% Synchronize response index
SRIMethod = 2;
SRIMethodStr = ["Resp_devided_by_Spon", "R_minus_S_devide_R_plus_S"];
SRIScale = [0.8, 2; 0 0.2];
SRITest = [1, 0];
pBase = 0.05;

% FFT method
FFTMethod = 2; %1: power(dB); 2: magnitude
fftScale = [60, 60; 400, 400];
correspFreq = 1000./[500, 250, 125, 60, 30, 1000];

flp = 300;
fhp = 0.1;
segOption = ["trial onset", "dev onset"];
s1OnsetOrS2Onset = 1; % 1, s1onset; 2, s2Onset
colors = ["#FF0000", "#FFA500", "#0000FF", "#000000", "#AAAAAA"];
stimStrs = ["Osc_500ms", "Osc_250ms", "Osc_125ms", "Osc_60ms", "Osc_30ms", "control"];

AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);

fs = 500;

badCh = {[], []};

quantWin = [0 300];
latencyWin = [80 200];
sponWin = [-300 0];
for mIndex = 1 : length(MATPATH)

    temp = string(split(MATPATH{mIndex}, '\'));
    Protocol = temp(end - 1);
    FIGPATH = strcat(ROOTPATH, "\Pop_Figure6_Osci_Control\",  SRIMethodStr(SRIMethod), "\", monkeyStr(mIndex), "\");
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

    temp = changeCellRowNum(trialsECOG_S1_Merge);
    temp = temp(ECOGSitePatch(AREANAME));
    trialsECOG_S1_Merge = changeCellRowNum(temp);


    %% process
    devType = unique([trialAll.devOrdr]);
    % initialize
    t = linspace(Window(1), Window(2), diff(Window) /1000 * fs + 1)';

%% diff stim type
    for dIndex = 1:length(devType)
        
        tIndex = [trialAll.devOrdr] == devType(dIndex);
        trials = trialAll(tIndex);
        trialsECOG = trialsECOG_Merge(tIndex);

        chMean{dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOG), 'UniformOutput', false));
        chStd = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOG), 'UniformOutput', false));

        % FFT during successive sound
        tIdx = find(t > FFTWin(1) & t < FFTWin(2));
        [ff, PMean{dIndex}, trialsFFT{dIndex}]  = trialsECOGFFT(trialsECOG, fs, tIdx, [], FFTMethod);
        [tarMean, idx] = findWithinWindow(PMean{dIndex}, ff, [0.9, 1.1] * correspFreq( dIndex));
        [~, targetIndex] = max(tarMean, [], 2);
        targetIdx(dIndex) = mode(targetIndex) + idx(1) - 1;
       
        for ch = 1 : size(chMean{dIndex}, 1)
            cdrPlot(ch).(strcat(monkeyStr(mIndex), "Wave"))(:, 2 * dIndex - 1) = t';
            cdrPlot(ch).(strcat(monkeyStr(mIndex), "Wave"))(:, 2 * dIndex) = chMean{dIndex}(ch, :)';
            cdrPlot(ch).(strcat(monkeyStr(mIndex), "FFT"))(:, 2 * dIndex - 1) = ff;
            cdrPlot(ch).(strcat(monkeyStr(mIndex), "FFT"))(:, 2 * dIndex) = PMean{dIndex}(ch, :)';
        end
    end

    %% compare and plot rawWave
    for  dIndex = 1 : length(devType)-1
        fftPValue(dIndex).info = stimStrs(dIndex);
        Successive(1).chMean = PMean{dIndex}; Successive(1).color = "r";
        Successive(2).chMean = PMean{length(devType)}; Successive(2).color = "k";
        [H, P] = waveFFTPower_pValue(trialsFFT{dIndex}, trialsFFT{length(devType)}, [{ff}, {ff}], targetIdx(dIndex), 2);
        fftPValue(dIndex).(strcat(stimStrs(dIndex), "_pValue")) = P;
        fftPValue(dIndex).(strcat(stimStrs(dIndex), "_H")) = H;
        % plot raw wave
        FigWave = plotRawWaveMulti_SPR(Successive, [0 fs/2], strcat(stimStrs(dIndex), " Oscillation"), [8, 8]);
        FigWave = deleteLine(FigWave, "LineStyle", "--");
        scaleAxes(FigWave, "y", [0 fftScale(FFTMethod, mIndex)]);
        scaleAxes(FigWave, "x", [0 50]);
        %     setAxes(FigWave, "Xscale", "log");
        lines(1).X = correspFreq(dIndex); lines(1).color = "k";
        addLines2Axes(FigWave, lines);
        orderLine(FigWave, "LineStyle", "--", "bottom");
        setAxes(FigWave, 'yticklabel', '');
        setAxes(FigWave, 'xticklabel', '');
        setAxes(FigWave, 'visible', 'off');
        setLine(FigWave, "YData", [-fftScale(FFTMethod, mIndex) fftScale(FFTMethod, mIndex)], "LineStyle", "--");
        pause(1);
        set(FigWave, "outerposition", [300, 100, 800, 670]);
        plotLayout(FigWave, params.posIndex + 2 * (mIndex - 1), 0.3);
        print(FigWave, strcat(FIGPATH, Protocol, "_FFT_", stimStrs(dIndex)), "-djpeg", "-r200");
        close(FigWave);
    end

%% p-value distribution

for dIndex = 1 : length(devType) - 1
    % plot p-value topo
    temp = fftPValue(dIndex).(strcat(stimStrs(dIndex), "_pValue"));
    topo = logg(pBase, temp / pBase);
    topo(isinf(topo)) = 5;
    topo(topo > 5) = 5;
    FigTopo(dIndex) = plotTopo_Raw(topo, [8, 8]);
    colormap(FigTopo(dIndex), "jet");
    scaleAxes(FigTopo(dIndex), "c", [-5 5]);
    pause(1);
    set(FigTopo(dIndex), "outerposition", [300, 100, 800, 670]);
    print(FigTopo(dIndex), strcat(FIGPATH, stimStrs(dIndex), "_pValue_Topo"), "-djpeg", "-r200");
end

ResName = strcat(FIGPATH, "cdrPlot_", AREANAME, ".mat");
FFT_60ms = trialsFFT{4};
FFT_30ms = trialsFFT{5};
save(ResName, "cdrPlot", "PMean", "Protocol", "FFT_60ms", "FFT_30ms", "-mat");
end
if ~isempty(gcp('nocreate'))
    delete(gcp('nocreate'));
end
close all
