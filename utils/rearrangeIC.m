function comp = rearrangeIC(comp, window, t0, dt)
    ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
    fs = comp.fsample;

    tIdx1 = max(fix((t0 - window(1)) / 1000 * fs), 1);
    tIdx2 = min(fix((t0 + dt - window(1)) / 1000 * fs), size(ICMean, 2));
    pw = std(ICMean(:, tIdx1:tIdx2), [], 2);
    
    [~, idx] = sort(pw, "descend");
    comp.trial = cellfun(@(x) x(idx, :), comp.trial, "UniformOutput", false);
    comp.topo = comp.topo(:, idx);
    comp.unmixing = comp.unmixing(idx, :);

    return;
end