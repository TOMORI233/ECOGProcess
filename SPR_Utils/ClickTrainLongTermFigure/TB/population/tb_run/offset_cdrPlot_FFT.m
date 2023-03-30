%% process across diff devTypes
devType = unique([trialAll.devOrdr]);
% initialize
t = linspace(Window(1), Window(2), diff(Window) /1000 * fs + 1)';
PMean = cell(length(MATPATH), length(devType));
chMean = cell(length(MATPATH), length(devType));
chMeanS1 = cell(length(MATPATH), length(devType));
chMeanFilterd = cell(length(MATPATH), length(devType));
trialsECOGFilterd = cell(length(MATPATH), length(devType));


% process
for dIndex = devType
    tIndex = [trialAll.devOrdr] == dIndex;
    trials = trialAll(tIndex);
    trialsECOG = trialsECOG_Merge(tIndex);
    trialsECOG_S1 = trialsECOG_S1_Merge(tIndex);
    trialsECOGFilterd = trialsECOG_Merge_Filtered(tIndex);

    % FFT during S1
    tIdx = find(t > FFTWin(dIndex, 1) & t < FFTWin(dIndex, 2));
    [ff{dIndex}, PMean{dIndex}, trialsFFT{dIndex}]  = trialsECOGFFT(trialsECOG, fs, tIdx, [], 2);
    [tarMean, idx] = findWithinWindow(PMean{dIndex}, ff{dIndex}, [0.9, 1.1] * correspFreq( dIndex));
    [~, targetIndex] = max(tarMean, [], 2);
    if ~isempty(idx)
        targetIdx(dIndex) = mode(targetIndex) + idx(1) - 1;
    else
        targetIdx(dIndex) = 1;
    end

    tIdx_Base = find(t > baseWin(1) & t < baseWin(2));
    [ff_Base, PMean_Base{dIndex}, trialsFFT_Base{dIndex}]  = trialsECOGFFT(trialsECOG_S1, fs, tIdx_Base, [], 2);


    % raw wave
    chMean{dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOG), 'UniformOutput', false));
    chStd = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOG), 'UniformOutput', false));

    % raw wave S1
    chMeanS1{dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOG_S1), 'UniformOutput', false));
    chStdS1 = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOG_S1), 'UniformOutput', false));

    % filter
    chMeanFilterd{dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOGFilterd), 'UniformOutput', false));
    chStdFilter = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOGFilterd), 'UniformOutput', false));

    % data for corelDraw plot
    for ch = 1 : size(chMean{dIndex}, 1)
        cdrPlot(ch).info = strcat("Ch", num2str(ch));
        cdrPlot(ch).Wave(dIndex).Data(:, 1) = t';
        cdrPlot(ch).Wave(dIndex).Data(:, 2) = chMean{dIndex}(ch, :)';
        cdrPlot(ch).WaveS1(dIndex).Data(:, 1) = t';
        cdrPlot(ch).WaveS1(dIndex).Data(:, 2) = chMeanS1{dIndex}(ch, :)';
        cdrPlot(ch).WaveFilted(:, 2 * dIndex - 1) = t';
        cdrPlot(ch).WaveFilted(:, 2 * dIndex) = chMeanFilterd{dIndex}(ch, :)';
        cdrPlot(ch).FFT(dIndex).Data(:, 1) = ff{dIndex};
        cdrPlot(ch).FFT(dIndex).Data(:, 2) = PMean{dIndex}(ch, :)';
        cdrPlot(ch).FFT_S1(dIndex).Data(:, 1) = ff_Base;
        cdrPlot(ch).FFT_S1(dIndex).Data(:, 2) = PMean_Base{dIndex}(ch, :)';
    end
end