function Fig = plotTimeFreqAnalysis(chMean, fs0, fs, window, titleStr)
    narginchk(4, 5);

    if nargin < 5
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
            mSubplot(Fig, 8, 8, chNum, [1, 1], margins);
            [t, Y, CData, coi] = mCWT(chMean(chNum, :), fs0, 'morlet', fs);
            X = t * 1000;
            imagesc('XData', X, 'YData', Y, 'CData', CData);
            colormap("jet");
            hold on;
            plot(X, coi, 'w--', 'LineWidth', 0.6);
            title(['CH ', num2str(chNum), titleStr]);
            set(gca, "YScale", "log");
            yticks([0, 2.^(0:nextpow2(max(Y)) - 1)]);

            if ~mod((chNum - 1), 8) == 0
                yticklabels('');
            end

            xticklabels('');
        end

    end

    yRange = scaleAxes(Fig);
    scaleAxes(Fig, "c");
    scaleAxes(Fig, "x", window - window(1));
    allAxes = findobj(Fig, "Type", "axes");

    for aIndex = 1:length(allAxes)
        plot(allAxes(aIndex), [0, 0] - window(1), yRange, "w--", "LineWidth", 0.6);
    end

    return;
end
