function [r, lag] = mXcorr(x, y, maxlag)
    narginchk(2, 3);
    
    if size(x, 1) ~= size(y, 1)
        error("The size of x and y do not equal");
    end

    for i = 1 : size(x, 1)
        if nargin < 3
            [r(i, :), lag(i, :)] = xcorr(x(i, :), y(i, :));
        else
            [r(i, :), lag(i, :)] = xcorr(x(i, :), y(i, :), maxlag);
        end
    end
end