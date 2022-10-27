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
%             case 1 % chouchou AC large
%                 image(layAx, cc_AC_sulcus_large); hold on
%             case 2 % chouchou PFC large
%                 image(layAx, cc_PFC_sulcus_large); hold on
            case 1 % chouchou AC square
                image(layAx, cc_AC_sulcus_square); hold on
            case 2 % chouchou PFC square
                image(layAx, cc_PFC_sulcus_square); hold on
%             case 11 % xiaoxiao AC large
%             
%             case 12 % xiaoxiao PFC large

            case 3 % xiaoxiao AC square 
                image(layAx, xx_AC_sulcus_square); hold on
            case 4 % xiaoxiao PFC square
                image(layAx, xx_PFC_sulcus_square); hold on
        end

        alpha(layAx, alphaValue);
        set(layAx, 'XTickLabel', []);
        set(layAx, 'YTickLabel', []);
        set(layAx, 'Box', 'off');
        set(layAx, 'visible', 'off');

        % Set as background
%         allAxes = findobj(Figs(fIndex), "Type", "axes");
        allAxes = get(Figs(fIndex), "child");
        set(Figs(fIndex), 'child', [allAxes; layAx]);
        drawnow;
    end

    return;
end
