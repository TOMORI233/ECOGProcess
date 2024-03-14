function Fig = plotTFA(data, arg2, arg3, window, titleStr, plotSize, chs, visible)
    % If [data] is [trialsData] (nTrial*1 cell with nCh*nTime double), 
    % perform cwt on each trial and average the result. The second and
    % thrid inputs are origin sample rate [fs0] and downsample rate [fsD].
    % 
    % If [data] is [chMean] (nCh*nTime), perform cwt on the averaged wave. 
    % The second and thrid inputs are origin sample rate [fs0] and 
    % downsample rate [fsD].
    % 
    % If [data] is [cwtres] (nTrial*nCh*nFreq*nTime complex), plot cwt result
    % averaged across trials. The second and third inputs are frequency [f]
    % and cone of influence [coi].
    % 
    % If [data] is averaged abs([cwtres]) (nCh*nFreq*nTime), directly plot.
    % The second and third inputs are frequency [f] and cone of influence [coi].

    narginchk(4, 8);
    
    if nargin < 5
        titleStr = '';
    elseif ~isempty(titleStr) && ~strcmp(titleStr, '')
        titleStr = [' | ', char(titleStr)];
    else
        titleStr = '';
    end

    if iscell(data)
        nChs = size(data{1}, 1);
    else
        switch ndims(data)
            case 2
                nChs = size(data, 1);
            case 3
                nChs = size(data, 1);
            case 4
                nChs = size(data, 2);
            otherwise
                error("Unsupported data dimensions");
        end
    end

    if nargin < 6
        plotSize = autoPlotSize(nChs);
    end
    
    if nargin < 7
        chs = reshape(1:(plotSize(1) * plotSize(2)), plotSize(2), plotSize(1))';
    end

    if nargin < 8
        visible = "on";
    end

    if size(chs, 1) ~= plotSize(1) || size(chs, 2) ~= plotSize(2)
        disp("chs option not matched with plotSize. Resize chs...");
        chs = reshape(chs(1):(chs(1) + plotSize(1) * plotSize(2) - 1), plotSize(2), plotSize(1))';
    end

    Fig = figure("Visible", visible, "WindowState", "maximized");
    margins = [0.05, 0.05, 0.1, 0.1];
    paddings = [0.01, 0.03, 0.01, 0.01];

    if iscell(data) || ismatrix(data)
        fs0 = arg2;
        fsD = arg3;
        if ~isempty(fsD) && fsD < fs0
            temp = resampleData(data, fs0, fsD);
            [cwtres, f, coi] = cwtAny(temp, fsD, 10, "mode", "GPU");
        else
            [cwtres, f, coi] = cwtAny(data, fs0, 10, "mode", "GPU");
        end
    else
        f = arg2;
        coi = arg3;
        cwtres = data;
    end

    if ndims(cwtres) == 3 % nCh_nFreq_nTime
        
    elseif ndims(cwtres) == 4 % nTrial_nCh_nFreq_nTime
        cwtres = squeeze(mean(abs(cwtres), 1));
    else
        error("Invalid cwt result input");
    end

    t = linspace(window(1), window(2), size(cwtres, 3));
    
    for rIndex = 1:plotSize(1)
    
        for cIndex = 1:plotSize(2)

            if chs(rIndex, cIndex) > nChs
                continue;
            end

            chNum = chs(rIndex, cIndex);

            mSubplot(Fig, plotSize(1), plotSize(2), (rIndex - 1) * plotSize(2) + cIndex, [1, 1], margins, paddings);
            imagesc('XData', t, 'YData', f, 'CData', squeeze(cwtres(chNum, :, :)));
            
            title(['CH ', num2str(chNum), titleStr]);
            xlim(window);
            set(gca, "YScale", "log");
            set(gca, "YLimitMethod", "tight");
            yticks([0, 2.^(0:nextpow2(max(f)) - 1)]);
    
            if ~mod(((rIndex - 1) * plotSize(2) + cIndex - 1), plotSize(2)) == 0
                yticklabels('');
            end

            if (rIndex - 1) * plotSize(2) + cIndex < (plotSize(1) - 1) * plotSize(2) + 1
                xticklabels('');
            end
    
        end
    end

    colormap("jet");
    colorbar('position', [1 - paddings(2), 0.1, 0.5 * paddings(2), 0.8]);
    
    scaleAxes(Fig, "c");
    addLines2Axes(struct("X", 0, "color", "w", "style", "--", "width", 0.6));

    if ~isempty(coi)
        addLines2Axes(struct("X", t, "Y", coi, "color", "w", "style", "--", "width", 0.6));
    end
    
    return;
end
