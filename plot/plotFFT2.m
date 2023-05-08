function Fig = plotFFT2(Fig, yData, xData, window, lineColor, plotSize)
    narginchk(5, 6);


    if nargin < 6
        plotSize = [8, 8];
    end

    allAxes = findobj(Fig, "Type", "axes");


    for rIndex = 1:plotSize(1)

        for cIndex = 1:plotSize(2)
            chNum = (rIndex - 1) * plotSize(2) + cIndex;

            if chNum > size(yData, 1)
                continue;
            end
            
            t = linspace(window(1), window(2), size(yData, 2));
            

            plot(allAxes(length(allAxes) - chNum + 1), xData, yData(chNum, :), 'color', lineColor, "LineWidth", 1.5); 
            hold on;

            xlim(window);
        end

    end
    return;
end

