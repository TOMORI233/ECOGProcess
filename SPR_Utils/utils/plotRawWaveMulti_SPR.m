function Fig = plotRawWaveMulti_SPR(chData, window, titleStr, plotSize, chs, visible)
narginchk(2, 6);

    if nargin < 3 || isempty(titleStr)
        titleStr = '';
    else
        titleStr = [' | ', char(titleStr)];
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

    Fig = plotRawWave(chData(1).chMean, [], window, titleStr, plotSize, chs, visible);
    setLine(Fig, "Color", chData(1).color, "LineWidth", 1.5);
    if length(chData) > 1
        for i = 2 : length(chData)
            lineSetting.color = chData(i).color;
            Fig_MultiWave = plotRawWaveAdd(Fig, chData(i).chMean, [], window, lineSetting);
        end
    end
end