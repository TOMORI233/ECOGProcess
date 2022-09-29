close all; clc; clear;
% MATPATH = 'E:\ECoG\MAT Data\XX\BlkFreqLoc Active\xx20220905\xx20220905_PFC.mat';
MATPATH = 'E:\ECoG\MAT Data\cc\BlkFreqLoc Active\cc20220903\cc20220903_AC.mat';

ROOTPATH = "E:\ECOG\Figures\BlkFreqLoc\";
params.posIndex = 1; % 1-AC, 2-PFC
params.choiceWin = [100, 600];
params.processFcn = @ActiveProcess_freqLoc;

temp = string(split(MATPATH, '\'));
DateStr = temp(end - 1);

AREANAME = ["AC", "PFC"];
FEATRUE = ["Freq", "Loc"];
AREANAME = AREANAME(params.posIndex);
BPATH = strcat(ROOTPATH, DateStr, "\Behavior\");
PEPATH = strcat(ROOTPATH, DateStr, "\Prediction error\");
PPATH = strcat(ROOTPATH, DateStr, "\Prediction\");
DMPATH = strcat(ROOTPATH, DateStr, "\Decision making\");
MMNPATH = strcat(ROOTPATH, DateStr, "\MMN\");
PUSHPATH = strcat(ROOTPATH, DateStr, "\Push\");
mkdir(BPATH);
mkdir(PEPATH);
mkdir(PPATH);
mkdir(DMPATH);
mkdir(MMNPATH);
mkdir(PUSHPATH);

%% Processing
[trialAll, ECOGDataset] = ECOGPreprocess(MATPATH, params);

%% Behavior
FigBehavior = BFLBehavior(trialAll);
print(FigBehavior, strcat(BPATH, "Behavior_", DateStr), "-djpeg", "-r200");

%% MMN 
[MMNBlkWaveFig, MMNRandWaveFig, MMNDiffWaveFig] = BFLMMN(trialAll, ECOGDataset);
scaleAxes([MMNBlkWaveFig, MMNRandWaveFig, MMNDiffWaveFig], "x", [-600, 1000]);
scaleAxes([MMNBlkWaveFig, MMNRandWaveFig, MMNDiffWaveFig], "y", [], [-60, 60], "max");

for fIndex = 1 : length(MMNBlkWaveFig)
print(MMNBlkWaveFig(fIndex), strcat(MMNPATH, AREANAME, "_MMN_Block_", FEATRUE(fIndex), "_Correct_", DateStr), "-djpeg", "-r200");
print(MMNRandWaveFig(fIndex), strcat(MMNPATH, AREANAME, "_MMN_Rand_", FEATRUE(fIndex), "_Correct_", DateStr), "-djpeg", "-r200");
end
for fIndex = 1 : length(MMNDiffWaveFig)
print(MMNDiffWaveFig(fIndex), strcat(MMNPATH, AREANAME, "_MMN_Diff_", num2str(fIndex + 1), "_Correct_", DateStr), "-djpeg", "-r200");
end

%% Prediction
[FigPWave, FigPTFA, FigPDiffWave, FigPDiffTFA] = BFLPrediction(trialAll, ECOGDataset);
scaleAxes(FigPWave, "y", [-60, 60]);
scaleAxes(FigPDiffWave, "y", [-20, 20]);
scaleAxes(FigPTFA, "c", [0, 6]);
scaleAxes(FigPDiffTFA, "c", [-5, 5]);

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
scaleAxes([PEBlkWaveFig, PERandWaveFig, PEDiffWaveFig], "y", [-60, 60]);


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
scaleAxes([PushBlkWaveFig, PushRandWaveFig, PushDiffWaveFig], "y", [-80, 80]);
for fIndex = 1 : length(PushBlkWaveFig)
print(PushBlkWaveFig(fIndex), strcat(PUSHPATH, AREANAME, "_Push_Block_", FEATRUE(fIndex), "_Correct_", DateStr), "-djpeg", "-r200");
print(PushRandWaveFig(fIndex), strcat(PUSHPATH, AREANAME, "_Push_Rand_", FEATRUE(fIndex), "_Correct_", DateStr), "-djpeg", "-r200");
end
for fIndex = 1 : length(PushDiffWaveFig)
print(PushDiffWaveFig(fIndex), strcat(PUSHPATH, AREANAME, "_Push_Diff_", num2str(fIndex + 1), "_Correct_", DateStr), "-djpeg", "-r200");
end

