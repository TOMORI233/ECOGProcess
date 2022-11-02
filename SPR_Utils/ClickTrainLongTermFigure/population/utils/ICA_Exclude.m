function [comp, ICs, FigTopoICA, FigWave] = ICA_Exclude(trialsECOG, comp, windowICA)
     ICs = 1 : size(trialsECOG{1}, 1);
    trialsICs = cellfun(@(x) comp.unmixing * x, trialsECOG, "uni", false);
    ICMean = cell2mat(cellfun(@mean, changeCellRowNum(trialsICs), "UniformOutput", false));
    ICStd = cell2mat(cellfun(@(x) std(x, [], 1), changeCellRowNum(trialsICs), "UniformOutput", false));
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