function [FigPWave, FigPTFA, FigPDiffWave, FigPDiffTFA] = BFLPrediction_ICA(trialAll, ECOGDatasetTemp, comp)

run("trialSelect.m");
ECOGDataset = ECOGDatasetTemp;

window = [-2500, 6000]; % ms
PETitle = ["block freq", "block loc", "rand"];

% prediction raw
ECOGDataset.data = comp.trialsBlkFreqP.unmixing * ECOGDatasetTemp.data;
[~, chMeanP(1).chMean, ~] = joinSTD(trialsBlkFreqP([trialsBlkFreqP.correct] == true), ECOGDataset);
ECOGDataset.data = comp.trialsBlkLocP.unmixing * ECOGDatasetTemp.data;
[~, chMeanP(2).chMean, ~] = joinSTD(trialsBlkLocP([trialsBlkLocP.correct] == true), ECOGDataset);
ECOGDataset.data = comp.trialsRandP.unmixing * ECOGDatasetTemp.data;
[~, chMeanP(3).chMean, ~] = joinSTD(trialsRandP([trialsRandP.correct] == true), ECOGDataset);
chMeanP(1).color = "r"; chMeanP(2).color = "b"; chMeanP(3).color = "k"; 
trialN = [sum([trialsBlkFreqP.correct] == true), sum([trialsBlkLocP.correct] == true), sum([trialsRandP.correct] == true)];
FigPWave = plotRawWaveMulti(chMeanP, window, strcat("prediction, Nbf=", num2str(trialN(1)), ",Nbl=", num2str(trialN(2)), ",Nr=", num2str(trialN(3))));
drawnow;


% prediction diff
chMeanPDiff(1).chMean = chMeanP(1).chMean - chMeanP(2).chMean; % block freq - loc
chMeanPDiff(2).chMean = chMeanP(1).chMean - chMeanP(3).chMean; % block freq - rand
chMeanPDiff(3).chMean = chMeanP(2).chMean - chMeanP(3).chMean; % block loc - rand
chMeanPDiff(1).color = "r"; chMeanPDiff(2).color = "#FFA500"; chMeanPDiff(3).color = "b"; 
drawnow;


fs = 500;
fs0 = ECOGDataset.fs;
firstIdx = [1, 1, 2];
secondIdx = [2, 3, 3];
diffTitle = [" blk freq-blk loc ", " block freq-rand ", " block loc-rand "];
for bIndex = 1 : 3
FigPTFA(bIndex) = plotTFA(chMeanP(bIndex).chMean, fs0, fs, window, strcat("prediction ", PETitle(bIndex), " num=", num2str(trialN(bIndex))));
drawnow;
FigPDiffWave(bIndex) = plotRawWave(chMeanPDiff(bIndex).chMean, [], window, strcat("prediction diff,", diffTitle(bIndex)));
FigPDiffTFA(bIndex) = plotTFACompare(chMeanP(firstIdx(bIndex)).chMean, chMeanP(secondIdx(bIndex)).chMean, fs0, fs, window, strcat("prediction diff", diffTitle(bIndex)));
drawnow;
end