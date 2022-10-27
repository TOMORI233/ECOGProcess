function [FigWave_Push, FigTFA_Push] = push(trialAll, ECOGDataset)
    [dRatioAll, dRatio] = computeDevRatio(trialAll);
    dRatio(dRatio == 1) = [];

    window = [-2000, 2000]; % ms
    colors = cellfun(@(x) x / 255, {[0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

    for dIndex = 1:length(dRatio)
        trials = trialAll([trialAll.correct] == true & dRatioAll == dRatio(dIndex));
        [~, chData(dIndex).chMean, chData(dIndex).chStd] = selectEcog(ECOGDataset, trials, "push onset", window);
        chData(dIndex).color = colors{dIndex};
        FigTFA_Push(dIndex) = plotTFA(chData(dIndex).chMean, ECOGDataset.fs, [], window, ['dRatio=', num2str(dRatio(dIndex))]);
    end

    FigWave_Push = plotRawWaveMulti(chData, window, 'Push');
    scaleAxes([FigWave_Push, FigTFA_Push], "x", [-500, 500]);
    
    return;
end