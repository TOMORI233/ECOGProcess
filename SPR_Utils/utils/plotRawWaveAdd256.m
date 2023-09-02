function Fig = plotRawWaveAdd256(Fig, chMean, chStd, window,  chs, lineSetting, plotSize)
    narginchk(6, 7);


    if nargin < 7
        plotSize = [8, 11];
    end

    allAxes = findobj(Fig, "Type", "axes");
color = getOr(lineSetting, "color", "red");
width = getOr(lineSetting, "width", 1);
style = getOr(lineSetting, "style", "-");

% split chMean to 4 cells

load(fullfile(fileparts(mfilename("fullpath")), "chMap_v1.mat"));
temp = sortrows(chMap, 2);
idx = temp(:, 1);
chMean = chMean(idx, :);
n = 0;
    for rIndex = 1:plotSize(1)

        for cIndex = 1:plotSize(2)
            chNum = chs(rIndex, cIndex);

            if chs(rIndex, cIndex) > size(chMean, 1) || chs(rIndex, cIndex) == 0
                continue;
            end
        n = n + 1;
     
            
            t = linspace(window(1), window(2), size(chMean, 2));
            
            if ~isempty(chStd)
                y1 = chMean(chNum, :) + chStd(chNum, :);
                y2 = chMean(chNum, :) - chStd(chNum, :);
                fill([t fliplr(t)], [y1 fliplr(y2)], [0, 0, 0], 'edgealpha', '0', 'facealpha', '0.3', 'DisplayName', 'Error bar');
                hold on;
            end

            plot(allAxes(length(allAxes) - n + 1), t, chMean(chNum, :), "color", color, "LineWidth", width, "LineStyle", style); 
            hold on;

            xlim(window);
        end

    end
    return;
end

