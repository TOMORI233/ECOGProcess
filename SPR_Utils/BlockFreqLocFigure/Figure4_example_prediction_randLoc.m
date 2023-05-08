clc; clear; 

MATPATH = {'E:\ECoG\MAT Data\XX\BlkFreqLoc Active\xx20220905\xx20220905_AC.mat'...
           'E:\ECoG\MAT Data\XX\BlkFreqLoc Active\xx20220905\xx20220905_PFC.mat'...
           'E:\ECoG\MAT Data\CC\BlkFreqLoc Active\cc20220903\cc20220903_AC.mat'...
           'E:\ECoG\MAT Data\CC\BlkFreqLoc Active\cc20220903\cc20220903_PFC.mat'...
           };
pos = [1, 2, 1 ,2];
icSelect = [3, 7, 2, 1];
cScale = [0.15, 0.5, 0.4, 0.25];
ROOTPATH = "E:\ECOG\ICAFigures\BlkFreqLoc\";
FIGPATH = "E:\ECoG\corelDraw\PEOddBlkFreqLoc\Figure4\";
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
        ECOGDatasetTemp = ECOGDataset;
        ECOGDataset.data = comp.unmixing * ECOGDataset.data;
    end

    FigTopo = plotTopoICA(comp, [8, 8], [1, 1], icSelect(mIndex));
print(FigTopo, strcat(FIGPATH, AREANAME, "_IC_example_", DateStr), "-djpeg", "-r200");

%% trial select
block1Idx = mod([trialAll.trialNum]', 80) >= 5 & mod([trialAll.trialNum]', 80) <= 20;
block2Idx = mod([trialAll.trialNum]', 80) >= 25 & mod([trialAll.trialNum]', 80) <= 40;
block3Idx = mod([trialAll.trialNum]' - 1, 80) >= 50 & mod([trialAll.trialNum]', 80) <= 79;
stdFreq = unique([trialAll([trialAll.oddballType]' == "STD").devFreq]);
stdLoc = unique([trialAll([trialAll.oddballType]' == "STD").devLoc]);
trialsBlkFreq = trialAll([trialAll.devLoc]' == stdLoc & block1Idx);
trialsRand = trialAll([trialAll.oddballType]' ~= "INTERRUPT" & block3Idx);
trialsBlkLoc = trialAll([trialAll.devFreq]' == stdFreq & block2Idx);

%% Prediction
window = [-2500, 6000]; % ms
fs = 500;
fs0 = ECOGDataset.fs;
t = linspace(window(1), window(2), diff(window) /1000 * ECOGDataset.fs + 1)';
PETitle = ["blockFreq", "blockLoc", "rand"];
cdrPlot(mIndex).info = strcat(AREANAME, "_", DateStr);
cdrPlot(mIndex).blockFreq(:, 1) = t;
cdrPlot(mIndex).blockLoc(:, 1) = t;
cdrPlot(mIndex).rand(:, 1) = t;
[~, chMeanBlkFreq, ~] = joinSTD(trialsBlkFreq([trialsBlkFreq.correct] == true), ECOGDataset);
[~, chMeanBlkLoc, ~] = joinSTD(trialsBlkLoc([trialsBlkLoc.correct] == true), ECOGDataset);
[~, chMeanRand, ~] = joinSTD(trialsRand([trialsRand.correct] == true), ECOGDataset);
cdrPlot(mIndex).blockFreq(:, 2) = chMeanBlkFreq(icSelect(mIndex), :)';
cdrPlot(mIndex).blockLoc(:, 2) = chMeanBlkLoc(icSelect(mIndex), :)';
cdrPlot(mIndex).rand(:, 2) = chMeanRand(icSelect(mIndex), :)';
FigPTFA(1) = plotTFA(chMeanBlkFreq, fs0, fs, window, strcat("prediction ", PETitle(1)), [1, 1], icSelect(mIndex));
FigPTFA(2) = plotTFA(chMeanBlkLoc, fs0, fs, window, strcat("prediction ", PETitle(2)), [1, 1], icSelect(mIndex));
FigPTFA(3) = plotTFA(chMeanRand, fs0, fs, window, strcat("prediction ", PETitle(3)), [1, 1], icSelect(mIndex));
scaleAxes(FigPTFA, "c", [0, cScale(mIndex)]);
% for tIndex = 1 : length(FigPTFA)
%     print(FigPTFA(tIndex), strcat(FIGPATH, AREANAME, "_",PETitle(tIndex) ,"_Prediction_example_", DateStr), "-djpeg", "-r200");
% end

close all;

end






