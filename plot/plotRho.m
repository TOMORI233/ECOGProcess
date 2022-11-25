function Fig = plotRho(rho, chSort, Fig)
narginchk(1, 3);
if nargin < 2
    chSort = 1 : size(rho, 1);
end

if nargin < 3 || isempty(Fig)
    Fig = figure;
    maximizeFig(Fig);
else
    axesObj = findobj(Fig, "Type", "axes");
    if ~isempty(axesObj)
        delete(axesObj);
    end
end

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
UserData = get(Fig, "UserData");

% set CLim
if ~any(rho < 0)
    CLim = getOr(UserData, "CLim", [0, 1]);
else
    CLim = getOr(UserData, "CLim", [-1, 1]);
end
scaleAxes(mAxe, "c", CLim);
UserData.CLim = CLim;
Fig.UserData = UserData;

colormap("jet");
colorbar;

imgObj = findobj(Fig, "Type", "Image");
imgObj.ButtonDownFcn = {@mCompareCorrCh, Fig};
cm = uicontextmenu(Fig);
m = uimenu(cm, 'Text', 'set parameters and resort');
imgObj.ContextMenu = cm;
set(m, "MenuSelectedFcn", {@mSetFigRho, Fig});
return;
end