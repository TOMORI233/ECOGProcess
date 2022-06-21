function Fig = plotTopo(comp)

    Fig = figure;
    maximizeFig(Fig);
    margins = [0.05, 0.05, 0.1, 0.1];
    paddings = [0.01, 0.03, 0.01, 0.01];
    topo = comp.topo;
    
    for rIndex = 1:8
    
        for cIndex = 1:8
            ICNum = (rIndex - 1) * 8 + cIndex;
            mSubplot(Fig, 8, 8, ICNum, 1, margins, paddings);
            N = 4;
            C = flipud(reshape(topo(:, ICNum), [8, 8])');
            C = interp2(C, N);
            C = imgaussfilt(C, 8);
            X = linspace(1, 8, size(C, 1));
            Y = linspace(1, 8, size(C, 2));
            imagesc("XData", X, "YData", Y, "CData", C);
            [~, idx] = max(topo(:, ICNum));
            title(['IC ', num2str(ICNum), ' | max - ', num2str(idx)]);
            xlim([1 8]);
            ylim([1 8]);
            xticklabels('');
        end
    
    end

    scaleAxes(Fig, "c");
    colorbar('position', [1 - paddings(2),   0.1 , 0.5 * paddings(2), 0.8]);

    return;
end