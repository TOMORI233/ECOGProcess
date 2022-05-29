function [result, chMean, chStd] = selectEcog(ECOGDataset, trials, segOption, window, scaleFactor)
    narginchk(2, 5);

    if nargin < 3
        segOption = "trial onset";
    end

    if nargin < 4
        window = [-3000, 7000];
    end

    if nargin < 5
        scaleFactor = 1e6;
    end

    fs = ECOGDataset.fs;
    windowIndex = fix(window / 1000 * fs);

    switch segOption
        case "trial onset"
            segIndex = cellfun(@(x) fix(x(1) / 1000 * fs), {trials.soundOnsetSeq}');
        case "dev onset"
            segIndex = fix([trials.devOnset]' / 1000 * fs);
        case "push onset" % make sure pushing time of all trials not empty

            if length(trials) ~= length([trials.firstPush])
                error("Pushing time of all trials should not be empty");
            end

            segIndex = fix([trials.firstPush]' / 1000 * fs);
    end

    % by trial
    result = cell(length(segIndex), 1);

    for index = 1:length(segIndex)
        result{index} = ECOGDataset.data(:, segIndex(index) + windowIndex(1):segIndex(index) + windowIndex(2));
    end

    % scale
    result = cellfun(@(x) x * scaleFactor, result, "UniformOutput", false);

    % by channel
    nChs = length(ECOGDataset.channels);
    temp = cell2mat(result);
    chMean = zeros(nChs, size(result{1}, 2));
    chStd = zeros(nChs, size(result{1}, 2));
    
    for index = 1:nChs
        chMean(index, :) = mean(temp(index:nChs:length(result) * nChs, :), 1);
        chStd(index, :) = std(temp(index:nChs:length(result) * nChs, :), [], 1);
    end

    return;
end