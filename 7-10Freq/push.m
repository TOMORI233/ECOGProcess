function [FigPush1, FigPush2] = push(trialAll, ECOGDataset)
    [dRatioAll, dRatio] = computeDevRatio(trialAll);

    window = [-2000, 2000]; % ms

    for dIndex = 2:length(dRatio)
        trials = trialAll([trialAll.correct] == true & dRatioAll == dRatio(dIndex));
        [~, chMean, chStd] = selectEcog(ECOGDataset, trials, "push onset", window);
        FigPush1(dIndex - 1) = plotRawWave(chMean, chStd, window, ['dRatio=', num2str(dRatio(dIndex)), '(N=', num2str(length(trials)), ')']);
        drawnow;
        FigPush2(dIndex - 1) = plotTFA(chMean, ECOGDataset.fs, [], window, ['dRatio=', num2str(dRatio(dIndex)), '(N=', num2str(length(trials)), ')']);
        drawnow;
    end

    scaleAxes([FigPush1, FigPush2], "x", [-1500, 2000]);
    
    return;
end