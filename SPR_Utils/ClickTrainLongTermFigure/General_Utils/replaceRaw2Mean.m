function data = replaceRaw2Mean(data, idx, dim)
narginchk(2, 3);
if nargin < 3
    dim = 1;
end

idxs = ones(size(data, dim), 1);
idxs(idx) = 0;
idxs = logical(idxs);

if dim == 1
    data(idx, :) = repmat(mean(data(idxs, :), 1), sum(~idxs), 1);
else
    data(:, idx) = repmat(mean(data(:, idxs), 2), 1, sum(~idxs));
end
end