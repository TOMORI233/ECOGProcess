function [resultSTD, chMean, chStd, window] = joinSTD2(trials, trialsECOG, fs)
    ISI = fix(mean(cellfun(@(x, y) (x(end) - x(1)) / y, {trials.soundOnsetSeq}, {trials.stdNum})));
    stdNumAll = unique([trials.stdNum]);
    resultSTD = cell(length(stdNumAll), 1);
    window = [-2500, ISI * max(stdNumAll) + 2000];
    
    for sIndex = 1:length(stdNumAll)
    
        if sIndex == 1
            windowSTD = [window(1), ISI * stdNumAll(sIndex)];
        elseif sIndex == length(stdNumAll)
            windowSTD = [ISI * (stdNumAll(sIndex) - 1), window(2)];
        else
            windowSTD = [ISI * (stdNumAll(sIndex) - 1), ISI * stdNumAll(sIndex)];
        end
    
        temp = trialsECOG([trials.stdNum] >= stdNumAll(sIndex));
        weightSTD = zeros(1, size(temp{1}, 2));
        weightSTD(floor((windowSTD(1) - window(1)) * fs / 1000 + 1):floor((windowSTD(2) - window(1)) * fs / 1000)) = 1 / length(temp);
        
        if length(temp) > 1
            resultSTD{sIndex} = cell2mat(cellfun(@sum, changeCellRowNum(cellfun(@(x) x .* weightSTD, temp, "UniformOutput", false)), "UniformOutput", false));
        else
            resultSTD{sIndex} = temp{1};
        end

    end
    
    chMean = resultSTD{1};
    
    for index = 2:length(resultSTD)
        chMean = chMean + resultSTD{index};
    end
    
    chMean = double(chMean);
    chStd = zeros(size(chMean, 1), size(chMean, 2));

    return;
end