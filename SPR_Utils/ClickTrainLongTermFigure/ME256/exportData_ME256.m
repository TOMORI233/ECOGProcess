%% joker
clear ; clc
recordPath = strcat(fileparts(mfilename("fullpath")), "\ME256_Recording_Joker.xlsx");
recordInfo = table2struct(readtable(recordPath));
exported = [recordInfo.Exported]';
iIndex = find(exported == 0);  % export sorted and unprocessed spike data

% export sorted and unprocessed spike data 
for i = iIndex'
    disp(strcat("processing ", recordInfo(i).paradigm, "... (", num2str(i), "/", num2str(max(iIndex)), ")"));
    recordInfo = table2struct(readtable(recordPath));
    SAVEPATH = strcat("E:\ECOG\MAT Data\Joker\ClickTrainLongTerm\ME256\", string(recordInfo(i).paradigm), "\");
    BLOCKPATH{1} = recordInfo(i).tankPath;
    RHDPATH{1} = recordInfo(i).RHDPath;
    params.processFcn = @PassiveProcess_clickTrainContinuous;
    export256DataFcn(BLOCKPATH, RHDPATH, SAVEPATH, params, 600, 1);
    recordInfo(i).Exported = 1;
    writetable(struct2table(recordInfo), recordPath);
end



