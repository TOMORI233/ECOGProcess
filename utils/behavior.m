%% Data loading
clear; clc; close all;
BLOCKPATH = 'G:\ECoG\chouchou\cc20220525\Block-1';

temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs'});
epocs = temp.epocs;

choiceWin = [0, 800]; % ms

trialAll = ActiveProcess_7_10Freq(epocs, choiceWin);
plotBehaviorOnly(trialAll, "r", "7-10 Freq");