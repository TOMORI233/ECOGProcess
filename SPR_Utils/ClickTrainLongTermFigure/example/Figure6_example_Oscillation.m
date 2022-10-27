close all; clc; clear;

MATPATH{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Add_on_Basic_Oscillation_control_500_250_125_60_30\cc20221024\cc20221024_AC.mat';
MATPATH{2} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\Add_on_Basic_Oscillation_control_500_250_125_60_30\xx20221024\xx20221024_AC.mat';
monkeyStr = ["CC", "XX"];
ROOTPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\";
params.posIndex = 1; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;

% Synchronize response index
SRIMethod = 2;
SRIMethodStr = ["Resp_devided_by_Spon", "R_minus_S_devide_R_plus_S"];
SRIScale = [0.8, 2; 0 0.2];
SRITest = [1, 0];

% FFT method
FFTMethod = 2; %1: power(dB); 2: magnitude
fftScale = [60, 60; 400, 400];
correspFreq = 1000./[500, 250, 125, 60, 30, 1000];

flp = 400;
fhp = 0.1;
segOption = ["trial onset", "dev onset"];
s1OnsetOrS2Onset = 1; % 1, s1onset; 2, s2Onset
colors = ["#FF0000", "#FFA500", "#0000FF", "#000000", "#AAAAAA"];
stimStrs = ["Osc_500ms", "Osc_250ms", "Osc_125ms", "Osc_60ms", "Osc_30ms", "control"];

AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);



badCh = {[], []};
yScale = [60, 90];
quantWin = [0 300];
latencyWin = [80 200];
sponWin = [-300 0];
for mIndex = 1 : length(MATPATH)

    temp = string(split(MATPATH{mIndex}, '\'));
    DateStr = temp(end - 1);
    Protocol = temp(end - 2);
    FIGPATH = strcat(ROOTPATH, "Figure6_Oscillation\", DateStr, "\", SRIMethodStr(SRIMethod), "\");
    mkdir(FIGPATH);
    %% process
    [trialAll, ECOGDataset] = ECOGPreprocess(MATPATH{mIndex}, params);
    fs = ECOGDataset.fs;

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

    % cdrPlot initialize
    t = linspace(Window(1), Window(2), diff(Window) /1000 * ECOGDataset.fs + 1)';

%% diff stim type
    for dIndex = 1:length(devType)
        
        for ch = 1 : length(ECOGFDZ.channels)
            cdrPlot(ch).(strcat(stimStrs(dIndex), "info")) = strcat("Ch", num2str(ch));
            cdrPlot(ch).(strcat(stimStrs(dIndex), "Wave")) = zeros(length(t), 2 * length(devType));
        end
        tIndex = [trialAll.devOrdr] == devType(dIndex);
        trials = trialAll(tIndex);
        trialsECOG = selectEcog(ECOGFDZ, trials, segOption(s1OnsetOrS2Onset), Window);

        % exclude trial
        trialsECOG = excludeTrialsChs(trialsECOG, 0.1);
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
        set(FigWave, "outerposition", [300, 100, 800, 670]);
        plotLayout(FigWave, params.posIndex + 2 * (mIndex - 1), 0.3);
        print(FigWave, strcat(FIGPATH, Protocol, "_FFT_", stimStrs(dIndex)), "-djpeg", "-r200");
        close(FigWave);
    end

%% p-value distribution

for dIndex = 1 : length(devType) - 1
    % plot p-value topo
    temp = fftPValue(dIndex).(strcat(stimStrs(dIndex), "_pValue"));
    topo = logg(0.05, temp / 0.05);
    topo(isinf(topo)) = 5;
    topo(topo > 5) = 5;
    FigTopo(dIndex) = plotTopo_Raw(topo, [8, 8]);
    colormap(FigTopo(dIndex), "jet");
    scaleAxes(FigTopo(dIndex), "c", [-5 5]);
    set(FigTopo(dIndex), "outerposition", [300, 100, 800, 670]);
    print(FigTopo(dIndex), strcat(FIGPATH, stimStrs(dIndex), "_pValue_Topo"), "-djpeg", "-r200");
end





end

close all
