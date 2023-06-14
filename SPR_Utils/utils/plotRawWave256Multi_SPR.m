function Fig = plotRawWave256Multi_SPR(chData, window, titleStr, plotSize)
narginchk(2, 4);

if nargin < 3 || isempty(titleStr)
    titleStr = '';
else
    titleStr = [' | ', char(titleStr)];
end

if nargin < 4
    plotSize = [8, 11];
end
slides = siteMap256;
Fig = plotRawWave256(chData(1).chMean, [], window, titleStr);
setLine(Fig, "Color", chData(1).color, "LineWidth", 1.5);
if length(chData) > 1
    for i = 2 : length(chData)
        lineSetting.color = chData(i).color;
        for fIndex = 1 : length(Fig)
            Fig(fIndex) = plotRawWaveAdd256(Fig(fIndex), chData(i).chMean, [], window, slides{fIndex}, lineSetting, [8, 11]);
        end
    end
end
end