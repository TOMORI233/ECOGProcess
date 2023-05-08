function data = valueRowCol(data, val, idx, dim)
narginchk(3, 4)

if nargin < 4
    dim = 1; % defalt: row
end

if dim == 1
    if isempty(val)
        data(idx, :) = [];
    else
        data(idx, :) = val;
    end
elseif dim == 2
    if isempty(val)
        data(:, idx) = [];
    else
        data(:, idx) = val;
    end
end