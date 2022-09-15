clc; clear;
BLOCKPATH = 'D:\ECoG\xiaoxiao\xx20220820\Block-1';
temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs'});
epocs = temp.epocs;
temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'streams'}, 'STORE', {'LAuC'});
ECOGDataset = temp.streams.LAuC;
choiceWin = [100, 600]; % ms
trialAll = ActiveProcess_1_9Freq(epocs);
fs0 = ECOGDataset.fs;
fs = 300;

window = [-1000, 2000];
[~, chMean] = selectEcog(ECOGDataset, trialAll, "trial onset", window);
Fig = plotRawWave(chMean, [], window);
scaleAxes(Fig, "y", [], [-50, 50], "min");
Fig2 = plotTFA(chMean, fs0, fs, window);
scaleAxes(Fig2, "c", [0, 20]);