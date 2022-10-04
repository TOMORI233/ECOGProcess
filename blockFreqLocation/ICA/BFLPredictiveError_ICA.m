function [PEBlkWaveFig, PERandWaveFig, PEDiffWaveFig] = BFLPredictiveError_ICA(trialAll, ECOGDatasetTemp, comp)

run("trialSelect.m");
ECOGDataset = ECOGDatasetTemp;

%% Prediction error
window = [-2000, 2000]; % ms
colors = ["k", "b", "#FFA500", "r"];
for dIndex = 2 : length(dRatio)
    trialsBlkFreqC = trialsBlkFreq([trialsBlkFreq.devType]' == dIndex &  [trialsBlkFreq.correct]' == true);
    trialsBlkLocC = trialsBlkLoc([trialsBlkLoc.devType]' == dIndex &  [trialsBlkLoc.correct]' == true);
    trialsRandFreqC = trialsRandFreq([trialsRandFreq.devType]' == dIndex &  [trialsRandFreq.correct]' == true);
    trialsRandLocC = trialsRandLoc([trialsRandLoc.devType]' == dIndex &  [trialsRandLoc.correct]' == true);

    ECOGDataset.data = comp.trialsBlkFreq.unmixing * ECOGDatasetTemp.data;
    [~, chMeanBlkFreqC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsBlkFreqC, "dev onset", window);
    chMeanBlkFreqC(dIndex - 1).color = colors(dIndex - 1);

    ECOGDataset.data = comp.trialsRandFreq.unmixing * ECOGDatasetTemp.data;
    [~, chMeanRandFreqC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsRandFreqC, "dev onset", window);
    chMeanRandFreqC(dIndex - 1).color = colors(dIndex - 1);

    ECOGDataset.data = comp.trialsBlkLoc.unmixing * ECOGDatasetTemp.data;
    [~, chMeanBlkLocC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsBlkLocC, "dev onset", window);
    chMeanBlkLocC(dIndex - 1).color = colors(dIndex - 1);

    ECOGDataset.data = comp.trialsRandLoc.unmixing * ECOGDatasetTemp.data;
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