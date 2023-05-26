function res = calCorrLag(r1, r2, binSizeHalf)

    if length(r1) ~= length(r2)
        error('Data length should be the same.');
    end
    
    temp1 = arrayfun(@(x) r1(x - binSizeHalf:x + binSizeHalf), binSizeHalf + 1:length(r1) - binSizeHalf, "UniformOutput", false)';
    temp2 = arrayfun(@(x) r2(x - binSizeHalf:x + binSizeHalf), binSizeHalf + 1:length(r2) - binSizeHalf, "UniformOutput", false)';
    
    idx = (binSizeHalf + 1:length(temp1) - binSizeHalf)';
    res = cell2mat(arrayfun(@(x1) arrayfun(@(x2) corrAnalysis(temp1{x1}, temp2{x2}), x1 - binSizeHalf:x1 + binSizeHalf), idx, "Uni", false));

    return;
end