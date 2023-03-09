function [Fig, mAxe, nPush, nTotal] = plotBehaviorOnly(trials, color, varargin)
    mIp = inputParser;
    mIp.addRequired("trials", @isstruct);
    mIp.addRequired("color");
    mIp.addOptional("Fig", [], @(x) strcmp(class(x), "matlab.ui.Figure"));
    mIp.addOptional("mAxe", [], @(x) strcmp(class(x), "matlab.graphics.axis.Axes"));
    mIp.addParameter("cueType", "freq", @(x) any(validatestring(x, {'freq', 'loc'})));
    mIp.addParameter("legendStr", [], @(x) ischar(x) || isstring(x));
    mIp.addParameter("xlabelStr", [], @(x) ischar(x) || isstring(x));
    mIp.parse(trials, color, varargin{:});

    legendStr = mIp.Results.legendStr;
    Fig = mIp.Results.Fig;
    mAxe = mIp.Results.mAxe;
    cueType = mIp.Results.cueType;
    xlabelStr = mIp.Results.xlabelStr;

    if isempty(Fig)
        Fig = figure;
        maximizeFig(Fig);
    end

    margins = [0.1, 0.1, 0.1, 0.1];
    
    if isfield(trials, 'ordrSeq')
        diffLevel = roundn(cellfun(@(x) x(end) / x(1), {trials.ordrSeq}), -2);
    else
        diffLevel = roundn(cellfun(@(x) x(end) / x(1), {trials.freqSeq}), -2);
    end
    
    if strcmpi(cueType, "loc")
        diffLevel = cellfun(@(x) x(end), {trials.locSeq});
    end

    diffLevelUnique = unique(diffLevel);
    
    nPush = [];
    nTotal = [];
    
    for dIndex = 1:length(diffLevelUnique)
        temp = trials(diffLevel == diffLevelUnique(dIndex) & [trials.interrupt] == false);
        nTotal = [nTotal, length(temp)];
        nPush = [nPush, length([temp.firstPush])];
        RT = cell2mat(cellfun(@(x, y) x - y, {temp.firstPush}, {temp.devOnset}, 'UniformOutput', false));

        if isempty(mAxe)
            mAxe = mSubplot(Fig, 2, 2, 1, [1, 1], margins);
        end

        mAxe(dIndex + 1) = mSubplot(Fig, length(diffLevelUnique), 4, 4 * dIndex, [1, 1], [0.1, 0.1, 0.2, 0.2]);
        scatter(mAxe(dIndex + 1), RT, 1:length(RT), 40, color, "filled");
        hold on;
        meanRT = mean(RT);
        yaxis = get(mAxe(dIndex + 1), "YLim");
        stem(mAxe(dIndex + 1), meanRT, yaxis(2), "Color", color, "LineStyle", "-", "LineWidth", 1.5);
        xlim(mAxe(dIndex + 1), [0, 800]);
        xlabel(mAxe(dIndex + 1), 'Reaction Time (ms)');
        title(mAxe(dIndex + 1), ['dRatio = ', num2str(diffLevelUnique(dIndex))]);
    end

    L = plot(mAxe(1), nPush ./ nTotal, "Color", color, "LineWidth", 2);
    if ~isempty(legendStr)
        set(L, "DisplayName", legendStr);
        legend(mAxe(1), "Location", "best");
    end
    hold on;
    xticks(mAxe(1), 1:length(diffLevelUnique));
    xticklabels(mAxe(1), diffLevelUnique);
    ylim(mAxe(1), [0 1]);
    yticks(mAxe(1), 0:0.2:1);
    if ~isempty(xlabelStr)
        xlabel(mAxe(1), xlabelStr);
    end
    ylabel(mAxe(1), "Push Ratio");

    for index = 1:length(nPush)
        text(mAxe(1), index, nPush(index) / nTotal(index), [num2str(nPush(index)), '/', num2str(nTotal(index))]);
    end

    return;
end