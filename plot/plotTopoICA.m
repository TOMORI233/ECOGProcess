function Fig = plotTopoICA(comp, topoSize, plotSize, ICs)
    narginchk(1, 4);

    if nargin < 2
        topoSize = [8, 8];
    end

    if nargin < 3
        plotSize = [8, 8];
    end

    if nargin < 4
        ICs = reshape(1:(plotSize(1) * plotSize(2)), plotSize(2), plotSize(1))';
    end

    if size(ICs, 1) ~= plotSize(1) || size(ICs, 2) ~= plotSize(2)
        disp("chs option not matched with plotSize. Resize chs...");
        ICs = reshape(ICs(1):(ICs(1) + plotSize(1) * plotSize(2) - 1), plotSize(2), plotSize(1))';
    end

    Fig = figure;
    maximizeFig(Fig);
    margins = [0.05, 0.05, 0.1, 0.1];
    paddings = [0.01, 0.03, 0.01, 0.01];
    topo = comp.topo;
    
    for rIndex = 1:plotSize(1)
    
        for cIndex = 1:plotSize(2)
            ICNum = ICs(rIndex, cIndex);


            if ICs(rIndex, cIndex) > size(topo, 1)
                continue;
            end

            mAxe = mSubplot(Fig, plotSize(1), plotSize(2), (rIndex - 1) * plotSize(2) + cIndex, [1, 1], margins, paddings);
            plotTopo(mAxe, topo(:, ICNum), topoSize);
            [~, idx] = max(topo(:, ICNum));
            title(['IC ', num2str(ICNum), ' | max - ', num2str(idx)]);
            scaleAxes(mAxe, "c", "on", "symOpts", "max");
            colorbar;
        end
    
    end

    return;
end