close all; clc; clear;
% MATPATH = 'E:\ECoG\MAT Data\XX\BlkFreqLoc Active\xx20220905\xx20220905_PFC.mat';
MATPATH = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\successive_0o1_0o2\cc20220927\cc20220927_AC.mat';
ROOTPATH = "E:\ECOG\Figures\ClickTrainLongTerm\successive_0o1_0o2\";

params.posIndex = 1; % 1-AC, 2-PFC
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
WAVEPATH = strcat(ICAPATH, "Wave\");
FFTPATH = strcat(ICAPATH, "FFT\");
mkdir(ICAPATH);
mkdir(WAVEPATH);
mkdir(FFTPATH);


%% Processing
[trialAll, ECOGDataset] = ECOGPreprocess(MATPATH, params);

ICAName = strcat(ICAPATH, "comp_", AREANAME, ".mat");
if ~exist(ICAName, "file")
    [ECOGDataset, comp, FigICAWave, FigTopo] = CTLICA(ECOGDataset, trialAll, 500, opts);
    print(FigICAWave, strcat(ICAPATH, AREANAME, "_ICA_Wave_", DateStr), "-djpeg", "-r200");
    print(FigTopo, strcat(ICAPATH, AREANAME, "_ICA_Topo_",  DateStr), "-djpeg", "-r200");
    save(ICAName, "comp", "-mat");
else
    load(ICAName);
    ECOGDataset.data = comp.unmixing * ECOGDataset.data;
end

if contains(Protocol, "successive")
    [FigWave, FigFFT, filterRes] = CTLSucFcn(trialAll, ECOGDataset, opts);
    scaleAxes(FigWave, "y", [-10 10]);
    scaleAxes(FigFFT, "y", [0 1]);
    scaleAxes(FigFFT, "x", [0 20]);
    set([FigWave, FigFFT], "outerposition", [300, 100, 800, 670]);
    for fIndex = 1 : length(FigFFT)
        print(FigFFT(fIndex), strcat(FFTPATH, AREANAME, "_Wave_Order", num2str(fIndex), "_", Protocol), "-djpeg", "-r200");
        print(FigWave(fIndex), strcat(WAVEPATH, AREANAME, "_FFT_Order", num2str(fIndex), "_", Protocol), "-djpeg", "-r200");
    end
end

close all
