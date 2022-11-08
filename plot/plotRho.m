function Fig = plotRho(rho, chSort)
narginchk(1, 2);
if nargin < 2
    chSort = 1 : size(rho, 1);
end
Fig = figure;
maximizeFig(Fig);
margins = [0, 0, 0, 0];
paddings = [0.015, 0.015, 0.015, 0.015];
mAxe = mSubplot(Fig, 1, 1, 1, [1, 1], margins, paddings);
C = flip(rho);
imagesc("CData", C); hold on;
set(mAxe, "xtick", 1 : size(rho, 1));
set(mAxe,"ytick", 1 : size(rho, 1));
set(mAxe,"xticklabel", string(chSort));
set(mAxe,"yticklabel", string(flip(chSort)));
xlim([0.5 size(rho, 1)+0.5]);
ylim([0.5 size(rho, 1)+0.5]);
if ~any(rho < 0)
    scaleAxes(mAxe, "c", [0, 1]);
else
    scaleAxes(mAxe, "c", [-1, 1]);
end
colormap("jet");
colorbar;
return;
end