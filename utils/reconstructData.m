function [trialsECOG, chMean] = reconstructData(trialsECOG, comp, ICs)
    comp.topo(:, ~ismember(1:size(comp.topo, 2), ICs)) = 0;
    trialsICA = comp.unmixing * trialsECOG;
    trialsECOG = cellfun(@(x) comp.topo * x, trialsICA, "UniformOutput", false);
    chMean = cell2mat(cellfun(@mean, changeCellRowNum(trialsECOG), "UniformOutput", false));
    return;
end