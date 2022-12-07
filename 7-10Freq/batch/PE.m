function [FigWave_PE, FigTFA_PE] = PE(trialAll, ECOGDataset)
    [dRatioAll, dRatio] = computeDevRatio(trialAll);

    window = [-2000, 2000]; % ms
    colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

    for dIndex = 1:length(dRatio)
        trials = trialAll([trialAll.correct] == true & dRatioAll == dRatio(dIndex));
        [~, chData(dIndex).chMean, chData(dIndex).chStd] = selectEcog(ECOGDataset, trials, "dev onset", window);
        chData(dIndex).color = colors{dIndex};
        FigTFA_PE(dIndex) = plotTFA(chData(dIndex).chMean, ECOGDataset.fs, [], window, ['dRatio=', num2str(dRatio(dIndex))]);
    end

    FigWave_PE = plotRawWaveMulti(chData, window, 'PE');
    scaleAxes([FigWave_PE, FigTFA_PE], "x", [0, 800]);
    
    return;
end