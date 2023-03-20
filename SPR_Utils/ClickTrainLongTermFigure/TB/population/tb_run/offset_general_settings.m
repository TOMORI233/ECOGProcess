% basic
monkeyStr = ["CC", "XX"];
ROOTPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\Offset\";
params.posIndex = 1; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;
AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);

% for ICA
badCH_self = {[34, 49], [2, 48,49,57,64]};

% for CRI
CRIMethod = 2;
CRIMethodStr = ["Resp_devided_by_Spon", "R_minus_S_devide_R_plus_S"];
quantWin = [0 300];
sponWin = [-300 0];
CRITest = [1, 0];
pBase = 0.01;
plotWin = [-10, 600];

sigma = 5;
smthBin = 30;
latencyWin = [-500, 500];
latencySet(1).Win = [40, 200];
latencySet(2).Win = [70, 200];
latencySet(1).NP = 1*ones(64, 1);