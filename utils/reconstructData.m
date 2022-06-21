function [rec, comp] = reconstructData(ICAres, comp, ICs)
    comp.topo(:, ~ismember(1:size(comp.topo, 2), ICs)) = 0;
    rec = cellfun(@(x) comp.topo * x, ICAres, "UniformOutput", false);
    return;
end