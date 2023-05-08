function [FigDMCW, FigDMBlk, FigDMRand, FigDMDiff] = BFLDecisionMaking_ICA(trialAll, ECOGDatasetTemp, comp)

run("trialSelect.m");
ECOGDataset = ECOGDatasetTemp;
window = [-2000, 2000];
colors = ["r", "b", "#FFC0CB", "#4682B4"];
trialStr = ["trialsBlkFreq", "trialsRandFreq", "trialsBlkLoc", "trialsRandLoc"];
chMeanDMCW = cell(length(trialStr), 1);
for tIndex = 1 : length(trialStr)
eval(strcat("trialTemp = ", trialStr(tIndex), ";"));  % value trial
resultC = [];
resultW = [];

for dIndex = 2 : length(dRatio)
    trials = trialTemp([trialTemp.devType]' == dRatio(dIndex));
    ECOGDataset.data = comp.(trialStr(tIndex)).unmixing * ECOGDatasetTemp.data;
    [result, ~, ~] = selectEcog(ECOGDataset, trials, "dev onset", window);
    result = changeCellRowNum(cellfun(@zscore, changeCellRowNum(result), "UniformOutput", false));
    resultC = [resultC; result([trials.correct] == true)];
    resultW = [resultW; result([trials.correct] == false & [trials.interrupt] == false)];
end

chMeanC = cell2mat(cellfun(@mean, changeCellRowNum(resultC), "UniformOutput", false));
chMeanW = cell2mat(cellfun(@mean, changeCellRowNum(resultW), "UniformOutput", false));
chMeanDM(tIndex).chMean = chMeanC - chMeanW;
chMeanDM(tIndex).color = colors(tIndex);

chMeanDMCW{tIndex, 1}(1).chMean = chMeanC; chMeanDMCW{tIndex, 1}(1).color = "r";
chMeanDMCW{tIndex, 1}(2).chMean = chMeanW; chMeanDMCW{tIndex, 1}(2).color = "k";
FigDMCW(tIndex) = plotRawWaveMulti(chMeanDMCW{tIndex, 1}, window, strcat(trialStr(tIndex), " decision making C & W"));
drawnow
end

% diff
FigDMDiff = plotRawWaveMulti(chMeanDM, window, "decision making C-W");
drawnow;

% block freq & loc compare
temp(1).chMean = chMeanDMCW{1}(1).chMean; % block freq   
temp(2).chMean = chMeanDMCW{3}(1).chMean; % block loc
temp(1).color = "r"; temp(2).color = "b";
FigDMBlk = plotRawWaveMulti(temp, window, "decision making block freq & loc C");
drawnow;

% rand freq & loc compare
temp(1).chMean = chMeanDMCW{2}(1).chMean; % rand freq   
temp(2).chMean = chMeanDMCW{4}(1).chMean; % rand loc
temp(1).color = "r"; temp(2).color = "b";
FigDMRand = plotRawWaveMulti(temp, window, "decision making rand freq & loc C");
drawnow;
end

