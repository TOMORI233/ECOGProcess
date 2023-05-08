function comp = reverseIC(comp, ICs)
    comp.topo(:, ICs) = -comp.topo(:, ICs);
    comp.unmixing = comp.topo ^ (-1);
    return;
end