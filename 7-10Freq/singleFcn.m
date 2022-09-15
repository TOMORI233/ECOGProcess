function singleFcn(MATPATH, ROOTPATH, posIndex)
close all; clc;
%% Parameter settings
params.posIndex = posIndex; % 1-AC, 2-PFC
params.choiceWin = [100, 800];
params.processFcn = @ActiveProcess_7_10Freq;

temp = string(split(MATPATH, '\'));
DateStr = temp(end - 1);

AREANAME = ["AC", "PFC"];
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
FigBehavior = plotBehaviorOnly(trialAll, "r", "7-10 Freq");
drawnow;
print(FigBehavior, strcat(BPATH, "Behavior_", DateStr), "-djpeg", "-r200");

%% MMN - PE
FigMMN = MMN(trialAll, ECOGDataset);
scaleAxes(FigMMN, "y", [], [-100, 100], "max");
print(FigMMN, strcat(MMNPATH, AREANAME, "_MMN_Raw_Correct_", DateStr), "-djpeg", "-r200");

%% Prediction
FigP = prediction(trialAll, ECOGDataset);

%% Prediction error
[FigPE1, FigPE2] = PE(trialAll, ECOGDataset);

% Scale
scaleAxes([FigP(1), FigPE1], "y", [-80, 80]);
scaleAxes([FigP(2), FigPE2], "c", [], [0, 15]);

print(FigP(1), strcat(PPATH, AREANAME, "_Prediction_Raw_", DateStr), "-djpeg", "-r200");
print(FigP(2), strcat(PPATH, AREANAME, "_Prediction_TFA_", DateStr), "-djpeg", "-r200");

for dIndex = 1:length(FigPE1)
    print(FigPE1(dIndex), strcat(PEPATH, AREANAME, "_PE_Raw_", num2str(dIndex), "_", DateStr), "-djpeg", "-r200");
    print(FigPE2(dIndex), strcat(PEPATH, AREANAME, "_PE_TFA_", num2str(dIndex), "_", DateStr), "-djpeg", "-r200");
end

%% Decision making
[FigDM1, FigDM2] = decisionMaking(trialAll, ECOGDataset);
print(FigDM1, strcat(DMPATH, AREANAME, "_DM_Raw_", DateStr), "-djpeg", "-r200");
print(FigDM2, strcat(DMPATH, AREANAME, "_DM_TFA_", DateStr), "-djpeg", "-r200");

%% Push
[FigPush1, FigPush2] = push(trialAll, ECOGDataset);

% Scale
scaleAxes(FigPush1, "y", [-80, 80]);
scaleAxes(FigPush2, "c", [], [0, 15]);

for dIndex = 1:length(FigPush1)
    print(FigPush1(dIndex), strcat(PUSHPATH, AREANAME, "_Push_Raw_", num2str(dIndex), "_", DateStr), "-djpeg", "-r200");
    print(FigPush2(dIndex), strcat(PUSHPATH, AREANAME, "_Push_TFA_", num2str(dIndex), "_", DateStr), "-djpeg", "-r200");
end

end