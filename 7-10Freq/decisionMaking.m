function [FigDM1, FigDM2] = decisionMaking(trialAll, ECOGDataset)
    [dRatioAll, dRatio] = computeDevRatio(trialAll);

    window = [-2000, 2000];
    resultC = [];
    resultW = [];
    
    for dIndex = 2:length(dRatio)
        trials = trialAll(dRatioAll == dRatio(dIndex));
        [result, ~, ~] = selectEcog(ECOGDataset, trials, "dev onset", window);
        result = changeCellRowNum(cellfun(@zscore, changeCellRowNum(result), "UniformOutput", false));
        resultC = [resultC; result([trials.correct] == true)];
        resultW = [resultW; result([trials.correct] == false & [trials.interrupt] == false)];
    end
    
    chMeanC = cell2mat(cellfun(@mean, changeCellRowNum(resultC), "UniformOutput", false));
    chMeanW = cell2mat(cellfun(@mean, changeCellRowNum(resultW), "UniformOutput", false));
    chData(1).chMean = chMeanC;
    chData(1).color = "r";
    chData(2).chMean = chMeanW;
    chData(2).color = "b";
    FigDM1 = plotRawWaveMulti(chData, window, ['C', num2str(length(resultC)), 'W', num2str(length(resultW))]);
    drawnow;
    FigDM2 = plotTFACompare(chMeanC, chMeanW, ECOGDataset.fs, [], window, ['C', num2str(length(resultC)), 'W', num2str(length(resultW))]);
    drawnow;
    
    % Scale
    scaleAxes([FigDM1, FigDM2], "x", [-200, 800]);
    scaleAxes(FigDM1, "y");
    scaleAxes(FigDM2, "c", [], [-1, 1], "max");

    return;
end