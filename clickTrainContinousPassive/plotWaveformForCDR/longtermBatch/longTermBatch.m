clear all; clc
opts.monkeyId = ["chouchou", "xiaoxiao"];
opts.posStr = ["LAuC", "LPFC"];

%% for process content
opts.s1OnsetOrS2Onset = 1; % 1: start, 2: change
opts.dataType = "ica"; % "raw", "ica"
opts.paradigmType = "DiffICI_ind"; % RegIrreg, DiffICI_ind, DiffICI_merge, Others, Species
opts.processType = "synchronization"; % waveform, ampLatency, synchronization
opts.matFile = "filterResHP0o1Hz.mat";
opts.figRootPath = "E:\ECoG\corelDraw\jpgHP0o1Hz";
opts.matSavePath = "E:\ECoG\matData\longTermContinuous\cdrPlot0.1Hz";

%% for plot
opts.reprocess = 1; % if true, return cdrPlot, and save figures
opts.processCDR = 1; % if true and reprocess if false, return cdrPlot only
opts.selectWin = [-10 600];
opts.yScale = [60 60]; %% x1 is for the yScale of AC, x2 is for PFC

%% main 
cdrPlot = processLongTerm(opts);

%% save cdrPlot

zeroHour = ["S1", "S2"];
cdrPlotName = strcat("cdrPlot_", opts.dataType, "_", opts.paradigmType, "_", zeroHour(opts.s1OnsetOrS2Onset), "_", opts.processType);
eval(strcat(cdrPlotName, "= cdrPlot;"));
mkdir(fullfile(opts.matSavePath, opts.dataType))
save(fullfile(opts.matSavePath, opts.dataType, strcat(cdrPlotName, ".mat")), cdrPlotName, "-mat");


