function [comp, ICs, FigTopoICA] = ICA_Population(trialsECOG, fs, windowICA)
    comp0 = mICA2(trialsECOG, windowICA, fs);
    comp = realignIC(comp0, windowICA);

    ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
    ICStd = cell2mat(cellfun(@(x) std(x, [], 1), changeCellRowNum(comp.trial), "UniformOutput", false));
    plotRawWave(ICMean, ICStd, windowICA, "ICA");
    FigTopoICA = plotTopo(comp, [8, 8], [8, 8]);

    FigWave(1) = plotRawWave(cell2mat(cellfun(@mean, changeCellRowNum(trialsECOG), "UniformOutput", false)), [], windowICA, "origin");
    k = 'N';

    while ~strcmp(k, 'y') && ~strcmp(k, 'Y')

        try
            close(FigWave(2));
        end

        ICs = input('Input IC number for data reconstruction: ');
        badICs = input('Input bad IC number: ');
        ICs(badICs) = [];
        [~, temp] = reconstructData(trialsECOG, comp, ICs);
        FigWave(2) = plotRawWave(temp, [], windowICA, "reconstruct");
        k = validateInput("string", "Press Y to continue or N to reselect ICs: ", [], ["y", "n", "Y", "N"]);
    end

    comp.trial = [];

    return;
end