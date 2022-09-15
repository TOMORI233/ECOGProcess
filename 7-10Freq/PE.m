function [FigPE1, FigPE2] = PE(trialAll, ECOGDataset)
    [dRatioAll, dRatio] = computeDevRatio(trialAll);

    window = [-2000, 2000]; % ms

    for dIndex = 1:length(dRatio)
        trials = trialAll([trialAll.correct] == true & dRatioAll == dRatio(dIndex));
        [~, chMean, chStd] = selectEcog(ECOGDataset, trials, "dev onset", window);
        FigPE1(dIndex) = plotRawWave(chMean, chStd, window, ['dRatio=', num2str(dRatio(dIndex)), '(N=', num2str(length(trials)), ')']);
        drawnow;
        FigPE2(dIndex) = plotTFA(chMean, ECOGDataset.fs, [], window, ['dRatio=', num2str(dRatio(dIndex)), '(N=', num2str(length(trials)), ')']);
        drawnow;
    end

    scaleAxes([FigPE1, FigPE2], "x", [-1500, 2000]);
    
    return;
end