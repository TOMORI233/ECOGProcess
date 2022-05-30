function [chMean, chStd] = joinSTD(trialAll, ECOGDataset, window)
    trials = trialAll([trialAll.correct] == true);
    ISI = fix(mean(cellfun(@(x, y) (x(end) - x(1)) / y, {trials.soundOnsetSeq}, {trials.stdNum})));
    stdNumAll = unique([trials.stdNum]);
    fs0 = ECOGDataset.fs;
    resultSTD = cell(length(stdNumAll), 1);
    
    for sIndex = 1:length(stdNumAll)
        trialsSTD = trials([trials.correct] == true & [trials.stdNum] >= stdNumAll(sIndex));
    
        if sIndex == 1
            windowSTD = [window(1), ISI * stdNumAll(sIndex)];
        else
            windowSTD = [ISI * (stdNumAll(sIndex) - 1), ISI * stdNumAll(sIndex)];
        end
    
        ECOG = selectEcog(ECOGDataset, trialsSTD, "trial onset", window);
        weightSTD = zeros(1, size(ECOG{1}, 2));
        weightSTD(floor((windowSTD(1) - window(1)) * fs0 / 1000 + 1):floor((windowSTD(2) - window(1)) * fs0 / 1000)) = 1 / length(ECOG);
        resultSTD{sIndex} = cell2mat(cellfun(@sum, changeCellRowNum(cellfun(@(x) x .* weightSTD, ECOG, "UniformOutput", false)), "UniformOutput", false));
    end
    
    chMean = resultSTD{1};
    
    for index = 2:length(resultSTD)
        chMean = chMean + resultSTD{index};
    end
    
    chMean = double(chMean);
    chStd = zeros(size(chMean, 1), size(chMean, 2));

    return;
end