function [resVal,idx] = findWithinInterval(value, range, col)
narginchk(2,3);
if nargin < 3
    col = 1;
end
idx = find(value(:, col)>=range(1) & value(:, col)<=range(2));
resVal = value(idx, :);
end