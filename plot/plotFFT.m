function Fig = plotFFT(yData, xData, window, titleStr, plotSize, chs, visible)
    narginchk(3, 7);

    if nargin < 4
        titleStr = '';
    else
        titleStr = [' | ', char(titleStr)];
    end

    if nargin < 5
        plotSize = [8, 8];
    end

    if nargin < 6
        chs = reshape(1:(plotSize(1) * plotSize(2)), plotSize(2), plotSize(1))';
    end

    if nargin < 7 
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
            
            if chs(rIndex, cIndex) > size(yData, 1)
                continue;
            end

            chNum = chs(rIndex, cIndex);
            
            mSubplot(Fig, plotSize(1), plotSize(2), (rIndex - 1) * plotSize(2) + cIndex, [1, 1], margins, paddings);
            

            plot(xData, yData(chNum, :), "r", "LineWidth", 1.5); hold on;
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



    return;
end
