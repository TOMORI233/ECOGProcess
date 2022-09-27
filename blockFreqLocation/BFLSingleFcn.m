function BFLSingleFcn(MATPATH, ROOTPATH, posIndex)
close all; clc;
%% Parameter settings
params.posIndex = posIndex; % 1-AC, 2-PFC
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
[MMNBlkWaveFig, MMNRandWaveFig] = BFLMMN(trialAll, ECOGDataset);
scaleAxes([MMNBlkWaveFig, MMNRandWaveFig], "x", [-600, 1000]);
scaleAxes([MMNBlkWaveFig, MMNRandWaveFig], "y", [], [0, 10], "max");

for fIndex = 1 : length(MMNBlkWaveFig)
print(MMNBlkWaveFig(fIndex), strcat(MMNPATH, AREANAME, "_MMN_Block_", FEATRUE(fIndex), "_Correct_", DateStr), "-djpeg", "-r200");
print(MMNRandWaveFig(fIndex), strcat(MMNPATH, AREANAME, "_MMN_Rand_", FEATRUE(fIndex), "_Correct_", DateStr), "-djpeg", "-r200");
end

%% Prediction
[FigPWave, FigPTFA] = BFLPrediction(trialAll, ECOGDataset);
scaleAxes(FigPWave, "y", [-80, 80]);
scaleAxes(FigPTFA, "c", [0, 10]);
PETitle = ["block freq", "block loc", "rand"];

print(FigPWave, strcat(PPATH, AREANAME, "_Prediction_Raw_", DateStr), "-djpeg", "-r200");
for fIndex = 1 : length(FigPWave)
print(FigPTFA(fIndex), strcat(PPATH, AREANAME, "_Prediction_TFA_", PETitle(fIndex), "_", DateStr), "-djpeg", "-r200");
end
%% Prediction error
[PEBlkWaveFig, PERandWaveFig] = BFLPredictiveError(trialAll, ECOGDataset);

% Scale
scaleAxes([PEBlkWaveFig, PERandWaveFig], "x", [-600, 1000]);
scaleAxes([PEBlkWaveFig, PERandWaveFig], "y", [-80, 80]);
for fIndex = 1 : length(PEBlkWaveFig)
print(PEBlkWaveFig(fIndex), strcat(PEPATH, AREANAME, "_PE_Block_", FEATRUE(fIndex), "_Correct_", DateStr), "-djpeg", "-r200");
print(PERandWaveFig(fIndex), strcat(PEPATH, AREANAME, "_PE_Rand_", FEATRUE(fIndex), "_Correct_", DateStr), "-djpeg", "-r200");
end

%% Decision making
trialStr = ["trialsBlkFreq", "trialsRandFreq", "trialsBlkLoc", "trialsRandLoc"];
[FigDMCW, FigDMBlk, FigDMRand, FigDMDiff] = BFLDecisionMaking(trialAll, ECOGDataset);
scaleAxes([FigDMCW, FigDMBlk, FigDMRand, FigDMDiff], "x", [-600, 1000]);
scaleAxes([FigDMCW, FigDMBlk, FigDMRand, FigDMDiff], "y", [-80, 80]);

print(FigDMDiff, strcat(DMPATH, AREANAME, "_DM_Raw_C-W_", DateStr), "-djpeg", "-r200");
print(FigDMBlk(1), strcat(DMPATH, AREANAME, "_DM_Raw_Blk_Freq", DateStr), "-djpeg", "-r200");
print(FigDMBlk(2), strcat(DMPATH, AREANAME, "_DM_Raw_Blk_Loc", DateStr), "-djpeg", "-r200");
print(FigDMRand(1), strcat(DMPATH, AREANAME, "_DM_Raw_Rand_Freq", DateStr), "-djpeg", "-r200");
print(FigDMRand(2), strcat(DMPATH, AREANAME, "_DM_Raw_Rand_Loc", DateStr), "-djpeg", "-r200");

for tIndex = 1 : 4
print(FigDMCW(tIndex), strcat(DMPATH, AREANAME, trialStr(tIndex), "_DM_Raw_C&W", DateStr), "-djpeg", "-r200");
end


%% push
[PushBlkWaveFig, PushRandWaveFig] = BFLPush(trialAll, ECOGDataset);

% Scale
scaleAxes([PushBlkWaveFig, PushRandWaveFig], "x", [-600, 1000]);
scaleAxes([PushBlkWaveFig, PushRandWaveFig], "y", [-80, 80]);
for fIndex = 1 : length(PushBlkWaveFig)
print(PushBlkWaveFig(fIndex), strcat(PEPATH, AREANAME, "_Push_Block_", FEATRUE(fIndex), "_Correct_", DateStr), "-djpeg", "-r200");
print(PushRandWaveFig(fIndex), strcat(PEPATH, AREANAME, "_Push_Rand_", FEATRUE(fIndex), "_Correct_", DateStr), "-djpeg", "-r200");
end

end