% load .mat first
FDZData = filterRes(1).FDZData;
window = filterRes(1).t([1 end]);
testWin = [-4000 0];
[res, chIdx] = excludeTrialsChs(FDZData, 0.1, window, testWin);