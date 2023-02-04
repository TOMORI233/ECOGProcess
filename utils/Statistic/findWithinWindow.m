function [resVal,idx] = findWithinWindow(value, t, range)
if size(value, 2) ~= length(t)
    value = value';
end

    idx = find(t>= range(1) & t <= range(2));
    resVal = value(:, idx);
end

