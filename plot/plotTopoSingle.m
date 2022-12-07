function plotTopoSingle(Data, topoSize, N)
narginchk(1, 3);

if nargin < 2
    topoSize = [8, 8]; % [x, y]
end

if nargin < 3
    N = 5;
end

C = flipud(reshape(Data, topoSize)');
C = interp2(C, N);
C = imgaussfilt(C, 8);
X = linspace(1, topoSize(1), size(C, 1));
Y = linspace(1, topoSize(2), size(C, 2));
imagesc("XData", X, "YData", Y, "CData", C);
hold on;
contour(X, Y, C, "LineColor", "k");
xlim([1, topoSize(1)]);
ylim([1, topoSize(2)]);
xticklabels('');
yticklabels('');