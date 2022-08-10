function Fig = plotTopo(comp, topoSize, plotSize, visible)
    narginchk(1, 4);

    if nargin < 2
        topoSize = [8, 8];
    end

    if nargin < 3
        plotSize = [8, 8];
    end

    if nargin < 4
        visible = "on";
    end

    Fig = figure("Visible", visible);
    maximizeFig(Fig);
    margins = [0.05, 0.05, 0.1, 0.1];
    paddings = [0.01, 0.03, 0.01, 0.01];
    topo = comp.topo;
    
    for rIndex = 1:plotSize(1)
    
        for cIndex = 1:plotSize(2)
            ICNum = (rIndex - 1) * plotSize(2) + cIndex;

            if ICNum > size(topo, 1)
                continue;
            end

            mSubplot(Fig, plotSize(1), plotSize(2), ICNum, 1, margins, paddings);
            N = 5;
            C = flipud(reshape(topo(:, ICNum), topoSize)');
            C = interp2(C, N);
            C = imgaussfilt(C, 8);
            X = linspace(1, topoSize(1), size(C, 1));
            Y = linspace(1, topoSize(2), size(C, 2));
            imagesc("XData", X, "YData", Y, "CData", C); hold on;
            contour(X, Y, C, "LineColor", "k");
            [~, idx] = max(topo(:, ICNum));
            title(['IC ', num2str(ICNum), ' | max - ', num2str(idx)]);
            xlim([1 topoSize(1)]);
            ylim([1 topoSize(2)]);
            xticklabels('');
            yticklabels('');
        end
    
    end

    return;
end