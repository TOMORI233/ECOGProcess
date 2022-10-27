clc; clear; close all
rootPathMat = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\Basic_ICIThr\';
areaSelect = "AC";
[trialsECOG_ACMerge, trialsECOG_PFCMerge, trialAll_merge] = mergeECOGPreprocess(rootPathMat, areaSelect);
