function result = selectEcog(ecog, trials, segOption, window)
    narginchk(2, 4);

    if nargin < 3
        segOption = "trial onset";
    end

    if nargin < 4
        window = [-3000, 7000];
    end

    fs = ecog.fs;
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

    result = cell(length(segIndex), 1);

    for index = 1:length(segIndex)
        result{index} = ecog.data(:, segIndex(index) + windowIndex(1):segIndex(index) + windowIndex(2));
    end

    return;
end