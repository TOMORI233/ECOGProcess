function varargout = siteMap256(varargin)


    siteMap = zeros(16, 22);
    siteMap(1, 1:20) = 237:256;
    siteMap(2, 1:20) = 217:236;
    siteMap(3, 1:20) = 197:216;
    siteMap(4, 2:20) = 178:196;
    siteMap(5, 2:20) = 159:177;
    siteMap(6, 3:20) = 141:158;
    siteMap(7, 4:21) = 123:140;
    siteMap(8, 5:21) = 106:122;
    siteMap(9, 5:21) = 89:105;
    siteMap(10, 6:22) = 72:88;
    siteMap(11, 6:22) = 55:71;
    siteMap(12, 7:22) = 39:54;
    siteMap(13, 8:22) = 24:38;
    siteMap(14, 9:22) = 10:23;
    siteMap(15, 12:20) = 1:9;

if nargin > 0
    [X,Y] = find(siteMap == ch);
    X = mod(X,8);
    Y = mod(Y, 11);
    if ~X
        X = 8;
    end

    if ~Y
        Y = 11;
    end

    varargout{1} = X;
    varargout{2} = Y;
else
slide{1} = siteMap(1:8, 1:11);
slide{2} = siteMap(1:8, 12:22);
slide{3} = siteMap(9:16, 1:11);
slide{4} = siteMap(9:16, 12:22);
varargout{1} = slide;

end
