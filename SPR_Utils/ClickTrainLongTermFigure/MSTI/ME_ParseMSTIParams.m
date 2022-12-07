function MSTIParams = ME_ParseMSTIParams(protStr)

ME_MSTI_Update_Config;

% load excel
configPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "MSTI\ME_MSTIConfig.xlsx");
configTable = table2struct(readtable(configPath));
mProtocol = configTable(matches({configTable.paradigm}', protStr));

% parse CTLProt
MSTIParams.fs = 500;
MSTIParams.orderIndex = cell2mat(cellfun(@(x) str2double(string(strsplit(x, "-"))), strsplit(string(strsplit(mProtocol.orderIndex, ";")), ",")', "uni", false));
MSTIParams.Std_Dev_Onset = cell2mat(cellfun(@(x) str2double(strsplit(x, ",")), string(strsplit(mProtocol.Std_Dev_Onset, ";")), "uni", false)');
MSTIParams.DevOnset = MSTIParams.Std_Dev_Onset(:, end);
MSTIParams.S1_S2 = table2array(cell2table(cellfun(@(x) string(strsplit(x, "_")), string(strsplit(mProtocol.S1_S2, ";")), "uni", false)'));
end

