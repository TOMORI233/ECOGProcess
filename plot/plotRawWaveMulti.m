function Fig = plotRawWaveMulti(chData, window, varargin)
    % Description: plot serveral raw waves in one subplot
    % Input:
    %     chData: n*1 struct of fields:
    %             - chMean: [nCh,nSample]
    %             - color: [R, G, B] or valid color string
    %             - legend: string or char, if set empty
    %             - skipChs: channels not to plot
    %     other params: see plotRawWave.m
    % Output:
    %     Fig: figure object
    % Example:
    %     [~, chData(1).chMean, ~] = selectEcog(ECOGDataset, trialsA, "dev onset", window);
    %     chData(1).color = "r";
    %     [~, chData(2).chMean, ~] = selectEcog(ECOGDataset, trialsB, "dev onset", window);
    %     chData(2).color = "b";
    %     Fig = plotRawWaveMulti(chData, window, "A vs B");

    mIp = inputParser;
    mIp.addRequired("chData", @(x) isstruct(x));
    mIp.addRequired("window", @(x) validateattributes(x, {'numeric'}, {'numel', 2, 'increasing'}));
    mIp.addOptional("titleStr", [], @(x) isempty(x) || isstring(x) || ischar(x));
    mIp.addOptional("plotSize", autoPlotSize(size(chData(1).chMean, 1)), @(x) all(fix(x) == x) && numel(x) <= 2 && all(x > 0));
    mIp.addOptional("chs",      [], @(x) all(fix(x) == x & x >= 0));
    mIp.addOptional("visible",  "on", @(x) any(validatestring(x, {'on', 'off'})));
    mIp.parse(chData, window, varargin{:});

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

            if chs(rIndex, cIndex) == 0 || chs(rIndex, cIndex) > size(chData(1).chMean, 1)
                continue;
            end

            chNum = chs(rIndex, cIndex);
            mSubplot(Fig, plotSize(1), plotSize(2), (rIndex - 1) * plotSize(2) + cIndex, [1, 1], margins, paddings);

            for index = 1:length(chData)
                chMean = chData(index).chMean;
                color = getOr(chData(index), "color", "r");
                chData(index).legend = string(getOr(chData(index), "legend", []));
                skipChs = getOr(chData(index), "skipChs");

                if ismember(chNum, skipChs)
                    continue;
                end

                t = linspace(window(1), window(2), size(chMean, 2));

                if ~isempty(chData(index).legend)
                    ltemp = plot(t, chMean(chNum, :), "Color", color, "LineWidth", 1.5, "DisplayName", chData(index).legend);
                else
                    ltemp = plot(t, chMean(chNum, :), "Color", color, "LineWidth", 1.5);
                end

                hold on;
            end

            xlim(window);
            title(['CH ', num2str(chNum), titleStr]);

            if (rIndex == 1 && cIndex == 1) && ~isempty([chData.legend])
                legend(gca, "show");

                if isempty(chData(index).legend)
                    setLegendOff(ltemp);
                end

            else
                legend(gca, "hide");
            end

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

    return;
end
