function Figs = plotLayout(Figs, posIndex, alphaValue)
    narginchk(2, 3);

    if nargin < 3
        alphaValue = 0.5;
    end
    
    for fIndex = 1:length(Figs)
        setAxes(Figs(fIndex), 'color', 'none');
        layAx = mSubplot(Figs(fIndex), 1, 1, 1, [1 1], zeros(4, 1));
        load('layout.mat');
    
        switch posIndex
            case 1 % AC
                image(layAx, AC_sulcus); hold on
            case 2 % PFC
                image(layAx, PFC_sulcus); hold on
        end

        alpha(layAx, alphaValue);
        set(layAx, 'XTickLabel', []);
        set(layAx, 'YTickLabel', []);
        set(layAx, 'Box', 'off');
        set(layAx, 'visible', 'off');

        % Set as background
        allAxes = findobj(Figs(fIndex), "Type", "axes");
        set(Figs(fIndex), 'child', [allAxes; layAx]);
        drawnow;
    end

    return;
end
