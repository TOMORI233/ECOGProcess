clc; clear; 

% MATPATH = 'E:\ECoG\MAT Data\cc\BlkFreqLoc Active\cc20220903\cc20220903_PFC.mat';
MATPATH = {'E:\ECoG\MAT Data\XX\BlkFreqLoc Active\xx20220905\xx20220905_AC.mat'...
           'E:\ECoG\MAT Data\XX\BlkFreqLoc Active\xx20220905\xx20220905_PFC.mat'...
           'E:\ECoG\MAT Data\CC\BlkFreqLoc Active\cc20220903\cc20220903_AC.mat'...
           'E:\ECoG\MAT Data\CC\BlkFreqLoc Active\cc20220903\cc20220903_PFC.mat'...
           };
pos = [1, 2, 1 ,2];
icSelect = [2, 12, 1, 1];
devSel = {2 : 3, 2 : 3, 2 : 4, 2 : 4};
ROOTPATH = "E:\ECOG\ICAFigures\BlkFreqLoc\";
FIGPATH = "E:\ECoG\corelDraw\PEOddBlkFreqLoc\Figure3\";

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
% 
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

cdrPlot(mIndex).info = strcat(AREANAME, "_", DateStr);
%% decision making
window = [-200,1000];
t = linspace(window(1), window(2), diff(window) /1000 * ECOGDataset.fs + 1)';
trialStr = ["trialsBlkFreq", "trialsRandFreq", "trialsBlkLoc", "trialsRandLoc"];
chMeanDMCW = cell(length(trialStr), 1);
cdrPlot(mIndex).info = strcat(AREANAME, "_", DateStr);
for tIndex = 1 : length(trialStr)
eval(strcat("trialTemp = ", trialStr(tIndex), ";"));  % value trial
resultC = [];
resultW = [];
selectRawICC = [];
selectRawICW = [];
labelC = [];
labelW = [];

for dIndex = devSel{mIndex}
    trials = trialTemp([trialTemp.devType]' == dRatio(dIndex));
    [result, ~, ~] = selectEcog(ECOGDataset, trials, "dev onset", window);
    result = changeCellRowNum(cellfun(@zscore, changeCellRowNum(result), "UniformOutput", false));
    resultC = [resultC; result([trials.correct] == true)];
    resultW = [resultW; result([trials.correct] == false & [trials.interrupt] == false)];
end

% for anova
tempC = changeCellRowNum(resultC);
tempW = changeCellRowNum(resultW);
selectRawICC = [selectRawICC; cell2mat(tempC(icSelect(mIndex)))];
selectRawICW = [selectRawICW; cell2mat(tempW(icSelect(mIndex)))];
labelC = [labelC; ones(length(resultC), 1)];
labelW = [labelW; zeros(length(resultW), 1)];

[P, H] = mAnova1([selectRawICC; selectRawICW], [labelC; labelW], 0.05);
anovaRes(mIndex).(trialStr(tIndex))(:, 1) = t;
anovaRes(mIndex).(trialStr(tIndex))(:, 2) = H;
anovaRes(mIndex).(trialStr(tIndex))(:, 3) = P;

chMeanC = cell2mat(cellfun(@mean, changeCellRowNum(resultC), "UniformOutput", false));
chMeanW = cell2mat(cellfun(@mean, changeCellRowNum(resultW), "UniformOutput", false));

cdrPlot(mIndex).(trialStr(tIndex))(:, [1, 3]) = repmat(t, 1, 2);
cdrPlot(mIndex).(trialStr(tIndex))(:, 2) = chMeanC(icSelect(mIndex), :)';
cdrPlot(mIndex).(trialStr(tIndex))(:, 4) = chMeanW(icSelect(mIndex), :)';
end
end






