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
