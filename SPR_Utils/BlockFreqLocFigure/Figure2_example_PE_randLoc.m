clc; clear; 

% MATPATH = 'E:\ECoG\MAT Data\cc\BlkFreqLoc Active\cc20220903\cc20220903_PFC.mat';
MATPATH = {'E:\ECoG\MAT Data\XX\BlkFreqLoc Active\xx20220905\xx20220905_AC.mat'...
           'E:\ECoG\MAT Data\XX\BlkFreqLoc Active\xx20220905\xx20220905_PFC.mat'...
           'E:\ECoG\MAT Data\CC\BlkFreqLoc Active\cc20220903\cc20220903_AC.mat'...
           'E:\ECoG\MAT Data\CC\BlkFreqLoc Active\cc20220903\cc20220903_PFC.mat'...
           };
pos = [1, 2, 1 ,2];
icSelect = [2, 12, 1, 1];
sigVal = [2, 2, 6, 6];
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

    FigTopo = plotTopoICA(comp, [8, 8], [1, 1], icSelect(mIndex));
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
cdrPlot(mIndex).BlkFreqCdr = zeros(length(t), 2 * length(dRatio));
cdrPlot(mIndex).RandFreqCdr = zeros(length(t), 2 * length(dRatio));  
cdrPlot(mIndex).BlkLocCdr =  zeros(length(t), 2 * length(dRatio));
cdrPlot(mIndex).RandLocCdr = zeros(length(t), 2 * length(dRatio));

resultBlkFreqC = [];
resultBlkLocC = [];
resultRandFreqC = [];
resultRandLocC = [];
labelBlkFreqC = [];
labelBlkLocC = [];
labelRandFreqC = [];
labelRandLocC = [];
for dIndex = 2 : length(dRatio)
    trialsBlkFreqC = trialsBlkFreq([trialsBlkFreq.devType]' == dIndex &  [trialsBlkFreq.correct]' == true);
    trialsBlkLocC = trialsBlkLoc([trialsBlkLoc.devType]' == dIndex &  [trialsBlkLoc.correct]' == true);
    trialsRandFreqC = trialsRandFreq([trialsRandFreq.devType]' == dIndex &  [trialsRandFreq.correct]' == true);
    trialsRandLocC = trialsRandLoc([trialsRandLoc.devType]' == dIndex &  [trialsRandLoc.correct]' == true);
    % block freq
    [tempC, chMeanBlkFreqC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsBlkFreqC, "dev onset", window);
    resultBlkFreqC = [resultBlkFreqC; tempC];
    labelBlkFreqC = [labelBlkFreqC; ones(length(tempC), 1) * dIndex];
    cdrPlot(mIndex).BlkFreqCdr(:, 2 * dIndex - 1) = t;
    cdrPlot(mIndex).BlkFreqCdr(:, 2 * dIndex) = chMeanBlkFreqC(dIndex - 1).chMean(icSelect(mIndex), :)';
    % rand freq
    [tempC, chMeanRandFreqC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsRandFreqC, "dev onset", window);
    resultRandFreqC = [resultRandFreqC; tempC];
    labelRandFreqC = [labelRandFreqC; ones(length(tempC), 1) * dIndex];
     cdrPlot(mIndex).RandFreqCdr(:, 2 * dIndex - 1) = t;
    cdrPlot(mIndex).RandFreqCdr(:, 2 * dIndex) = chMeanRandFreqC(dIndex - 1).chMean(icSelect(mIndex), :)';
    % block loc
    [tempC, chMeanBlkLocC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsBlkLocC, "dev onset", window);
    resultBlkLocC = [resultBlkLocC; tempC];
    labelBlkLocC = [labelBlkLocC; ones(length(tempC), 1) * dIndex];
    cdrPlot(mIndex).BlkLocCdr(:, 2 * dIndex - 1) = t;
    cdrPlot(mIndex).BlkLocCdr(:, 2 * dIndex) = chMeanBlkLocC(dIndex - 1).chMean(icSelect(mIndex), :)';
    % rand loc
    [tempC, chMeanRandLocC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsRandLocC, "dev onset", window);
    resultRandLocC = [resultRandLocC; tempC];
    labelRandLocC = [labelRandLocC; ones(length(tempC), 1) * dIndex];
    cdrPlot(mIndex).RandLocCdr(:, 2 * dIndex - 1) = t;
    cdrPlot(mIndex).RandLocCdr(:, 2 * dIndex) = chMeanRandLocC(dIndex - 1).chMean(icSelect(mIndex), :)';

end
temp = changeCellRowNum(resultBlkFreqC);
selectRawICBlkFreq = cell2mat(temp(icSelect(mIndex)));
[P, H] = mAnova1(selectRawICBlkFreq, labelBlkFreqC, 0.05, sigVal(mIndex));
anovaRes(mIndex).BlkFreq(:, 1) = t;
anovaRes(mIndex).BlkFreq(:, 2) = H;
anovaRes(mIndex).BlkFreq(:, 3) = P;

temp = changeCellRowNum(resultRandFreqC);
selectRawICRandFreq = cell2mat(temp(icSelect(mIndex)));
[P, H] = mAnova1(selectRawICRandFreq, labelRandFreqC, 0.05, sigVal(mIndex));
anovaRes(mIndex).RandFreq(:, 1) = t;
anovaRes(mIndex).RandFreq(:, 2) = H;
anovaRes(mIndex).RandFreq(:, 3) = P;

temp = changeCellRowNum(resultBlkLocC);
selectRawICBlkLoc = cell2mat(temp(icSelect(mIndex)));
[P, H] = mAnova1(selectRawICBlkLoc, labelBlkLocC, 0.05, sigVal(mIndex));
anovaRes(mIndex).BlkLoc(:, 1) = t;
anovaRes(mIndex).BlkLoc(:, 2) = H;
anovaRes(mIndex).BlkLoc(:, 3) = P;

temp = changeCellRowNum(resultRandLocC);
selectRawICRandLoc = cell2mat(temp(icSelect(mIndex)));
[P, H] = mAnova1(selectRawICRandLoc, labelRandLocC, 0.05, sigVal(mIndex));
anovaRes(mIndex).RandLoc(:, 1) = t;
anovaRes(mIndex).RandLoc(:, 2) = H;
anovaRes(mIndex).RandLoc(:, 3) = P;



end







