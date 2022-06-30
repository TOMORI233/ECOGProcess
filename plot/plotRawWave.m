function Fig = plotRawWave(chMean, chStd, window, titleStr, plotSize, chs)
    narginchk(3, 6);

    if nargin < 4
        titleStr = '';
    else
        titleStr = [' | ', char(titleStr)];
    end

    if nargin < 5
        plotSize = [8, 8];
    end

    if nargin < 6
        chs = reshape(1:(plotSize(1) * plotSize(2)), plotSize(1), plotSize(2))';
    end

    if size(chs, 1) ~= plotSize(1) || size(chs, 2) ~= plotSize(2)
        disp("chs option not matched with plotSize. Resize chs...");
        chs = reshape(chs(1):(chs(1) + plotSize(1) * plotSize(2) - 1), plotSize(1), plotSize(2))';
    end

    Fig = figure;
    margins = [0.05, 0.05, 0.1, 0.1];
    paddings = [0.01, 0.03, 0.01, 0.01];
    maximizeFig(Fig);

    for rIndex = 1:plotSize(1)

        for cIndex = 1:plotSize(2)
            
            if chs(rIndex, cIndex) > size(chMean, 1)
                continue;
            end

            chNum = chs(rIndex, cIndex);
            t = linspace(window(1), window(2), size(chMean, 2));
            mSubplot(Fig, plotSize(1), plotSize(2), (rIndex - 1) * plotSize(2) + cIndex, [1, 1], margins, paddings);
            
            if ~isempty(chStd)
                y1 = chMean(chNum, :) + chStd(chNum, :);
                y2 = chMean(chNum, :) - chStd(chNum, :);
                fill([t fliplr(t)], [y1 fliplr(y2)], [0, 0, 0], 'edgealpha', '0', 'facealpha', '0.3', 'DisplayName', 'Error bar');
                hold on;
            end

            plot(t, chMean(chNum, :), "r", "LineWidth", 1.5);
            hold on;

            xlim(window);
            title(['CH ', num2str(chNum), titleStr]);

            if ~mod(((rIndex - 1) * plotSize(2) + cIndex - 1), plotSize(2)) == 0
                yticks([]);
                yticklabels('');
            end

            if chNum < (plotSize(1) - 1) * plotSize(2) + 1
                xticklabels('');
            end

        end

    end

    yRange = scaleAxes(Fig);
    allAxes = findobj(Fig, "Type", "axes");

    for aIndex = 1:length(allAxes)
        plot(allAxes(aIndex), [0, 0], yRange, "k--", "LineWidth", 0.6);
    end

    return;
end
