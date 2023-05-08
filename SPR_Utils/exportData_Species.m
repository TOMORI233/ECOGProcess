%% CC
clear ; clc
recordPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\SPR_Utils\ClickTrainLongTermFigure\Species\Species_CTLRecording_CC.xlsx");
recordInfo = table2struct(readtable(recordPath));
exported = [recordInfo.Exported]';
iIndex = find(exported == 0);  % export sorted and unprocessed spike data

% export sorted and unprocessed spike data 
for i = iIndex'
    disp(strcat("processing ", recordInfo(i).paradigm, "... (", num2str(i), "/", num2str(max(iIndex)), ")"));
    recordInfo = table2struct(readtable(recordPath));
    SAVEPATH = strcat("E:\ECOG\MAT Data\CC\ClickTrainLongTerm\SpeciesNew\", string(recordInfo(i).paradigm), "\");
    BLOCKPATH{1} = recordInfo(i).tankPath;
    params.processFcn = @PassiveProcess_clickTrainContinuous;
    exportDataFcn(BLOCKPATH, SAVEPATH, params, 600, 1);
    recordInfo(i).Exported = 1;
    writetable(struct2table(recordInfo), recordPath);
end


%% XX
clear ; clc
recordPath = strcat(fileparts(fileparts(mfilename("fullpath"))), "\SPR_Utils\ClickTrainLongTermFigure\Species\Species_CTLRecording_XX.xlsx");
recordInfo = table2struct(readtable(recordPath));
exported = [recordInfo.Exported]';
iIndex = find(exported == 0);  % export sorted and unprocessed spike data

% export sorted and unprocessed spike data 
for i = iIndex'
    disp(strcat("processing ", recordInfo(i).paradigm, "... (", num2str(i), "/", num2str(max(iIndex)), ")"));
    recordInfo = table2struct(readtable(recordPath));
    SAVEPATH = strcat("E:\ECOG\MAT Data\XX\ClickTrainLongTerm\SpeciesNew\", string(recordInfo(i).paradigm), "\");
    BLOCKPATH{1} = recordInfo(i).tankPath;
    params.processFcn = @PassiveProcess_clickTrainContinuous;
    exportDataFcn(BLOCKPATH, SAVEPATH, params, 600, 1);
    recordInfo(i).Exported = 1;
    writetable(struct2table(recordInfo), recordPath);
end
