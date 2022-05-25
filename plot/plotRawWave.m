function Fig = plotRawWave(dataMean, dataSD, window, titleStr)
    narginchk(3, 4);

    if nargin < 4
        titleStr = '';
    else
        titleStr = [' | ', char(titleStr)];
    end

    Fig = figure;
    margins = [0.05, 0.05, 0.1, 0.1];
    maximizeFig(Fig);

    for rIndex = 1:8

        for cIndex = 1:8
            chNum = (rIndex - 1) * 8 + cIndex;
            t = linspace(window(1), window(2), size(dataMean, 2));
            mSubplot(Fig, 8, 8, chNum, [1, 1], margins);
            y1 = dataMean(chNum, :) + dataSD(chNum, :);
            y2 = dataMean(chNum, :) - dataSD(chNum, :);
            fill([t fliplr(t)], [y1 fliplr(y2)], [0, 0, 0], 'edgealpha', '0', 'facealpha', '0.3', 'DisplayName', 'Error bar');
            hold on;
            plot(t, dataMean(chNum, :), "r", "LineWidth", 1.5);

            xlim(window);
            title(['CH ', num2str(chNum), titleStr]);

            if ~mod((chNum - 1), 8) == 0
                yticklabels('');
            end

            if chNum < 57
                xticklabels('');
            end

        end

    end

    return;
end
