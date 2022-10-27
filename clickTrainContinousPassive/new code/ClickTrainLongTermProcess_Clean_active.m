close all; clc; clear;

MATPATH = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\Successive_0o3_0o5\xx20220929\xx20220929_AC.mat';
ROOTPATH = "E:\ECOG\Figures\ClickTrainLongTerm\Successive_0o3_0o5\";
% MATPATH = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\successive_Tone_250-246_240_200\cc20221011\cc20221011_AC.mat';
% ROOTPATH = "E:\ECOG\Figures\ClickTrainLongTerm\successive_Tone_250-246_240_200\";

% MATPATH = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Basic_ICI4\cc20220610\cc20220610_AC.mat';
% ROOTPATH = "E:\ECOG\Figures\ClickTrainLongTerm\Basic_ICI4\";
params.posIndex = 1; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;



temp = string(split(MATPATH, '\'));
DateStr = temp(end - 1);
Protocol = temp(end - 2);

opts.flp = 400;
opts.fhp = 0.1;
opts.Protocol = Protocol;
opts.segOption = ["trial onset", "dev onset"];

opts.s1OnsetOrS2Onset = 2; % 1, s1onset; 2, s2Onset

AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);

WAVEPATH = strcat(ROOTPATH, DateStr, "\Wave\");
FFTPATH = strcat(ROOTPATH, DateStr, "\FFT\");
mkdir(WAVEPATH);
mkdir(FFTPATH);


%% segregate trials
[trialAll, ECOGDataset] = ECOGPreprocess(MATPATH, params);

%% series of Successive ...
if contains(Protocol, "Successive")
    opts.s1OnsetOrS2Onset = 1; % 1, s1onset; 2, s2Onset
    [FigWave, FigFFT, filterRes] = CTLSucFcn(trialAll, ECOGDataset, opts);
    scaleAxes(FigWave, "y", [-60 60]);
    scaleAxes(FigFFT, "y", [20 60]);
    scaleAxes(FigFFT, "x", [0 20]);
    if contains(DateStr, "cc")
        plotLayout([FigWave, FigFFT], params.posIndex);
    elseif contains(DateStr, "xx")
        plotLayout([FigWave, FigFFT], params.posIndex + 2);
    end
    for fIndex = 1 : length(FigFFT)
        print(FigFFT(fIndex), strcat(FFTPATH, AREANAME, "_Wave_Order", num2str(fIndex), "_", Protocol), "-djpeg", "-r200");
        print(FigWave(fIndex), strcat(WAVEPATH, AREANAME, "_FFT_Order", num2str(fIndex), "_", Protocol), "-djpeg", "-r200");
    end
%% series of Basic ...
elseif contains(Protocol, "Basic")
    opts.s1OnsetOrS2Onset = 2; % 1, s1onset; 2, s2Onset
    [FigWave, FigFFT, filterRes] = CTLBasicFcn(trialAll, ECOGDataset, opts);
    scaleAxes(FigWave, "y", [-60 60]);
    scaleAxes(FigWave, "x", [-10 600]);
    scaleAxes(FigFFT, "y", [0 8]);
    scaleAxes(FigFFT, "x", [0 300]);
    if contains(DateStr, "cc")
        plotLayout([FigWave, FigFFT], params.posIndex);
    elseif contains(DateStr, "xx")
        plotLayout([FigWave, FigFFT], params.posIndex + 2);
    end
    for fIndex = 1 : length(FigFFT)
        print(FigFFT(fIndex), strcat(FFTPATH, AREANAME, "_Wave_Order", num2str(fIndex), "_", Protocol), "-djpeg", "-r200");
        print(FigWave(fIndex), strcat(WAVEPATH, AREANAME, "_FFT_Order", num2str(fIndex), "_", Protocol), "-djpeg", "-r200");
    end

end

close all
