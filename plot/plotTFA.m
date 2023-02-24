function [Fig, res] = plotTFA(chMean, fs0, fsD, window, titleStr, plotSize, chs, visible)
    narginchk(4, 8);
    
    if nargin < 5
        titleStr = '';
    elseif ~isempty(titleStr) && ~strcmp(titleStr, '')
        titleStr = [' | ', char(titleStr)];
    else
        titleStr = '';
    end

    if nargin < 6
        plotSize = [8, 8];
    end
    
    if nargin < 7
        chs = reshape(1:(plotSize(1) * plotSize(2)), plotSize(2), plotSize(1))';
    end

    if nargin < 8
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

    res.TFR = [];
    
    for rIndex = 1:plotSize(1)
    
        for cIndex = 1:plotSize(2)

            if chs(rIndex, cIndex) > size(chMean, 1)
                continue;
            end

            chNum = chs(rIndex, cIndex);
            mSubplot(Fig, plotSize(1), plotSize(2), (rIndex - 1) * plotSize(2) + cIndex, [1, 1], margins, paddings);
            [t, Y, CData, coi] = mCWT(double(chMean(chNum, :)), fs0, 'morlet', fsD);
            X = t * 1000 + window(1);
            imagesc('XData', X, 'YData', Y, 'CData', CData);
            res.TFR = [res.TFR; {CData}];
            colormap("jet");
            hold on;
            plot(X, coi, 'w--', 'LineWidth', 0.6);
            title(['CH ', num2str(chNum), titleStr]);
            set(gca, "YScale", "log");
            yticks([0, 2.^(0:nextpow2(max(Y)) - 1)]);
            xlim(window);
            ylim([min(Y), max(Y)]);
    
            if ~mod(((rIndex - 1) * plotSize(2) + cIndex - 1), plotSize(2)) == 0
                yticklabels('');
            end

            if (rIndex - 1) * plotSize(2) + cIndex < (plotSize(1) - 1) * plotSize(2) + 1
                xticklabels('');
            end
    
        end
    end
    
    colorbar('position', [1 - paddings(2), 0.1, 0.5 * paddings(2), 0.8]);
    
    yRange = scaleAxes(Fig);
    scaleAxes(Fig, "c");
    allAxes = findobj(Fig, "Type", "axes");
    
    for aIndex = 1:length(allAxes)
        plot(allAxes(aIndex), [0, 0], yRange, "w--", "LineWidth", 0.6);
    end
    
    res.t = t;
    res.f = Y;
    res.coi = coi;
    return;
end
