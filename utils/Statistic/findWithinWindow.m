function [resVal,idx] = findWithinWindow(value, t, range)
    idx = find(t>= range(1) & t <= range(2));
    resVal = value(idx);
end

