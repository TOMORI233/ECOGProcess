function [Fig, res] = plotTFMean(tfOpts, window, titleStr, plotSize, chs, visible)
    narginchk(1, 6);
    
Y = tfOpts.f;
coi = tfOpts.coi;
X = tfOpts.t;
CData = tfOpts.CData;

if nargin < 2
 window = [X(1), X(end)];
end
    if nargin < 3
        titleStr = '';
    elseif ~isempty(titleStr) && ~strcmp(titleStr, '')
        titleStr = [' | ', char(titleStr)];
    else
        titleStr = '';
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

    res.TFR = [];
    
    for rIndex = 1:plotSize(1)
    
        for cIndex = 1:plotSize(2)

            if chs(rIndex, cIndex) > length(CData)
                continue;
            end

            chNum = chs(rIndex, cIndex);
            mSubplot(Fig, plotSize(1), plotSize(2), (rIndex - 1) * plotSize(2) + cIndex, [1, 1], margins, paddings);
            imagesc('XData', X, 'YData', Y, 'CData', CData{chNum});
            res.TFR = [res.TFR; CData(chNum)];
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

            if chNum < (plotSize(1) - 1) * plotSize(2) + 1
                xticklabels('');
            end
    
        end
    end
    
    colorbar('position', [1 - paddings(2),   0.1 , 0.5 * paddings(2), 0.8]);
    
    yRange = scaleAxes(Fig);
    scaleAxes(Fig, "c");
    allAxes = findobj(Fig, "Type", "axes");
    
    for aIndex = 1:length(allAxes)
        plot(allAxes(aIndex), [0, 0], yRange, "w--", "LineWidth", 0.6);
    end
    
    res.t = X;
    res.f = Y;
    res.coi = coi;
    return;
end
