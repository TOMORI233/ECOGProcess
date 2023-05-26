function res = corrAnalysis(r1, r2)
    % r1, r2 are row vector
    res = (r1 * r2') / sqrt((r1 * r1') * (r2 * r2'));
    return;
end