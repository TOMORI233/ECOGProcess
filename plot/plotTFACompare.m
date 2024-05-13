function Fig = plotTFACompare(chMean1, chMean2, fs0, fs, window, titleStr, plotSize, chs)
    % Description: plot cwt difference between chMean1 and chMean2
    % Warning: This function is obsolete since 2024/03. Please use
    %          plotTFA() instead.

    warning("This function is obsolete since 2024/03. Please use plotTFA() instead.");

    narginchk(5, 8);

    if nargin < 6 || isempty(titleStr)
        titleStr = '';
    else
        titleStr = [' | ', char(titleStr)];
    end

    if nargin < 7
        plotSize = autoPlotSize(size(chMean1, 1));
    end

    if nargin < 8
        chs = reshape(1:(plotSize(1) * plotSize(2)), plotSize(2), plotSize(1))';
    end

    if size(chs, 1) ~= plotSize(1) || size(chs, 2) ~= plotSize(2)
        disp("chs option not matched with plotSize. Resize chs...");
        chs = reshape(chs(1):(chs(1) + plotSize(1) * plotSize(2) - 1), plotSize(2), plotSize(1))';
    end

    Fig = figure("WindowState", "maximized");
    margins = [0.05, 0.05, 0.1, 0.1];
    paddings = [0.01, 0.03, 0.01, 0.01];

    for rIndex = 1:plotSize(1)

        for cIndex = 1:plotSize(2)

            if chs(rIndex, cIndex) > size(chMean1, 1)
                continue;
            end

            chNum = chs(rIndex, cIndex);
            mSubplot(Fig, plotSize(1), plotSize(2), (rIndex - 1) * plotSize(2) + cIndex, [1, 1], margins, paddings);
            [t, Y, CData1, coi] = mCWT(double(chMean1(chNum, :)), fs0, 'morlet', fs);
            [~, ~, CData2, ~] = mCWT(double(chMean2(chNum, :)), fs0, 'morlet', fs);
            X = t * 1000 + window(1);
            imagesc('XData', X, 'YData', Y, 'CData', CData1 - CData2);
            colormap("jet");
            hold on;
            plot(X, coi, 'w--', 'LineWidth', 0.6);
            title(['CH ', num2str(chNum), titleStr]);
            set(gca, "YScale", "log");
            yticks([0, 2.^(0:nextpow2(max(Y)) - 1)]);
            xlim(window);
            ylim([min(Y), max(Y)]);

            if ~mod(((rIndex - 1) * plotSize(2) + cIndex - 1), plotSize(2)) == 0
                yticks([]);
                yticklabels('');
            end

            if chNum < (plotSize(1) - 1) * plotSize(2) + 1
                xticklabels('');
            end

        end

    end

    colorbar('position', [1 - paddings(2),   0.1 , 0.5 * paddings(2), 0.8]);

    yRange = scaleAxes(Fig);
    scaleAxes(Fig, "c", [], [], "max");
    allAxes = findobj(Fig, "Type", "axes");

    for aIndex = 1:length(allAxes)
        plot(allAxes(aIndex), [0, 0], yRange, "w--", "LineWidth", 0.6);
    end

    return;
end
