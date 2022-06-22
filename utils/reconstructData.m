function comp = reconstructData(comp, ICs)
    comp.topo(:, ~ismember(1:size(comp.topo, 2), ICs)) = 0;
    comp.unmixing = comp.topo ^ (-1);
    comp.trial = cellfun(@(x) comp.topo * x, comp.trial, "UniformOutput", false);
    return;
end