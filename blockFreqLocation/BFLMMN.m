function [MMNBlkWaveFig, MMNRandWaveFig, MMNDiffWaveFig] = BFLMMN(trialAll, ECOGDataset)

%% trial selection
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


window = [-2000, 2000];
colors = ["k", "b", "#FFA500", "r"];
for dIndex = 2 : length(dRatio)

% block freq
trialsBlkFreqC = trialsBlkFreq([trialsBlkFreq.devType]' == dIndex &  [trialsBlkFreq.correct]' == true);
trialsBlkFreqW = trialsBlkFreq([trialsBlkFreq.devType]' == dIndex &  [trialsBlkFreq.correct]' == false);
[resultBlkFreqDEVC, ~, ~] = selectEcog(ECOGDataset, trialsBlkFreqC, "dev onset", window);
[resultBlkFreqSTDC, ~, ~] = selectEcog(ECOGDataset, trialsBlkFreqC, "last std", window);
[resultBlkFreqDEVW, ~, ~] = selectEcog(ECOGDataset, trialsBlkFreqW, "dev onset", window);
[resultBlkFreqSTDW, ~, ~] = selectEcog(ECOGDataset, trialsBlkFreqW, "last std", window);
chMeanBlkFreqC(dIndex - 1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultBlkFreqDEVC - resultBlkFreqSTDC), "UniformOutput", false));
chMeanBlkFreqW(dIndex - 1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultBlkFreqDEVW - resultBlkFreqSTDW), "UniformOutput", false));
chMeanBlkFreqC(dIndex - 1).color = colors(dIndex - 1);
chMeanBlkFreqW(dIndex - 1).color = colors(dIndex - 1);

% rand freq
trialsRandFreqC = trialsRandFreq([trialsRandFreq.devType]' == dIndex &  [trialsRandFreq.correct]' == true);
trialsRandFreqW = trialsRandFreq([trialsRandFreq.devType]' == dIndex &  [trialsRandFreq.correct]' == false);
[resultRandFreqDEVC, ~, ~] = selectEcog(ECOGDataset, trialsRandFreqC, "dev onset", window);
[resultRandFreqSTDC, ~, ~] = selectEcog(ECOGDataset, trialsRandFreqC, "last std", window);
[resultRandFreqDEVW, ~, ~] = selectEcog(ECOGDataset, trialsRandFreqW, "dev onset", window);
[resultRandFreqSTDW, ~, ~] = selectEcog(ECOGDataset, trialsRandFreqW, "last std", window);
chMeanRandFreqC(dIndex - 1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultRandFreqDEVC - resultRandFreqSTDC), "UniformOutput", false));
chMeanRandFreqW(dIndex - 1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultRandFreqDEVW - resultRandFreqSTDW), "UniformOutput", false));
chMeanRandFreqC(dIndex - 1).color = colors(dIndex - 1);
chMeanRandFreqW(dIndex - 1).color = colors(dIndex - 1);

% block Loc
trialsBlkLocC = trialsBlkLoc([trialsBlkLoc.devType]' == dIndex &  [trialsBlkLoc.correct]' == true);
trialsBlkLocW = trialsBlkLoc([trialsBlkLoc.devType]' == dIndex &  [trialsBlkLoc.correct]' == false);
[resultBlkLocDEVC, ~, ~] = selectEcog(ECOGDataset, trialsBlkLocC, "dev onset", window);
[resultBlkLocSTDC, ~, ~] = selectEcog(ECOGDataset, trialsBlkLocC, "last std", window);
[resultBlkLocDEVW, ~, ~] = selectEcog(ECOGDataset, trialsBlkLocW, "dev onset", window);
[resultBlkLocSTDW, ~, ~] = selectEcog(ECOGDataset, trialsBlkLocW, "last std", window);
chMeanBlkLocC(dIndex - 1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultBlkLocDEVC - resultBlkLocSTDC), "UniformOutput", false));
chMeanBlkLocW(dIndex - 1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultBlkLocDEVW - resultBlkLocSTDW), "UniformOutput", false));
chMeanBlkLocC(dIndex - 1).color = colors(dIndex - 1);
chMeanBlkLocW(dIndex - 1).color = colors(dIndex - 1);

% rand Loc
trialsRandLocC = trialsRandLoc([trialsRandLoc.devType]' == dIndex &  [trialsRandLoc.correct]' == true);
trialsRandLocW = trialsRandLoc([trialsRandLoc.devType]' == dIndex &  [trialsRandLoc.correct]' == false);
[resultRandLocDEVC, ~, ~] = selectEcog(ECOGDataset, trialsRandLocC, "dev onset", window);
[resultRandLocSTDC, ~, ~] = selectEcog(ECOGDataset, trialsRandLocC, "last std", window);
[resultRandLocDEVW, ~, ~] = selectEcog(ECOGDataset, trialsRandLocW, "dev onset", window);
[resultRandLocSTDW, ~, ~] = selectEcog(ECOGDataset, trialsRandLocW, "last std", window);
chMeanRandLocC(dIndex - 1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultRandLocDEVC - resultRandLocSTDC), "UniformOutput", false));
chMeanRandLocW(dIndex - 1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultRandLocDEVW - resultRandLocSTDW), "UniformOutput", false));
chMeanRandLocC(dIndex - 1).color = colors(dIndex - 1);
chMeanRandLocW(dIndex - 1).color = colors(dIndex - 1);


    % compare of different blocks
    temp(4).color = "r"; temp(3).color = "#FFA500"; temp(2).color = "b"; temp(1).color = "#AAAAFF";
    temp(4).chMean = chMeanBlkFreqC(dIndex - 1).chMean;
    temp(3).chMean = chMeanRandFreqC(dIndex - 1).chMean;
    temp(2).chMean = chMeanBlkLocC(dIndex - 1).chMean;
    temp(1).chMean = chMeanRandLocC(dIndex - 1).chMean;
    MMNDiffWaveFig(dIndex - 1) = plotRawWaveMulti(temp, window, strcat("MMN: Diff Level ", num2str(dIndex))); drawnow;
end

% plot raw wave
MMNBlkWaveFig(1) = plotRawWaveMulti(chMeanBlkFreqC, window, "blkFreq C:DEV-last STD");
MMNBlkWaveFig(2) = plotRawWaveMulti(chMeanBlkLocC, window, "blkLoc C:DEV-last STD");
MMNRandWaveFig(1) = plotRawWaveMulti(chMeanRandFreqC, window, "randFreq C:DEV-last STD");
MMNRandWaveFig(2) = plotRawWaveMulti(chMeanRandLocC, window, "randLoc C:DEV-last STD");
