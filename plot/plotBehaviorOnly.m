function [Fig, mAxe, nPush, nTotal] = plotBehaviorOnly(trials, color, legendStr, Fig, mAxe, cueType)
    narginchk(3, 6);
    margins = [0.1, 0.1, 0.1, 0.1];

    if nargin < 4
        Fig = figure;
        cueType = "freq";
    end
    if nargin < 6
        cueType = "freq";
    end

    if nargin == 4
        error("The number of input params should be 1 or 3");
    end
    
    if isfield(trials,'ordrSeq')
        diffLevel = roundn(cellfun(@(x) x(end) / x(1), {trials.ordrSeq}), -2);
    else
        diffLevel = roundn(cellfun(@(x) x(end) / x(1), {trials.freqSeq}), -2);
    end

    
    
    if  cueType == "loc"
        diffLevel = cellfun(@(x) x(end), {trials.locSeq});
    end
    diffLevelUnique = unique(diffLevel);
    
    nPush = [];
    nTotal = [];
    
    maximizeFig(Fig);
    
    for dIndex = 1:length(diffLevelUnique)
        temp = trials(diffLevel == diffLevelUnique(dIndex) & [trials.interrupt] == false);
        nTotal = [nTotal, length(temp)];
        nPush = [nPush, length([temp.firstPush])];
        RT = cell2mat(cellfun(@(x, y) x - y, {temp.firstPush}, {temp.devOnset}, 'UniformOutput', false));

        if nargin < 5
            mAxe(dIndex + 1) = mSubplot(Fig, length(diffLevelUnique), 4, 4 * dIndex, [1, 1], [0.1, 0.1, 0.15, 0.15]);
        end

        scatter(mAxe(dIndex + 1), RT, 1:length(RT), 40, color, "filled");
        hold on;
        meanRT = mean(RT);
        yaxis = get(mAxe(dIndex + 1), "YLim");
        stem(mAxe(dIndex + 1), meanRT, yaxis(2), "Color", color, "LineStyle", "-", "LineWidth", 1.5);
        xlim(mAxe(dIndex + 1), [0, 800]);
        xlabel(mAxe(dIndex + 1), 'Reaction Time (ms)');
        title(mAxe(dIndex + 1), ['dRatio = ', num2str(diffLevelUnique(dIndex))]);
    end

    if nargin < 5
        mAxe(1) = mSubplot(Fig, 2, 2, 1, [1, 1], margins);
    end

    plot(mAxe(1), nPush ./ nTotal, "Color", color, "LineWidth", 2, "DisplayName", legendStr);
    hold on;
    xticks(mAxe(1), 1:length(diffLevelUnique));
    xticklabels(mAxe(1), diffLevelUnique);
    ylim(mAxe(1), [0 1]);
    yticks(mAxe(1), 0:0.2:1);
    xlabel(mAxe(1), "Difference Ratio (DEV / STD)");
    ylabel(mAxe(1), "Push Ratio");
    legend(mAxe(1), "Location", "best");

    for index = 1:length(nPush)
        text(mAxe(1), index, nPush(index) / nTotal(index), [num2str(nPush(index)), '/', num2str(nTotal(index))]);
    end

    return;
end