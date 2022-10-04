clc; clear; 

% MATPATH = 'E:\ECoG\MAT Data\cc\BlkFreqLoc Active\cc20220903\cc20220903_PFC.mat';
MATPATH = {'E:\ECoG\MAT Data\XX\BlkFreqLoc Active\xx20220905\xx20220905_AC.mat'...
           'E:\ECoG\MAT Data\XX\BlkFreqLoc Active\xx20220905\xx20220905_PFC.mat'...
           'E:\ECoG\MAT Data\CC\BlkFreqLoc Active\cc20220903\cc20220903_AC.mat'...
           'E:\ECoG\MAT Data\CC\BlkFreqLoc Active\cc20220903\cc20220903_PFC.mat'...
           };
pos = [1, 2, 1 ,2];
icSelect = [2, 12, 1, 1];
ROOTPATH = "E:\ECOG\ICAFigures\BlkFreqLoc\";
FIGPATH = "E:\ECoG\corelDraw\PEOddBlkFreqLoc\Figure2\";

for mIndex = 1 : 4
params.posIndex = pos(mIndex); % 1-AC, 2-PFC
params.choiceWin = [100, 600];
params.processFcn = @ActiveProcess_freqLoc;

temp = string(split(MATPATH{mIndex}, '\'));
DateStr = temp(end - 1);

AREANAME = ["AC", "PFC"];
FEATRUE = ["Freq", "Loc"];
AREANAME = AREANAME(params.posIndex);

mkdir(FIGPATH);

%% Processing
[trialAll, ECOGDataset] = ECOGPreprocess(MATPATH{mIndex}, params);

%% ICA
ICAPATH = strcat(ROOTPATH, DateStr, "\ICA\");
    ICAName = strcat(ICAPATH, "comp_", DateStr, "_", AREANAME, ".mat");
    if ~exist(ICAName, "file")
        [ECOGDataset, comp, FigICAWave, FigTopo] = toDoICA(ECOGDataset, trialAll, 500);
        print(FigICAWave, strcat(ICAPATH, AREANAME, "_ICA_Wave_", DateStr), "-djpeg", "-r200");
        print(FigTopo, strcat(ICAPATH, AREANAME, "_ICA_Topo_",  DateStr), "-djpeg", "-r200");
        save(ICAName, "comp", "-mat");
    else
        load(ICAName);
        ECOGDataset.data = comp.unmixing * ECOGDataset.data;
    end

    FigTopo = plotTopo(comp, [8, 8], [1, 1], icSelect(mIndex));
print(FigTopo, strcat(FIGPATH, AREANAME, "_IC_example_", DateStr), "-djpeg", "-r200");

%% trial select
block1Idx = mod([trialAll.trialNum]', 80) >= 1 & mod([trialAll.trialNum]', 80) <= 20;
block2Idx = mod([trialAll.trialNum]', 80) >= 21 & mod([trialAll.trialNum]', 80) <= 40;
block3Idx = mod([trialAll.trialNum]' - 1, 80) >= 40 & mod([trialAll.trialNum]', 80) <= 79;
stdFreq = unique([trialAll([trialAll.oddballType]' == "STD").devFreq]);
stdLoc = unique([trialAll([trialAll.oddballType]' == "STD").devLoc]);
trialsBlkFreq = trialAll([trialAll.devLoc]' == stdLoc & block1Idx);
trialsRandFreq = trialAll([trialAll.devLoc]' == stdLoc & block3Idx);
trialsBlkLoc = trialAll([trialAll.devFreq]' == stdFreq & block2Idx);
trialsRandLoc = trialAll([trialAll.devFreq]' == stdFreq & block3Idx);

devType = [trialAll.devType]';
dRatio = unique(devType(([trialAll.devType]' > 0)));

%% Prediction error
window = [-200, 800]; % ms
t = linspace(window(1), window(2), diff(window) /1000 * ECOGDataset.fs + 1)';
cdrPlot(mIndex).info = strcat(AREANAME, "_", DateStr);
cdrPlot(mIndex).blkFreqCdr = zeros(length(t), 2 * length(dRatio));
cdrPlot(mIndex).randFreqCdr = zeros(length(t), 2 * length(dRatio));  
cdrPlot(mIndex).blkLocCdr =  zeros(length(t), 2 * length(dRatio));
cdrPlot(mIndex).randLocCdr = zeros(length(t), 2 * length(dRatio));

colors = ["k", "b", "#FFA500", "r"];
for dIndex = 2 : length(dRatio)
    trialsBlkFreqC = trialsBlkFreq([trialsBlkFreq.devType]' == dIndex &  [trialsBlkFreq.correct]' == true);
    trialsBlkLocC = trialsBlkLoc([trialsBlkLoc.devType]' == dIndex &  [trialsBlkLoc.correct]' == true);
    trialsRandFreqC = trialsRandFreq([trialsRandFreq.devType]' == dIndex &  [trialsRandFreq.correct]' == true);
    trialsRandLocC = trialsRandLoc([trialsRandLoc.devType]' == dIndex &  [trialsRandLoc.correct]' == true);
    [~, chMeanBlkFreqC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsBlkFreqC, "dev onset", window);
    [~, chMeanRandFreqC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsRandFreqC, "dev onset", window);
    [~, chMeanBlkLocC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsBlkLocC, "dev onset", window);
    [~, chMeanRandLocC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsRandLocC, "dev onset", window);

    cdrPlot(mIndex).blkFreqCdr(:, 2 * dIndex - 1) = t;
    cdrPlot(mIndex).blkFreqCdr(:, 2 * dIndex) = chMeanBlkFreqC(dIndex - 1).chMean(icSelect(mIndex), :)';

    cdrPlot(mIndex).randFreqCdr(:, 2 * dIndex - 1) = t;
    cdrPlot(mIndex).randFreqCdr(:, 2 * dIndex) = chMeanRandFreqC(dIndex - 1).chMean(icSelect(mIndex), :)';

    cdrPlot(mIndex).blkLocCdr(:, 2 * dIndex - 1) = t;
    cdrPlot(mIndex).blkLocCdr(:, 2 * dIndex) = chMeanBlkLocC(dIndex - 1).chMean(icSelect(mIndex), :)';

    cdrPlot(mIndex).randLocCdr(:, 2 * dIndex - 1) = t;
    cdrPlot(mIndex).randLocCdr(:, 2 * dIndex) = chMeanRandLocC(dIndex - 1).chMean(icSelect(mIndex), :)';
end
end







