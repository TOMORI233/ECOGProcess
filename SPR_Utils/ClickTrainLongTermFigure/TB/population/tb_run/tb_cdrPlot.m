 %% for cdrPlot and plot comparison figure

devType = unique([trialAll.devOrdr]);
t = linspace(Window(1), Window(2), diff(Window) /1000 * fs + 1)';
    for dIndex = 1:length(devType)
        tIndex = [trialAll.devOrdr] == devType(dIndex);
        trials = trialAll(tIndex);
        trialsECOG = trialsECOG_Merge(tIndex);

        chMean{dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOG), 'UniformOutput', false));
        chStd = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOG), 'UniformOutput', false));
        RegRatio(dIndex).chMean = chMean{dIndex}; RegRatio(dIndex).color = colors(dIndex);

        % for cdr plot
        for ch = 1 : size(chMean{dIndex}, 1)
            cdrPlot(ch).info = strcat("Ch", num2str(ch));
            cdrPlot(ch).Wave(:, 2 * dIndex - 1) = t';
            cdrPlot(ch).Wave(:, cdrPlotIdx(dIndex)*2) = chMean{dIndex}(ch, :)';
        end
    end
