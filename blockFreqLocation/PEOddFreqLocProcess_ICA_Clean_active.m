close all; clc; clear;
MATPATH = 'E:\ECoG\MAT Data\cc\BlkFreqLoc Active\cc20220909\cc20220909_AC.mat';
% MATPATH = 'E:\ECoG\MAT Data\XX\BlkFreqLoc Active\xx20220905\xx20220905_PFC.mat';
ROOTPATH = "E:\ECOG\ICAFigures\BlkFreqLoc\";

params.posIndex = 1; % 1-AC, 2-PFC
params.choiceWin = [100, 600];
params.processFcn = @ActiveProcess_freqLoc;

temp = string(split(MATPATH, '\'));
DateStr = temp(end - 1);

AREANAME = ["AC", "PFC"];
FEATRUE = ["Freq", "Loc"];
AREANAME = AREANAME(params.posIndex);
ICAPATH = strcat(ROOTPATH, DateStr, "\ICA\");
BPATH = strcat(ROOTPATH, DateStr, "\Behavior\");
PEPATH = strcat(ROOTPATH, DateStr, "\Prediction error\");
PPATH = strcat(ROOTPATH, DateStr, "\Prediction\");
DMPATH = strcat(ROOTPATH, DateStr, "\Decision making\");
MMNPATH = strcat(ROOTPATH, DateStr, "\MMN\");
PUSHPATH = strcat(ROOTPATH, DateStr, "\Push\");
mkdir(ICAPATH);
mkdir(BPATH);
mkdir(PEPATH);
mkdir(PPATH);
mkdir(DMPATH);
mkdir(MMNPATH);
mkdir(PUSHPATH);

%% Processing
[trialAll, ECOGDataset] = ECOGPreprocess(MATPATH, params);

%% ICA

yScale = [-2 2];
ICAName = strcat(ICAPATH, "comp_", DateStr, "_", AREANAME, ".mat");
if ~exist(ICAName, "file")
    [ECOGDataset, comp, FigICAWave, FigTopo] = CTLToDoICA(ECOGDataset, trialAll, 500);
    print(FigICAWave, strcat(ICAPATH, AREANAME, "_ICA_Wave_", DateStr), "-djpeg", "-r200");
    print(FigTopo, strcat(ICAPATH, AREANAME, "_ICA_Topo_",  DateStr), "-djpeg", "-r200");
    save(ICAName, "comp", "-mat");
else
    load(ICAName);
    ECOGDataset.data = comp.unmixing * ECOGDataset.data;
end

% %% Behavior
% FigBehavior = BFLBehavior(trialAll);
% print(FigBehavior, strcat(BPATH, "Behavior_", DateStr), "-djpeg", "-r200");

% %% MMN
%
% [MMNBlkWaveFig, MMNRandWaveFig, MMNDiffWaveFig] = BFLMMN(trialAll, ECOGDataset);
% scaleAxes([MMNBlkWaveFig, MMNRandWaveFig, MMNDiffWaveFig], "x", [-600, 1000]);
% scaleAxes([MMNBlkWaveFig, MMNRandWaveFig, MMNDiffWaveFig], "y", [], yScale, "max");
%
% for fIndex = 1 : length(MMNBlkWaveFig)
% print(MMNBlkWaveFig(fIndex), strcat(MMNPATH, AREANAME, "_MMN_Block_", FEATRUE(fIndex), "_Correct_", DateStr), "-djpeg", "-r200");
% print(MMNRandWaveFig(fIndex), strcat(MMNPATH, AREANAME, "_MMN_Rand_", FEATRUE(fIndex), "_Correct_", DateStr), "-djpeg", "-r200");
% end
% for fIndex = 1 : length(MMNDiffWaveFig)
% print(MMNDiffWaveFig(fIndex), strcat(MMNPATH, AREANAME, "_MMN_Diff_", num2str(fIndex + 1), "_Correct_", DateStr), "-djpeg", "-r200");
% end

%% Prediction

[FigPWave, FigPTFA, FigPDiffWave, FigPDiffTFA] = BFLPrediction(trialAll, ECOGDataset);
scaleAxes(FigPWave, "y", [], yScale, "max");
scaleAxes(FigPDiffWave, "y", [], yScale/2, "max");
scaleAxes(FigPTFA, "c", [0, yScale(2)/6]);
scaleAxes(FigPDiffTFA, "c", yScale/12);

PETitle = ["block freq", "block loc", "rand"];
diffTitle = [" blk freq-blk loc ", " block freq-rand ", " block loc-rand "];

print(FigPWave, strcat(PPATH, AREANAME, "_Prediction_Raw_", DateStr), "-djpeg", "-r200");

for fIndex = 1 : length(FigPTFA)
    print(FigPTFA(fIndex), strcat(PPATH, AREANAME, "_Prediction_TFA_", PETitle(fIndex), "_", DateStr), "-djpeg", "-r200");
    print(FigPDiffWave(fIndex), strcat(PPATH, AREANAME, "_Prediction_Diff_Raw_", diffTitle(fIndex), "_", DateStr), "-djpeg", "-r200");
    print(FigPDiffTFA(fIndex), strcat(PPATH, AREANAME, "_Prediction_Diff_TFA_", diffTitle(fIndex), "_", DateStr), "-djpeg", "-r200");
end
%% Predictive error

[PEBlkWaveFig, PERandWaveFig, PEDiffWaveFig] = BFLPredictiveError(trialAll, ECOGDataset);

% Scale
scaleAxes([PEBlkWaveFig, PERandWaveFig, PEDiffWaveFig], "x", [-600, 1000]);
scaleAxes([PEBlkWaveFig, PERandWaveFig, PEDiffWaveFig], "y", [], yScale, "max");
scaleAxes([PEBlkWaveFig, PERandWaveFig, PEDiffWaveFig], "y", [-10 10]);


for fIndex = 1 : length(PEBlkWaveFig)
    print(PEBlkWaveFig(fIndex), strcat(PEPATH, AREANAME, "_PE_Block_", FEATRUE(fIndex), "_Correct_", DateStr), "-djpeg", "-r200");
    print(PERandWaveFig(fIndex), strcat(PEPATH, AREANAME, "_PE_Rand_", FEATRUE(fIndex), "_Correct_", DateStr), "-djpeg", "-r200");
end

for fIndex = 1 : length(PEDiffWaveFig)
    print(PEDiffWaveFig(fIndex), strcat(PEPATH, AREANAME, "_PE_Diff_", num2str(fIndex + 1), "_Correct_", DateStr), "-djpeg", "-r200");
end


%% Decision making
trialStr = ["trialsBlkFreq", "trialsRandFreq", "trialsBlkLoc", "trialsRandLoc"];
[FigDMCW, FigDMBlk, FigDMRand, FigDMDiff] = BFLDecisionMaking(trialAll, ECOGDataset);
scaleAxes([FigDMCW, FigDMBlk, FigDMRand, FigDMDiff], "x", [-600, 1000]);
scaleAxes([FigDMCW, FigDMBlk, FigDMRand, FigDMDiff], "y", [-1, 1]);

print(FigDMDiff, strcat(DMPATH, AREANAME, "_DM_Raw_C-W_", DateStr), "-djpeg", "-r200");
print(FigDMBlk, strcat(DMPATH, AREANAME, "_DM_Raw_Blk_Freq&Loc", DateStr), "-djpeg", "-r200");
print(FigDMRand, strcat(DMPATH, AREANAME, "_DM_Raw_Rand_Freq&Loc", DateStr), "-djpeg", "-r200");


for tIndex = 1 : 4
    print(FigDMCW(tIndex), strcat(DMPATH, AREANAME, trialStr(tIndex), "_DM_Raw_C&W", DateStr), "-djpeg", "-r200");
end


%% push
[PushBlkWaveFig, PushRandWaveFig, PushDiffWaveFig] = BFLPush(trialAll, ECOGDataset);

% Scale
scaleAxes([PushBlkWaveFig, PushRandWaveFig, PushDiffWaveFig], "x", [-600, 1000]);
scaleAxes([PushBlkWaveFig, PushRandWaveFig, PushDiffWaveFig], "y", [], yScale, "max");
for fIndex = 1 : length(PushBlkWaveFig)
    print(PushBlkWaveFig(fIndex), strcat(PUSHPATH, AREANAME, "_Push_Block_", FEATRUE(fIndex), "_Correct_", DateStr), "-djpeg", "-r200");
    print(PushRandWaveFig(fIndex), strcat(PUSHPATH, AREANAME, "_Push_Rand_", FEATRUE(fIndex), "_Correct_", DateStr), "-djpeg", "-r200");
end
for fIndex = 1 : length(PushDiffWaveFig)
    print(PushDiffWaveFig(fIndex), strcat(PUSHPATH, AREANAME, "_Push_Diff_", num2str(fIndex + 1), "_Correct_", DateStr), "-djpeg", "-r200");
end

close all;
