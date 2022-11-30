function Fig = plotTopo_Raw(topo, topoSize)
% to plot only one axis
narginchk(1, 2);

if nargin < 2
    topoSize = [8, 8];
end
Fig = figure;
maximizeFig(Fig);
mAxe = mSubplot(Fig, 1, 1, 1, [1 1], zeros(4, 1));
N = 5;
C = flipud(reshape(topo, topoSize)');
C = interp2(C, N);
C = imgaussfilt(C, 8);
X = linspace(1, topoSize(1), size(C, 1));
Y = linspace(1, topoSize(2), size(C, 2));
imagesc("XData", X, "YData", Y, "CData", C); hold on;
contour(X, Y, C, "LineColor", "k");

xlim([1 topoSize(1)]);
ylim([1 topoSize(2)]);
xticklabels('');
yticklabels('');
scaleAxes(mAxe, "c", [], [-10, 10], "max");

colorbar;
return;
end