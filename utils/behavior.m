%% Data loading
clear; clc; close all;
BLOCKPATH = 'G:\ECoG\chouchou\cc20220620\Block-1';

temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs'});
epocs = temp.epocs;

choiceWin = [100, 800]; % ms

%% LTST
trialAll = ActiveProcess_LTST(epocs, choiceWin);
constIdx = logical(mod(ceil([trialAll.trialNum] / 20), 2));
randIdx = ~logical(mod(ceil([trialAll.trialNum] / 20), 2));
trialsConst = trialAll(constIdx);
trialsRand = trialAll(randIdx);
[FigBehavior, mAxe] = plotBehaviorOnly(trialsConst, "r", "Constant");
plotBehaviorOnly(trialsRand, "b", "Random", FigBehavior, mAxe);
drawnow;

%% 1-9
% trialAll = ActiveProcess_1_9Freq(epocs);
% trials1_3 = trialAll([trialAll.stdNum] >= 1 & [trialAll.stdNum] <= 3);
% trials4_6 = trialAll([trialAll.stdNum] >= 4 & [trialAll.stdNum] <= 6);
% trials7_9 = trialAll([trialAll.stdNum] >= 7 & [trialAll.stdNum] <= 9);
% [Fig, mAxe] = plotBehaviorOnly(trials1_3, "k", "1 2 3");
% [Fig, mAxe] = plotBehaviorOnly(trials4_6, "b", "4 5 6", Fig, mAxe);
% [Fig, mAxe] = plotBehaviorOnly(trials7_9, "r", "7 8 9", Fig, mAxe);

%% 7-10
trialAll = ActiveProcess_7_10Freq(epocs, choiceWin);
plotBehaviorOnly(trialAll, "r", "7-10 Freq");