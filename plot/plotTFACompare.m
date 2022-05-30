function Fig = plotTFACompare(chMean1, chMean2, fs0, fs, window, titleStr)
    narginchk(5, 6);

    if nargin < 6
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
            [t, Y, CData1, coi] = mCWT(chMean1(chNum, :), fs0, 'morlet', fs);
            [~, ~, CData2, ~] = mCWT(chMean2(chNum, :), fs0, 'morlet', fs);
            X = t * 1000 + window(1);
            imagesc('XData', X, 'YData', Y, 'CData', CData1 - CData2);
            colormap("jet");
            hold on;
            plot(X, coi, 'w--', 'LineWidth', 0.6);
            title(['CH ', num2str(chNum), titleStr]);
            set(gca, "YScale", "log");
            yticks([0, 2.^(0:nextpow2(max(Y)) - 1)]);
            xlim(window);

            if ~mod((chNum - 1), 8) == 0
                yticklabels('');
            end

            if chNum < 57
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

    return;
end
