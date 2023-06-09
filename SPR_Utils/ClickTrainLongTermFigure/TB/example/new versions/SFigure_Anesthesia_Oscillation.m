close all; clc; clear;

MATPATH = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\TB\TB_Anesthesia_Osci_Rate_40\xx20230531\xx20230531_AC.mat';
if contains(MATPATH, "xx")
    mIndex = 2;
elseif contains(MATPATH, "cc")
    mIndex = 1;
end
% MATPATH{2} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\Add_on_Basic_Oscillation_control_500_250_125_60_30\xx20221027\xx20221027_AC.mat';
monkeyStr = ["CC", "XX"];
ROOTPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\Anesthesia\";
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
fs = 600;

segOption = ["trial onset", "dev onset"];
s1OnsetOrS2Onset = 1; % 1, s1onset; 2, s2Onset
colors = ["#FF0000", "#0000FF", "#000000", "#AAAAAA"];
stimStrs = ["120ms-4-4o06", "60ms-4-4o06", "60ms-250-246", "60ms-250-200"];

AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);



badCh = {[], []};
yScale = [60, 90];
quantWin = [0 300];
latencyWin = [80 200];
sponWin = [-300 0];



%% process
temp = string(split(MATPATH, '\'));
DateStr = temp(end - 1);
Protocol = temp(end - 2);
FIGPATH = strcat(ROOTPATH, "Figure_", Protocol,"\", DateStr, "_", AREANAME, "\Figures\");
mkdir(FIGPATH)
% if exist(FIGPATH, "dir")
%     return
% end

tic
[trialAll, trialsECOG_Merge, trialsECOG_S1_Merge, badCHs] =  mergeCTLTrialsECOG(MATPATH, params.posIndex);
toc

%% ICA
run("CTLconfig.m");
run("tb_ICA.m");
run("tb_chPatch.m");
run("tb_interpolateBadChs");

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
            cdrPlot(ch).Wave(:, 2 * dIndex - 1) = t';
            cdrPlot(ch).Wave(:, 2 * dIndex) = chMean{dIndex}(ch, :)';
            cdrPlot(ch).FFT(:, 2 * dIndex - 1) = ff;
            cdrPlot(ch).FFT(:, 2 * dIndex) = PMean{dIndex}(ch, :)';
        end
    end
%% plot RawWave
    for  dIndex = 1 : length(devType)
        % plot rawWave
        FigWave = plotRawWave(chMean{dIndex}, [], Window, strcat(stimStrs(dIndex), " Oscillation"), [8, 8]);
        FigWave = deleteLine(FigWave, "LineStyle", "--");
        scaleAxes(FigWave, "x",Window);
        scaleAxes(FigWave, "y", [-30 30]);
        %     setAxes(FigWave, "Xscale", "log");
        lines(1).X = correspFreq(dIndex); lines(1).color = "k";
        addLines2Axes(FigWave, lines);
        setLine(FigWave, "YData", [-30 30], "LineStyle", "--");
        pause(1);
        plotLayout(FigWave, params.posIndex + 2 * (mIndex - 1), 0.3);
        print(FigWave, strcat(FIGPATH, Protocol, "_RawWave_", stimStrs(dIndex)), "-djpeg", "-r200");
        close(FigWave);
    end

    %% plot FFT
    for  dIndex = 1 : length(devType)
        fftPValue(dIndex).info = stimStrs(dIndex);
        pMean = PMean{dIndex}; 
        [H, P] = waveFFTPower_pValue(trialsFFT{dIndex}, trialsFFT{length(devType)}, [{ff}, {ff}], targetIdx(dIndex), 2);
        fftPValue(dIndex).pValue = P;
        fftPValue(dIndex).H = H;
        % plot FFT result
        FigWave = plotRawWave(pMean, [], [0 fs/2], strcat(stimStrs(dIndex), " Oscillation"), [8, 8]);
        FigWave = deleteLine(FigWave, "LineStyle", "--");
        scaleAxes(FigWave, "y",[0, 30]);
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

ResName = strcat(FIGPATH, "cdrPlot_", AREANAME, ".mat");
save(ResName, "cdrPlot", "PMean", "Protocol", "-mat");

close all
