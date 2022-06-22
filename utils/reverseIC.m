function comp = reverseIC(comp, ICs)
    ICAres = comp.trial;

    for index = 1:length(ICs)
        temp = comp.topo(:, ICs(index));
        comp.topo(:, ICs(index)) = -temp;
        temp = changeCellRowNum(ICAres);
        temp(ICs(index)) = {-temp{ICs(index)}};
        ICAres = changeCellRowNum(temp);
    end

    comp.trial = ICAres;
    comp.unmixing = comp.topo ^ (-1);

    return;
end