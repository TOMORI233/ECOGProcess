function ICIs = genRandICISeq(N, edge)
ICIs = repmat(reshape(edge, [numel(edge), 1]), [ceil(N / length(edge)) * length(edge), 1]);
ICIs = ICIs(randperm(length(ICIs)));
ICIs = ICIs(1:N);