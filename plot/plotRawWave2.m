function Fig = plotRawWave2(Fig, chMean, chStd, window, lineColor, plotSize)
    narginchk(5, 6);


    if nargin < 6
        plotSize = [8, 8];
    end

    allAxes = findobj(Fig, "Type", "axes");


    for rIndex = 1:plotSize(1)

        for cIndex = 1:plotSize(2)
            chNum = (rIndex - 1) * plotSize(2) + cIndex;

            if chNum > size(chMean, 1)
                continue;
            end
            
            t = linspace(window(1), window(2), size(chMean, 2));
            
            if ~isempty(chStd)
                y1 = chMean(chNum, :) + chStd(chNum, :);
                y2 = chMean(chNum, :) - chStd(chNum, :);
                fill([t fliplr(t)], [y1 fliplr(y2)], [0, 0, 0], 'edgealpha', '0', 'facealpha', '0.3', 'DisplayName', 'Error bar');
                hold on;
            end

            plot(allAxes(length(allAxes) - chNum + 1), t, chMean(chNum, :), 'color', lineColor, "LineWidth", 1.5); 
            hold on;

            xlim(window);
        end

    end
    return;
end

