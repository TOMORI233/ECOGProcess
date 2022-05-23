function Fig = plotTimeFreqAnalysis(data, fs0, fs)
    Fig = figure;
    margins = [0.05, 0.05, 0.1, 0.1];
    maximizeFig(Fig);
    
    for rIndex = 1:8
    
        for cIndex = 1:8
            chNum = (rIndex - 1) * 8 + cIndex;
            mSubplot(Fig, 8, 8, chNum, [1, 1], margins);
            [t, Y, CData, coi] = mCWT(data(chNum, :), fs0, 'morlet', fs);
            X = t * 1000;
            imagesc('XData', X, 'YData', Y, 'CData', CData);
            hold on;
            plot(X, coi, 'w--', 'LineWidth', 0.6);
            title(['CH ', num2str(chNum)]);
            set(gca, "YScale", "log");
            xlim([min(X), max(X)]);
            ylim([0, inf]);
            yticks([0, 2.^(0:nextpow2(max(Y)) - 1)]);
    
            if ~mod((chNum - 1), 8) == 0
                yticklabels('');
            end
                
            xticklabels('');
        end
    
    end

end