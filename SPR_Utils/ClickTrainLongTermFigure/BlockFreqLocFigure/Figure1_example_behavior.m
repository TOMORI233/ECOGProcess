clc; clear; 
mIndex = 1;
MATPATH = {'E:\ECoG\MAT Data\XX\BlkFreqLoc Active\xx20220905\xx20220905_AC.mat'...
           'E:\ECoG\MAT Data\CC\BlkFreqLoc Active\cc20220903\cc20220903_AC.mat'...
           };
pos = [1, 1];
ROOTPATH = "E:\ECOG\ICAFigures\BlkFreqLoc\";
FIGPATH = "E:\ECoG\corelDraw\PEOddBlkFreqLoc\Figure2\";

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
block1Idx = mod([trialAll.trialNum]', 80) >= 1 & mod([trialAll.trialNum]', 80) <= 20;
block2Idx = mod([trialAll.trialNum]', 80) >= 21 & mod([trialAll.trialNum]', 80) <= 40;
block3Idx = mod([trialAll.trialNum]' - 1, 80) >= 40 & mod([trialAll.trialNum]', 80) <= 79;
stdFreq = unique([trialAll([trialAll.oddballType]' == "STD").devFreq]);
stdLoc = unique([trialAll([trialAll.oddballType]' == "STD").devLoc]);
trialsBlkFreq = trialAll([trialAll.devLoc]' == stdLoc & block1Idx);
trialsRandFreq = trialAll([trialAll.devLoc]' == stdLoc & block3Idx);
trialsBlkLoc = trialAll([trialAll.devFreq]' == stdFreq & block2Idx);
trialsRandLoc = trialAll([trialAll.devFreq]' == stdFreq & block3Idx);


[FigBehavior, mAxe, nPush.blkFreq, nTotal.blkFreq] = plotBehaviorOnly(trialsBlkFreq, "r", "block freq");
[FigBehavior, mAxe, nPush.randFreq, nTotal.randFreq] = plotBehaviorOnly(trialsRandFreq, "m", "rand freq", FigBehavior, mAxe, "freq");
[FigBehavior, mAxe, nPush.blkLoc, nTotal.blkLoc] = plotBehaviorOnly(trialsBlkLoc, "b", "block loc", FigBehavior, mAxe, "loc");
[FigBehavior, ~, nPush.randLoc, nTotal.randLoc] = plotBehaviorOnly(trialsRandLoc, "k", "rand loc", FigBehavior, mAxe, "loc");
pushRatio.blkFreq = nPush.blkFreq./ nTotal.blkFreq;
pushRatio.blkLoc = nPush.blkLoc./ nTotal.blkLoc;
pushRatio.randFreq = nPush.randFreq./ nTotal.randFreq;
pushRatio.randLoc = nPush.randLoc./ nTotal.randLoc;
close all;