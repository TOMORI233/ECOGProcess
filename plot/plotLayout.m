function Figs = plotLayout(Figs, posIndex)
    
    for fIndex = 1:length(Figs)
        layAx = mSubplot(Figs(fIndex), 1, 1, 1, [1 1], zeros(4, 1));
        load('layout.mat');
    
        switch posIndex
            case 1 %AC
                image(layAx, AC_sulcus); hold on
            case 2 %PFC
                image(layAx, PFC_sulcus); hold on
        end
    
        set(layAx, 'XTickLabel', []);
        set(layAx, 'YTickLabel', []);
        set(layAx, 'Box', 'off');
        set(layAx, 'visible', 'off');
        allAxes = findobj(Figs(fIndex), "Type", "axes");
        set(Figs(fIndex), 'child', [allAxes; layAx]);
    end

    return;
end
