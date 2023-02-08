function [comp, ICs, FigTopoICA, FigWave, FigIC] = ICA_Population(trialsECOG, fs, windowICA)
    % Description: perform ICA on data and loop reconstructing data with input ICs until you are satisfied
    % Input:
    %     trialsECOG: nTrial*1 cell array of trial data (nCh*nSample matrix)
    %     fs: raw sample rate for [trialsECOG], in Hz
    %     windowICA: time window for [trialsECOG], in ms
    % Output:
    %     comp: result of ICA (FieldTrip) without field [trial]
    %     ICs: the input IC number array for data reconstruction
    %     FigTopoICA: figure of topo of all ICs

    comp0 = mICA(trialsECOG, windowICA, fs);
    comp = realignIC(comp0, windowICA);

    ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
    ICStd = cell2mat(cellfun(@(x) std(x, [], 1), changeCellRowNum(comp.trial), "UniformOutput", false));
    FigIC = plotRawWave(ICMean, ICStd, windowICA, "ICA");
    FigTopoICA = plotTopoICA(comp, [8, 8], [8, 8]);
    colormap('jet');
    FigWave(1) = plotRawWave(cell2mat(cellfun(@mean, changeCellRowNum(trialsECOG), "UniformOutput", false)), [], windowICA, "origin");
    scaleAxes(FigWave(1), "y", "on", "symOpts", "max");
    k = 'N';
    while ~strcmp(k, 'y') && ~strcmp(k, 'Y')

        try
            close(FigWave(2));
        end

        ICs = input('Input IC number for data reconstruction: ');
        badICs = input('Input bad IC number: ');
        ICs(ismember(ICs, badICs)) = [];
        [~, temp] = reconstructData(trialsECOG, comp, ICs);
        FigWave(2) = plotRawWave(temp, [], windowICA, "reconstruct");
        scaleAxes(FigWave(2), "y", "on", "symOpts", "max");
        k = validateInput('Press Y to continue or N to reselect ICs: ', @(x) any(validatestring(x, {'y', 'n', 'N', 'Y'})), 's');
    end

    comp.trial = [];

    return;
end