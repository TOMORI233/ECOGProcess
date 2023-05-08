%% Data loading
clear; clc; close all;
% BLOCKPATH = 'E:\ECoG\xiaoxiao\xx20220907\Block-1';
% BLOCKPATH = 'E:\ECoG\chouchou\cc20220825\Block-3';
BLOCKPATH = 'F:\Monkey LA\TDT Data\CM\cm20230323\Block-9';
temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs'});
epocs = temp.epocs;

choiceWin = [100, 600]; % ms

% % %% LTST
% trialAll = ActiveProcess_LTST(epocs, choiceWin);
% constIdx = logical(mod(ceil([trialAll.trialNum] / 20), 2));
% randIdx = ~logical(mod(ceil([trialAll.trialNum] / 20), 2));
% trialsConst = trialAll(constIdx);
% trialsRand = trialAll(randIdx);
% [FigBehavior, mAxe] = plotBehaviorOnly(trialsConst, "r", "Constant");
% plotBehaviorOnly(trialsRand, "b", "Random", FigBehavior, mAxe);
% drawnow;

% % % 1-9 / working memory
% trialAll = ActiveProcess_1_9Freq(epocs);
% trials1_3 = trialAll([trialAll.stdNum] >= 1 & [trialAll.stdNum] <= 3);
% trials4_6 = trialAll([trialAll.stdNum] >= 4 & [trialAll.stdNum] <= 6);
% trials7_9 = trialAll([trialAll.stdNum] >= 7 & [trialAll.stdNum] <= 9);
% [Fig, mAxe] = plotBehaviorOnly(trials1_3, "k", "1 2 3");
% [Fig, mAxe] = plotBehaviorOnly(trials4_6, "b", "4 5 6", Fig, mAxe);
% [Fig, mAxe] = plotBehaviorOnly(trials7_9, "r", "7 8 9", Fig, mAxe);

% % % %% 7-10 

trialAll = ActiveProcess_7_10Freq(epocs, choiceWin);
plotBehaviorOnly(trialAll, "r", "xlabelStr", "7-10 Freq");


% %freqLoc
% 
% trialAll = ActiveProcess_freqLoc(epocs, choiceWin);
% block1Idx = mod([trialAll.trialNum]', 80) >= 1 & mod([trialAll.trialNum]', 80) <= 20;
% block2Idx = mod([trialAll.trialNum]', 80) >= 21 & mod([trialAll.trialNum]', 80) <= 40;
% block3Idx = mod([trialAll.trialNum]' - 1, 80) >= 40 & mod([trialAll.trialNum]', 80) <= 79;
% 
% stdFreq = unique([trialAll([trialAll.oddballType]' == "STD").devFreq]);
% stdLoc = unique([trialAll([trialAll.oddballType]' == "STD").devLoc]);
% trialsBlkFreq = trialAll([trialAll.devLoc]' == stdLoc & block1Idx);
% trialsRandFreq = trialAll([trialAll.devLoc]' == stdLoc & block3Idx);
% trialsBlkLoc = trialAll([trialAll.devFreq]' == stdFreq & block2Idx);
% trialsRandLoc = trialAll([trialAll.devFreq]' == stdFreq & block3Idx);
% [Fig, mAxe] = plotBehaviorOnly(trialsBlkFreq, "r", "block freq");
% [Fig, mAxe] = plotBehaviorOnly(trialsRandFreq, "m", "rand freq", Fig, mAxe, "freq");
% [Fig, mAxe] = plotBehaviorOnly(trialsBlkLoc, "b", "block loc", Fig, mAxe, "loc");
% [Fig, mAxe] = plotBehaviorOnly(trialsRandLoc, "k", "rand loc", Fig, mAxe, "loc");

% % click train compare
% pairStr = {'4-4.06RC','4-4.06RD','4-4.06IC','4-4.06ID','FuzaTone-C','FuzaTone-D'};
% trialAll = ActiveProcess_clickTrainWM(epocs, choiceWin);
% trialAll = trialAll(2:end);
% trialsNoInterrupt = trialAll([trialAll.interrupt] == false);
% trials = deleteWrongTrial(trialsNoInterrupt, "ClickTrainOddCompare");
% 
% [Fig, mAxe] = plotClickTrainWMBehaviorOnly(trials, "k", {'control', 'dev'},pairStr);

% 
% % click train compare tone
% pairStr = {'4-4.16RC','4-4.16RD','4-5RC','4-5RD','4-4.16IC','4-4.16ID','4-5IC','4-5ID','250-250Hz','250-240Hz','250-250Hz','250-200Hz'};
% pairStr = {'4-4.08RC','4-4.08RD','4-4.08IC','4-4.08ID','250-250Hz','250-240Hz','250-250Hz','250-500Hz'};
% 
% trialAll = ActiveProcess_clickTrainWM(epocs, choiceWin);
% trialAll = trialAll(2:end);
% trialsNoInterrupt = trialAll([trialAll.interrupt] == false);
% trials = deleteWrongTrial(trialsNoInterrupt, "ClickTrainOddCompareTone");
% 
% [Fig, mAxe] = plotClickTrainWMBehaviorOnly(trials, "k", {'control', 'dev'},pairStr);

% % % click train ICI Thr
% trialAll = ActiveProcess_clickTrain1_9(epocs, choiceWin);
% trialAll = trialAll(2:end);
% [FigBehavior, mAxe] = plotBehaviorOnly(trialAll, "k", "7-10");

% trials = deleteWrongTrial(trialsNoInterrupt, 'clickTrainCompare');
% 
% [Fig, mAxe] = plotClickTrainWMBehaviorOnly(trials, "k", {'control', 'dev'},pairStr);

% 
% click train compare tone
% pairStr = {'4-4.16RC','4-4.16RD','4-5RC','4-5RD','4-4.16IC','4-4.16ID','4-5IC','4-5ID','250-250Hz','250-240Hz','250-250Hz','250-200Hz'};
% pairStr = {'4-4.08RC','4-4.08RD','4-4.08IC','4-4.08ID','250-250Hz','250-240Hz','250-250Hz','250-500Hz'};
% 
% trialAll = ActiveProcess_clickTrainWM(epocs, choiceWin);
% trialAll = trialAll(2:end);
% trialsNoInterrupt = trialAll([trialAll.interrupt] == false);
% trials = deleteWrongTrial(trialsNoInterrupt, "ClickTrainOddCompareTone");
% 
% [Fig, mAxe] = plotClickTrainWMBehaviorOnly(trials, "k", {'control', 'dev'},pairStr);

% % % click train ICI Thr
% trialAll = ActiveProcess_clickTrain1_9(epocs, choiceWin);
% trialAll = trialAll(2:end);
% [FigBehavior, mAxe] = plotBehaviorOnly(trialAll, "k", "7-10");


