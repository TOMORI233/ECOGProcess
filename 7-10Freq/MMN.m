function FigMMN = MMN(trialAll, ECOGDataset)
    [dRatioAll, dRatio] = computeDevRatio(trialAll);

    window = [-2000, 2000];
    colors = generateColorGrad(4, "rgb");
    
    for dIndex = 2:length(dRatio)
        trials = trialAll([trialAll.correct] == true & dRatioAll == dRatio(dIndex));
        [resultDEV, ~, ~] = selectEcog(ECOGDataset, trials, "dev onset", window);
        [resultSTD, ~, ~] = selectEcog(ECOGDataset, trials, "last std", window);
        
        chData(dIndex - 1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultDEV - resultSTD), "UniformOutput", false));
        chData(dIndex - 1).color = colors{dIndex - 1};
        chData(dIndex - 1).legend = ['dRatio=', num2str(dRatio(dIndex))];
    end
    
    FigMMN = plotRawWaveMulti(chData, window, 'MMN');
    
    scaleAxes(FigMMN, "x", [0, 500]);
%     scaleAxes(FigMMN, "y", [], [-50, 50], "max");

    return;
end