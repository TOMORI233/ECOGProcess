function Fig = plotRawWave(chMean, chStd, window, varargin)
    % Description: plot raw wave of continous channel-by-time data (single-condition)
    % Input:
    %     chMean: channel-by-time matrix of mean waves (2-D), not empty.
    %     chStd: channel-by-time matrix of wave stds (2-D). If set empty, error bars will not be shown.
    %     window: time window in ms, a strictly increasing 2-element vector.
    %     titleStr: the default title is 'CH xx'. If not set empty, it would be 'CH xx | titleStr' for each channel plot
    %     plotSize: default is autoPlotSize(size(chMean, 1)), where autoPlotSize is a function that
    %               returns the best plot size for the specified subplot number.
    %               If set empty and [chs] is specified, plotSize will be computed by autoPlotSize(numel(chs)).
    %               If set a scalar, it represents the number of channels to plot and will be computed by autoPlotSize(plotSize)
    %               If set a 2-element vector, it represents [nRows, nCols].
    %     chs: channels to plot, default: all channels
    %          If set [nRows, nCols], it specifies channel numbers for each subplot.
    %          If set a scalar, [chs] represents the first channel to plot and the following
    %          channels will be determined by [plotSize] (automatically resize).
    %          Zeros in [chs] will be skipped.
    %     visible: visibility of the figure, "on" or "off", default: "on"
    % Output:
    %     Fig: the figure object
    % Example:
    %     window = [-100, 1100]; % ms
    %     trialsData = selectEcog(data.lfp, trialAll, "trial onset", window);
    %     chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(trialsData), "UniformOutput", false));
    %
    %     % Plot all channels without error bars
    %     plotRawWave(chMean, [], window);
    %
    %     % Plot channel 1-9
    %     chs = 1:9;
    %     plotRawWave(chMean, [], window, [], autoPlotSize(numel(chs)), chs)

    mIp = inputParser;
    mIp.addRequired("chMean", @(x) validateattributes(x, {'numeric'}, {'2d'}));
    mIp.addRequired("chStd",  @(x) validateattributes(x, {'numeric'}, {'2d'}));
    mIp.addRequired("window", @(x) validateattributes(x, {'numeric'}, {'numel', 2, 'increasing'}));
    mIp.addOptional("titleStr", [], @(x) isempty(x) || isstring(x) || ischar(x));
    mIp.addOptional("plotSize", autoPlotSize(size(chMean, 1)), @(x) all(fix(x) == x) && numel(x) <= 2 && all(x > 0));
    mIp.addOptional("chs",      [], @(x) all(fix(x) == x & x >= 0));
    mIp.addOptional("visible",  "on", @(x) any(validatestring(x, {'on', 'off'})));
    mIp.parse(chMean, chStd, window, varargin{:});

    titleStr = mIp.Results.titleStr;
    plotSize = mIp.Results.plotSize;
    chs = mIp.Results.chs;
    visible = mIp.Results.visible;

    if isempty(titleStr)
        titleStr = '';
    else
        titleStr = [' | ', char(titleStr)];
    end

    if isempty(plotSize) && isempty(chs)
        error("chs should be specified if plotSize is set empty");
    elseif numel(plotSize) == 1 % the number of channels
        plotSize = autoPlotSize(plotSize);
    elseif isempty(plotSize)
        plotSize = autoPlotSize(numel(chs));
    end

    if isempty(chs)
        chs = reshape(1:(plotSize(1) * plotSize(2)), plotSize(2), plotSize(1))';
    elseif isscalar(chs)
        chs = reshape(chs(1):(chs(1) + plotSize(1) * plotSize(2) - 1), plotSize(2), plotSize(1))';
    elseif size(chs, 1) ~= plotSize(1) || size(chs, 2) ~= plotSize(2)
        disp("chs option not matched with plotSize. Resize chs...");
        temp = zeros(plotSize(1) * plotSize(2), 1);
        temp(1:numel(chs)) = chs;
        chs = reshape(temp, plotSize(2), plotSize(1))';
    end

    Fig = figure("Visible", visible);
    margins = [0.05, 0.05, 0.1, 0.1];
    paddings = [0.01, 0.03, 0.01, 0.01];
    maximizeFig(Fig);

    for rIndex = 1:plotSize(1)

        for cIndex = 1:plotSize(2)
            
            if chs(rIndex, cIndex) == 0 || chs(rIndex, cIndex) > size(chMean, 1)
                continue;
            end

            chNum = chs(rIndex, cIndex);
            t = linspace(window(1), window(2), size(chMean, 2));
            mSubplot(Fig, plotSize(1), plotSize(2), (rIndex - 1) * plotSize(2) + cIndex, [1, 1], margins, paddings);
            hold(gca, "on");

            if ~isempty(chStd)
                y1 = chMean(chNum, :) + chStd(chNum, :);
                y2 = chMean(chNum, :) - chStd(chNum, :);
                fill([t fliplr(t)], [y1 fliplr(y2)], [0, 0, 0], 'edgealpha', '0', 'facealpha', '0.3', 'DisplayName', 'Error bar');
            end

            plot(t, chMean(chNum, :), "r", "LineWidth", 1.5);
            xlim(window);
            title(['CH ', num2str(chNum), titleStr]);

            if ~mod(((rIndex - 1) * plotSize(2) + cIndex - 1), plotSize(2)) == 0
                yticks([]);
                yticklabels('');
            end

            if (rIndex - 1) * plotSize(2) + cIndex < (plotSize(1) - 1) * plotSize(2) + 1
                xticklabels('');
            end

        end

    end

    scaleAxes(Fig, "y", "on", "symOpt", "max");
    addLines2Axes(Fig, struct("X", 0));

    return;
end
