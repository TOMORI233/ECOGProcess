function Fig = plotRawWaveMulti(chData, window, titleStr, plotSize, chs, visible)
    % Description: plot serveral raw waves in one subplot
    % Input:
    %     chData: n*1 struct with fields [chMean], [color], [lines] and [legend]
    %     window: xlim
    %     titleStr: title of subplot
    %     plotSize: [nRows, nColumns]
    %     chs: a nRows*nColumns matrix with each element specifying a channel number
    % Output:
    %     Fig: figure object
    % Example:
    %     [~, chData(1).chMean, ~] = selectEcog(ECOGDataset, trialsA, "dev onset", window);
    %     chData(1).color = "r";
    %     [~, chData(2).chMean, ~] = selectEcog(ECOGDataset, trialsB, "dev onset", window);
    %     chData(2).color = "b";
    %     Fig = plotRawWaveMulti(chData, window, "A vs B");

    narginchk(2, 6);

    if nargin < 3 || isempty(titleStr) 
        titleStr = '';
    else
        titleStr = [' | ', char(titleStr)];
    end

    if nargin < 4
        plotSize = [8, 8];
    end

    if nargin < 5
        chs = reshape(1:(plotSize(1) * plotSize(2)), plotSize(2), plotSize(1))';
    end

    if nargin < 6
        visible = "on";
    end

    if size(chs, 1) ~= plotSize(1) || size(chs, 2) ~= plotSize(2)
        disp("chs option not matched with plotSize. Resize chs...");
        chs = reshape(chs(1):(chs(1) + plotSize(1) * plotSize(2) - 1), plotSize(2), plotSize(1))';
    end

    Fig = figure("Visible", visible);
    margins = [0.05, 0.05, 0.1, 0.1];
    paddings = [0.01, 0.03, 0.01, 0.01];
    maximizeFig(Fig);

    for rIndex = 1:plotSize(1)

        for cIndex = 1:plotSize(2)

            if chs(rIndex, cIndex) > size(chData(1).chMean, 1)
                continue;
            end

            chNum = chs(rIndex, cIndex);
            mSubplot(Fig, plotSize(1), plotSize(2), (rIndex - 1) * plotSize(2) + cIndex, [1, 1], margins, paddings);

            for index = 1:length(chData)
                chMean = chData(index).chMean;
                color = getOr(chData(index), "color", "r");
                chData(index).legend = getOr(chData(index), "legend", []);
                t = linspace(window(1), window(2), size(chMean, 2));

                if ~isempty(chData(index).legend)
                    plot(t, chMean(chNum, :), "Color", color, "LineWidth", 1.5, "DisplayName", chData(index).legend);
                else
                    plot(t, chMean(chNum, :), "Color", color, "LineWidth", 1.5);
                end

                hold on;
            end

            xlim(window);
            title(['CH ', num2str(chNum), titleStr]);

            if (rIndex == 1 && cIndex == 1) && ~isempty([chData.legend])
                legend(gca, "show");
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

    yRange = scaleAxes(Fig, "y", "on");
    
    allAxes = findobj(Fig, "Type", "axes");

    for aIndex = 1:length(allAxes)
        h = plot(allAxes(aIndex), [0, 0], yRange, "k--", "LineWidth", 0.6);
        set(get(get(h, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
    end

    drawnow;
    return;
end
