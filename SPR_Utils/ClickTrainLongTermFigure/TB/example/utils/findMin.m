function [val, refVal, idx] = findMin(y, ref, scale)
narginchk(1, 3);
if nargin < 2
    ref = 1 : size(y, 2);
    scale = ref;
end

ref = linspace(ref(1), ref(2), size(y, 2));
dataIdx =  ref > scale(1) & ref < scale(2); 
dataRef = ref(dataIdx);

% y: n * m matrix, return n * 1 cell
idx = cellfun(@(x) find(diff(sign(diff(x(1, dataIdx))))>0)+1, array2VectorCell(y), "uni", false);
val = cellfun(@(x, y) x(y), array2VectorCell(y(:, dataIdx)), idx, "UniformOutput", false);
refVal = cellfun(@(x) dataRef(x), idx, "UniformOutput", false);
