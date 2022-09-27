function [PEBlkWaveFig, PERandWaveFig, PEDiffWaveFig] = BFLPredictiveError(trialAll, ECOGDataset)

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
window = [-2000, 2000]; % ms
colors = ["k", "b", "#FFA500", "r"];
for dIndex = 2 : length(dRatio)
    trialsBlkFreqC = trialsBlkFreq([trialsBlkFreq.devType]' == dIndex &  [trialsBlkFreq.correct]' == true);
    trialsBlkLocC = trialsBlkLoc([trialsBlkLoc.devType]' == dIndex &  [trialsBlkLoc.correct]' == true);
    trialsRandFreqC = trialsRandFreq([trialsRandFreq.devType]' == dIndex &  [trialsRandFreq.correct]' == true);
    trialsRandLocC = trialsRandLoc([trialsRandLoc.devType]' == dIndex &  [trialsRandLoc.correct]' == true);
    [~, chMeanBlkFreqC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsBlkFreqC, "dev onset", window);
    chMeanBlkFreqC(dIndex - 1).color = colors(dIndex - 1);
    [~, chMeanRandFreqC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsRandFreqC, "dev onset", window);
    chMeanRandFreqC(dIndex - 1).color = colors(dIndex - 1);
    [~, chMeanBlkLocC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsBlkLocC, "dev onset", window);
    chMeanBlkLocC(dIndex - 1).color = colors(dIndex - 1);
    [~, chMeanRandLocC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsRandLocC, "dev onset", window);
    chMeanRandLocC(dIndex - 1).color = colors(dIndex - 1);

    % compare of different blocks
    temp(4).color = "r"; temp(3).color = "#FFA500"; temp(2).color = "b"; temp(1).color = "#AAAAFF";
    temp(4).chMean = chMeanBlkFreqC(dIndex - 1).chMean;
    temp(3).chMean = chMeanRandFreqC(dIndex - 1).chMean;
    temp(2).chMean = chMeanBlkLocC(dIndex - 1).chMean;
    temp(1).chMean = chMeanRandLocC(dIndex - 1).chMean;
    PEDiffWaveFig(dIndex - 1) = plotRawWaveMulti(temp, window, strcat("PE: Diff Level ", num2str(dIndex))); drawnow;
end
% plot raw wave
PEBlkWaveFig(1) = plotRawWaveMulti(chMeanBlkFreqC, window, "PE: blkFreq"); drawnow;
PEBlkWaveFig(2) = plotRawWaveMulti(chMeanBlkLocC, window, "PE: blkLoc"); drawnow;
PERandWaveFig(1) = plotRawWaveMulti(chMeanRandFreqC, window, "PE: randFreq"); drawnow;
PERandWaveFig(2) = plotRawWaveMulti(chMeanRandLocC, window, "PE: randLoc"); drawnow;




end