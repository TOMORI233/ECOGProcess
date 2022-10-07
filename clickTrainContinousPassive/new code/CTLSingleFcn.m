function CTLSingleFcn(MATPATH, ROOTPATH, posIndex)

%% Parameter settings
params.posIndex = posIndex; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;



temp = string(split(MATPATH, '\'));
DateStr = temp(end - 1);
Protocol = temp(end - 2);

opts.flp = 400;
opts.fhp = 0.1;
opts.Protocol = Protocol;
opts.s1OnsetOrS2Onset = 1; % 1, s1onset; 2, s2Onset
opts.segOption = ["trial onset", "dev onset"];

AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);

WAVEPATH = strcat(ROOTPATH, DateStr, "\Wave\");
FFTPATH = strcat(ROOTPATH, DateStr, "\FFT\");
mkdir(WAVEPATH);
mkdir(FFTPATH);

%% Processing
[trialAll, ECOGDataset] = ECOGPreprocess(MATPATH, params);

if contains(Protocol, "successive")
    [FigWave, FigFFT] = CTLSucFcn(trialAll, ECOGDataset, opts);
    scaleAxes(FigWave, "y", [-50 50]);
    scaleAxes(FigFFT, "y", [0 8]);
    scaleAxes(FigFFT, "x", [0 20]);
    set([FigWave, FigFFT], "outerposition", [300, 100, 800, 670]);
    for fIndex = 1 : length(FigFFT)
        print(FigFFT(fIndex), strcat(FFTPATH, AREANAME, "_Wave_Order", num2str(fIndex), "_", Protocol), "-djpeg", "-r200");
        print(FigWave(fIndex), strcat(WAVEPATH, AREANAME, "_FFT_Order", num2str(fIndex), "_", Protocol), "-djpeg", "-r200");
    end
end
close all