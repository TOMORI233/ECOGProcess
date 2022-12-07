function FigP = prediction(trialAll, ECOGDataset)
    [~, chMean, ~, window] = joinSTD(trialAll([trialAll.correct] == true), ECOGDataset);
    FigP(1) = plotRawWave(chMean, [], window);
    drawnow;
    FigP(2) = plotTFA(chMean, ECOGDataset.fs, [], window);
    drawnow;

    return;
end