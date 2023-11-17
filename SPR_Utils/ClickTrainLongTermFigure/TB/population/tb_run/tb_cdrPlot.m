%% for cdrPlot and plot comparison figure


    devType = unique([trialAll.devOrdr]);
    t = linspace(Window(1), Window(2), size(trialsECOG_Merge{1}, 2))';
    fs  = length(t) * 1000/ diff(Window);
for dIndex = 1:length(devType)
    tIndex = [trialAll.devOrdr] == devType(dIndex);

%     if strcmpi(Protocol, "Add_on_LocalChange_4ms_2s-1s_N01248")
%         trialsECOG = excludeTrialsChs(trialsECOG, 0.01, Window, [0, 300]);
%     end
    trials = trialAll(tIndex);
    trialsECOG = trialsECOG_Merge(tIndex);
    trialsECOG_S1 = trialsECOG_S1_Merge(tIndex);
    chMean{dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOG), 'UniformOutput', false));
    chMeanS1{dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOG_S1), 'UniformOutput', false));
    chStd = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOG), 'UniformOutput', false));
    RegRatio(dIndex).chMean = chMean{dIndex}; RegRatio(dIndex).color = colors(dIndex);
    RegRatioS1(dIndex).chMean = chMeanS1{dIndex}; RegRatioS1(dIndex).color = colors(dIndex);
    % for cdr plot
    for ch = 1 : size(chMean{dIndex}, 1)
        cdrPlot(ch).info = strcat("Ch", num2str(ch));
        cdrPlot(ch).Wave(:, 2 * dIndex - 1) = t';
        cdrPlot(ch).Wave(:, cdrPlotIdx(dIndex)*2) = chMean{dIndex}(ch, :)';
        cdrPlot(ch).S1Wave(:, 2 * dIndex - 1) = t';
        cdrPlot(ch).S1Wave(:, cdrPlotIdx(dIndex)*2) = chMeanS1{dIndex}(ch, :)';
    end
end
