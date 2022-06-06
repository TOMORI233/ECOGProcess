function Fig = plotRawWaveMulti(chData, window, titleStr)
    % Description: plot serveral raw waves in one subplot
    % Input:
    %     chData: n*1 struct with fields [chMean], [chStd] and [color]
    %     window: xlim
    %     titleStr: title of subplot
    % Output:
    %     Fig: figure object
    % Example:
    %     [~, chData(1).chMean, ~] = selectEcog(ECOGDataset, trialsA, "dev onset", window);
    %     chData(1).color = "r";
    %     [~, chData(2).chMean, ~] = selectEcog(ECOGDataset, trialsB, "dev onset", window);
    %     chData(2).color = "b";
    %     Fig = plotRawWaveMulti(chData, window, "A vs B");

    narginchk(2, 3);

    if nargin < 3
        titleStr = '';
    else
        titleStr = [' | ', char(titleStr)];
    end

    Fig = figure;
    margins = [0.05, 0.05, 0.1, 0.1];
    paddings = [0.01, 0.03, 0.01, 0.01];
    maximizeFig(Fig);

    for rIndex = 1:8

        for cIndex = 1:8
            chNum = (rIndex - 1) * 8 + cIndex;
            mSubplot(Fig, 8, 8, chNum, [1, 1], margins, paddings);

            for index = 1:length(chData)
                chMean = chData(index).chMean;
                chStd = getOr(chData(index), "chStd", []);
                color = getOr(chData(index), "color", "r");

                t = linspace(window(1), window(2), size(chMean, 2));
    
                if ~isempty(chStd)
                    y1 = chMean(chNum, :) + chStd(chNum, :);
                    y2 = chMean(chNum, :) - chStd(chNum, :);
                    fill([t fliplr(t)], [y1 fliplr(y2)], [0, 0, 0], 'edgealpha', '0', 'facealpha', '0.3');
                    hold on;
                end
    
                plot(t, chMean(chNum, :), "Color", color, "LineWidth", 1.5);
                hold on;
            end

            xlim(window);
            title(['CH ', num2str(chNum), titleStr]);

            if ~mod((chNum - 1), 8) == 0
                yticks([]);
                yticklabels('');
            end

            if chNum < 57
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
