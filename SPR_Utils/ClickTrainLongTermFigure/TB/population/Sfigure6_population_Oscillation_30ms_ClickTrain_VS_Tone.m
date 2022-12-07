close all; clc; clear;

monkeyStr = ["CC", "XX"];
ROOTPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\Basic\";
params.posIndex = 1; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;

% Synchronize response index
SRIMethod = 2;
SRIMethodStr = ["Resp_devided_by_Spon", "R_minus_S_devide_R_plus_S"];
SRIScale = [0.8, 2; 0 0.2];
SRITest = [1, 0];
pBase = 0.01;

% FFT method
FFTMethod = 2; %1: power(dB); 2: magnitude
fftScale = [60, 60; 400, 400];
correspFreq = 1000./[60, 30];

flp = 400;
fhp = 0.1;
segOption = ["trial onset", "dev onset"];
s1OnsetOrS2Onset = 1; % 1, s1onset; 2, s2Onset
stimStrs = ["ClickTrain_VS_Tone_60ms", "ClickTrain_VS_Tone_30ms"];
durationStr = ["60ms", "30ms"];

AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);

fs = 500;

for mIndex = 1 : length(monkeyStr)

    FIGPATH1 = strcat(ROOTPATH, "\Pop_Figure6_Osci_Control\",  SRIMethodStr(SRIMethod), "\", monkeyStr(mIndex), "\");
    FIGPATH2 = strcat(ROOTPATH, "\Pop_Sfigure6_Osci_Tone\",  SRIMethodStr(SRIMethod), "\", monkeyStr(mIndex), "\");
    %% process
    disp("loading data...");
    tic
    res_1 = load(strcat(FIGPATH1, "res_", AREANAME, ".mat"));
    res_2 = load(strcat(FIGPATH2, "res_", AREANAME, ".mat"));
    toc

    %% compare and plot rawWave
    for  dIndex = 1 : length(stimStrs)
        fftPValue(dIndex).info = stimStrs(dIndex);
        % get data
        CTL_FFT = res_1.(strcat("FFT_", durationStr(dIndex)));
        Tone_FFT = res_2.trialsFFT{dIndex};
        targetIdx = res_2.targetIdx;
        ff = res_2.ff;

% 
%         Successive(1).chMean = PMean{dIndex}; Successive(1).color = "r";
%         Successive(2).chMean = PMean{length(devType)}; Successive(2).color = "k";
%         
        [H, P] = waveFFTPower_pValue(Tone_FFT, CTL_FFT, [{ff}, {ff}], targetIdx(2 * dIndex - 1), 2);
        fftPValue(dIndex).(strcat(stimStrs(dIndex), "_pValue")) = P;
        fftPValue(dIndex).(strcat(stimStrs(dIndex), "_H")) = H;
    end

%% p-value distribution

for dIndex = 1 : length(stimStrs)
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
    print(FigTopo(dIndex), strcat(FIGPATH2, stimStrs(dIndex), "_pValue_Topo"), "-djpeg", "-r200");
end


end

close all


