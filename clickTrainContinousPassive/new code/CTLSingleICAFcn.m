function CTLSingleICAFcn(MATPATH, ROOTPATH, posIndex)

%% Parameter settings
params.posIndex = posIndex; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;



temp = string(split(MATPATH, '\'));
DateStr = temp(end - 1);
Protocol = temp(end - 2);

opts.flp = 400;
opts.fhp = 0.1;
opts.Protocol = Protocol;
opts.segOption = ["trial onset", "dev onset"];
opts.s1OnsetOrS2Onset = 1; % 1, s1onset; 2, s2Onset


AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);
ICAPATH = strcat(ROOTPATH, DateStr, "\ICA\");
WAVEPATH = strcat(ROOTPATH, DateStr, "\Wave\");
FFTPATH = strcat(ROOTPATH, DateStr, "\FFT\");
mkdir(ICAPATH);
mkdir(WAVEPATH);
mkdir(FFTPATH);

%% Processing
[trialAll, ECOGDataset] = ECOGPreprocess(MATPATH, params);


%% series of successive ...
if contains(Protocol, "successive")
    waveYScale = [-10 10; -1.5 1.5];
    fftYScale = [-1 1; -0.4 0.4];
    [FigWave, FigFFT, FigTFA] = CTLSucICAFcn(trialAll, ECOGDataset, opts);
    scaleAxes(FigWave, "y", [], waveYScale(posIndex, :));
    scaleAxes(FigFFT, "y", [], [0 fftYScale(posIndex, 2)]);
    scaleAxes(FigFFT, "x", [0 20]);
    scaleAxes(FigTFA, "c", [], [0 fftYScale(posIndex, 2)]);
    scaleAxes(FigTFA, "x", [1000 10000]);

    if contains(DateStr, "cc")
        plotLayout([FigWave, FigFFT], posIndex);
    elseif contains(DateStr, "xx")
        plotLayout([FigWave, FigFFT], posIndex + 2);
    end
    for fIndex = 1 : length(FigFFT)
        print(FigFFT(fIndex), strcat(FFTPATH, AREANAME, "_FFT_Order", num2str(fIndex), "_", Protocol), "-djpeg", "-r200");
        print(FigWave(fIndex), strcat(WAVEPATH, AREANAME, "_Wave_Order", num2str(fIndex), "_", Protocol), "-djpeg", "-r200");
        print(FigTFA(fIndex), strcat(WAVEPATH, AREANAME, "_TFA_Order", num2str(fIndex), "_", Protocol), "-djpeg", "-r200");
    end
    
%% series of Basic ...
elseif contains(Protocol, "Basic")
    opts.s1OnsetOrS2Onset = 2; % 1, s1onset; 2, s2Onset
    [FigWave, FigFFT] = CTLBasicFcn(trialAll, ECOGDataset, opts);
    scaleAxes(FigWave, "y", [-60 60]);
    scaleAxes(FigWave, "x", [-10 600]);
    scaleAxes(FigFFT, "y", [0 8]);
    scaleAxes(FigFFT, "x", [0 300]);
    if contains(DateStr, "cc")
        plotLayout([FigWave, FigFFT], posIndex);
    elseif contains(DateStr, "xx")
        plotLayout([FigWave, FigFFT], posIndex + 2);
    end
    for fIndex = 1 : length(FigFFT)
        print(FigFFT(fIndex), strcat(FFTPATH, AREANAME, "_Wave_Order", num2str(fIndex), "_", Protocol), "-djpeg", "-r200");
        print(FigWave(fIndex), strcat(WAVEPATH, AREANAME, "_FFT_Order", num2str(fIndex), "_", Protocol), "-djpeg", "-r200");
    end


end
close all