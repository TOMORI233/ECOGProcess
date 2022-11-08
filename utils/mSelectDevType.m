function mSelectDevType(handle, even, Fig)

UserData = get(Fig, "UserData");
trialAll = UserData.params.trialAll;
if isfield(trialAll, "devOrdr")
        devType = unique([trialAll.devOrdr]);
end

if isfield(UserData.params, "stimDlg")
    stimStrs = strcat("trial types are: 0. All, ", strjoin(UserData.params.stimDlg, ", "));
else
    stimStrs = strcat("trial codes are: 0. All, ", strjoin(string(devType), ", "));
end

prompt = stimStrs;
dlgtitle = "select trial type";
dims = [1 100];
devSel = inputdlg(prompt, dlgtitle, dims);
UserData.devSel = str2num(cell2mat(devSel));
Fig.UserData = UserData;
