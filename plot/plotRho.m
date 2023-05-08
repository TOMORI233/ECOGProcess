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

function mSetFigRho(handle, event, Fig)

UserData = get(Fig, "UserData");
Window = UserData.Window;
selWin = UserData.selWin;
REFCH = UserData.REFCH;
selNum = UserData.selNum;
trialsECOG = UserData.trialsECOG;
method = UserData.method;
stimStr = UserData.stimStr;




UserData.stimStr = stimStr;
prompt = [strcat("trial codes are: 0. All, ", stimStr), ...
         strcat("Window:[", strjoin(string(Window), ", "), "], set select Win:"),...
         "refCh | 0 auto selection via sort ", ...
         "number of channels to average | <1 means select channels above threshold  (e.g. 0.7)", ...
         "CLim"...
         "Xlim of FigCompare"...
         "Ylim of FigCompare"];

dlgtitle = "set parameters and resort";
dims = [1 100];
devSel = getOr(UserData, "devSel", 0);
definput = [strjoin(string(devSel), ","), ...
            strjoin(string(selWin), ", "), ...
            string(REFCH), ...
            string(selNum), ...
            strjoin(string(UserData.CLim), ", "), ...
            strjoin(string(UserData.XLim), ", "), ...
            strjoin(string(UserData.YLim), ", ")];
answer = inputdlg(prompt, dlgtitle, dims, definput);


%% replot
if ~isempty(answer)
devSel = str2num(answer{1});
UserData.devSel = devSel;

selWin = str2num(answer{2});
UserData.selWin = selWin;

REFCH = str2num(answer{3});
UserData.REFCH = REFCH;

selNum = str2num(answer{4});
UserData.selNum = selNum;

qstAns = questdlg('Would you like to replot a figure?', ...
	'Replot or not', ...
	'Replot','No, hold it','Replot');

Fig.UserData = UserData;
if strcmp(qstAns, "Replot")
    Fig = mECOGCorr(trialsECOG, Window, selWin, Fig, "method", method, "refCh", REFCH, "selNum", selNum, "params", UserData.params);
end

end
end
