function [PushBlkWaveFig, PushRandWaveFig, PushDiffWaveFig] = BFLPush_ICA(trialAll, ECOGDatasetTemp, comp)

run("trialSelect.m");
ECOGDataset = ECOGDatasetTemp;
dRatio = unique(devType(([trialAll.devType]' > 0)));

%% Prediction error
window = [-2000, 2000]; % ms
colors = ["k", "b", "#FFA500", "r"];
for dIndex = 2:length(dRatio)
    trialsBlkFreqC = trialsBlkFreq([trialsBlkFreq.devType]' == dIndex &  [trialsBlkFreq.correct]' == true);
    trialsBlkLocC = trialsBlkLoc([trialsBlkLoc.devType]' == dIndex &  [trialsBlkLoc.correct]' == true);
    trialsRandFreqC = trialsRandFreq([trialsRandFreq.devType]' == dIndex &  [trialsRandFreq.correct]' == true);
    trialsRandLocC = trialsRandLoc([trialsRandLoc.devType]' == dIndex &  [trialsRandLoc.correct]' == true);

    ECOGDataset.data = comp.trialsBlkFreq.unmixing * ECOGDatasetTemp.data;
    [~, chMeanBlkFreqC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsBlkFreqC, "push onset", window);
    chMeanBlkFreqC(dIndex - 1).color = colors(dIndex - 1);

    ECOGDataset.data = comp.trialsRandFreq.unmixing * ECOGDatasetTemp.data;
    [~, chMeanRandFreqC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsRandFreqC, "push onset", window);
    chMeanRandFreqC(dIndex - 1).color = colors(dIndex - 1);

    ECOGDataset.data = comp.trialsBlkLoc.unmixing * ECOGDatasetTemp.data;
    [~, chMeanBlkLocC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsBlkLocC, "push onset", window);
    chMeanBlkLocC(dIndex - 1).color = colors(dIndex - 1);

    ECOGDataset.data = comp.trialsRandLoc.unmixing * ECOGDatasetTemp.data;
    [~, chMeanRandLocC(dIndex - 1).chMean] = selectEcog(ECOGDataset, trialsRandLocC, "push onset", window);
    chMeanRandLocC(dIndex - 1).color = colors(dIndex - 1);

    temp(4).color = "r"; temp(3).color = "#FFA500"; temp(2).color = "b"; temp(1).color = "#AAAAFF";
    temp(4).chMean = chMeanBlkFreqC(dIndex - 1).chMean;
    temp(3).chMean = chMeanRandFreqC(dIndex - 1).chMean;
    temp(2).chMean = chMeanBlkLocC(dIndex - 1).chMean;
    temp(1).chMean = chMeanRandLocC(dIndex - 1).chMean;
    PushDiffWaveFig(dIndex - 1) = plotRawWaveMulti(temp, window, strcat("Push: Diff Level ", num2str(dIndex))); drawnow;

end
% plot raw wave
PushBlkWaveFig(1) = plotRawWaveMulti(chMeanBlkFreqC, window, "Push: blkFreq"); drawnow;
PushBlkWaveFig(2) = plotRawWaveMulti(chMeanBlkLocC, window, "Push: blkLoc"); drawnow;
PushRandWaveFig(1) = plotRawWaveMulti(chMeanRandFreqC, window, "Push: randFreq"); drawnow;
PushRandWaveFig(2) = plotRawWaveMulti(chMeanRandLocC, window, "Push: randLoc"); drawnow;
end