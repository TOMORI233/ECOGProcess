function CTLParams = ME_ParseOffsetParams(protStr)
% parse monkey ecog species click train longterm parameters

% load excel
configPath = strcat(fileparts(mfilename("fullpath")), "\ME_OffsetConfig.xlsx");
configTable = table2struct(readtable(configPath));
mProtocol = configTable(matches({configTable.paradigm}', protStr));

% parse CTLProt
CTLParams.protStr = string(mProtocol.paradigm);
CTLParams.S1Duration = str2double(string(strsplit(mProtocol.S1Duration, ",")));
CTLParams.Window = str2double(string(strsplit(mProtocol.Window, ",")));
CTLParams.PlotWin = str2double(string(strsplit(mProtocol.PlotWin, ",")));
CTLParams.Offset = str2double(string(strsplit(mProtocol.Offset, ",")));
CTLParams.stimStrs = strrep(string(strsplit(mProtocol.trialTypes, ",")), "_", "-");
CTLParams.FFTPlotWin = str2double(string(strsplit(mProtocol.FFTPlotWin, ",")));
CTLParams.ICAWin = str2double(string(strsplit(mProtocol.ICAWin, ",")));
CTLParams.BaseICI = str2double(string(strsplit(mProtocol.BaseICI, ",")));
CTLParams.ICI2 = str2double(string(strsplit(mProtocol.ICI2, ",")));
CTLParams.quantWin = str2double(string(strsplit(mProtocol.quantWin, ",")));
CTLParams.sponWin = str2double(string(strsplit(mProtocol.sponWin, ",")));
CTLParams.latencyWin = str2double(string(strsplit(mProtocol.latencyWin, ",")));
CTLParams.fhp = mProtocol.fhp;
CTLParams.flp = mProtocol.flp;
CTLParams.CRIMethod = mProtocol.CRIMethod;
CTLParams.pBase = mProtocol.pBase;
CTLParams.CRIScale = reshape(str2double(string(strsplit(mProtocol.CRIScale, ","))), 2, 2);
CTLParams.yScale = str2double(string(strsplit(mProtocol.yScale, ",")));

group_Index =  string(strsplit(mProtocol.group_Index, ";"));
for cIndex = 1 : length(group_Index) 
    CTLParams.group_Index{cIndex, 1} = str2double(strsplit(group_Index(cIndex), ","));
end
CTLParams.group_Str = strrep(string(strsplit(mProtocol.group_Str, ",")), "_", "-");
CTLParams.colors = string(strsplit(mProtocol.colors, ","));

FFTWin = string(strsplit(mProtocol.FFTWin, "_"));
CTLParams.FFTWin = repmat(str2double(strsplit(FFTWin(1), ",")), length(CTLParams.stimStrs), 1);
if length(FFTWin) > 1
    for wIndex = 2 : length(FFTWin)
        temp = strsplit(FFTWin(wIndex), ":");
        CTLParams.FFTWin(str2double(temp(1)), :) = str2double(strsplit(temp(2), ","));
    end
end
end

