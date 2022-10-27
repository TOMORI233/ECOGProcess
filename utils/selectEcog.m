function [trialsECOG, chMean, chStd, sampleinfo] = selectEcog(ECOGDataset, trials, segOption, window, scaleFactor)
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
        case "last std"
            segIndex = cellfun(@(x) fix(x(end - 1) / 1000 * fs), {trials.soundOnsetSeq}');
        otherwise
            error("Invalid segment option");
    end

    if isempty(segIndex)
        trialsECOG{1} = zeros(size(ECOGDataset.data, 1), diff(windowIndex) + 1);
        chMean = zeros(size(ECOGDataset.data, 1), diff(windowIndex) + 1);
        chStd = zeros(size(ECOGDataset.data, 1), diff(windowIndex) + 1);
        sampleinfo = [];
    else

        if segIndex(1) <= 0
            segIndex(1) = 1;
        end

        % by trial
        trialsECOG = cell(length(segIndex), 1);
        sampleinfo = zeros(length(segIndex), 2);

        for index = 1:length(segIndex)
            sampleinfo(index, :) = [segIndex(index) + windowIndex(1), segIndex(index) + windowIndex(2)];
            trialsECOG{index} = ECOGDataset.data(:, segIndex(index) + windowIndex(1):segIndex(index) + windowIndex(2));
        end

        % scale
        trialsECOG = cellfun(@(x) x * scaleFactor, trialsECOG, "UniformOutput", false);

        % by channel
        nChs = length(ECOGDataset.channels);
        temp = cell2mat(trialsECOG);
        chMean = zeros(nChs, size(trialsECOG{1}, 2));
        chStd = zeros(nChs, size(trialsECOG{1}, 2));

        for index = 1:nChs
            chMean(index, :) = mean(temp(index:nChs:length(trialsECOG) * nChs, :), 1);
            chStd(index, :) = std(temp(index:nChs:length(trialsECOG) * nChs, :), [], 1);
        end

        return;
    end

end
