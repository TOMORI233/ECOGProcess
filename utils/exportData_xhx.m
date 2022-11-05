clear; clc; close all;

%% 7-10Freq active
TBPATH = "D:\Education\Lab\Projects\ECOG\MAT Data\PEOdd7-10.xlsx"; % table path
BLOCKROOTPATH = "E:\ECoG\TDT Data"; % TDT Block path
SAVEROOTPATH = "D:\Education\Lab\Projects\ECOG\MAT Data"; % MAT path to save
PROTOCOL = "7-10Freq Active";

tb = readtable(TBPATH);
Monkeys = string(tb.Monkey);
Dates = string(num2str(tb.Date));
Blocks = string(num2str(tb.ActiveBlock));
Exported = tb.Exported;

BLOCKPATHs = arrayfun(@(x, y, z) char(fullfile(BLOCKROOTPATH, x, strcat(x, y), strcat("Block-", z))), Monkeys, Dates, Blocks, "UniformOutput", false);
SAVEPATHs = arrayfun(@(x) char(fullfile(SAVEROOTPATH, upper(x), PROTOCOL, "\")), Monkeys, "UniformOutput", false);

params.choiceWin = [100, 600];
params.processFcn = @ActiveProcess_7_10Freq;
tb.Exported = exportDataFcn(BLOCKPATHs, SAVEPATHs, params, Exported);
writetable(tb, TBPATH);

%% Fcn
function Exported = exportDataFcn(BLOCKPATHs, SAVEPATHs, params, Exported)
    fd = 500; % Hz

    idxAll = find(~Exported);

    for index = 1:length(idxAll)
        AREANAME = ["AC", "PFC"];
        temp = string(split(BLOCKPATHs{idxAll(index)}, '\'));
        DateStr = temp(end - 1);
        mkdir(fullfile(SAVEPATHs{idxAll(index)}, DateStr));
        
        % AC
        disp("Loading AC Data...");
        params.posIndex = 1;
        tic
        [trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATHs{idxAll(index)}, params);
        ECOGDataset = ECOGDownsample(ECOGDataset, fd);
        ECOGDataset = ECOGFilter(ECOGDataset);
        disp("Saving...");
        save(strcat(SAVEPATHs{idxAll(index)}, DateStr, "\", DateStr, "_", AREANAME(params.posIndex), ".mat"), "ECOGDataset", "trialAll", "-mat", "-v7.3");
        toc
        
        % PFC
        disp("Loading PFC Data...");
        params.posIndex = 2;
        tic
        [~, ECOGDataset] = ECOGPreprocess(BLOCKPATHs{idxAll(index)}, params);
        ECOGDataset = ECOGDownsample(ECOGDataset, fd);
        ECOGDataset = ECOGFilter(ECOGDataset);
        disp("Saving...");
        save(strcat(SAVEPATHs{idxAll(index)}, DateStr, "\", DateStr, "_", AREANAME(params.posIndex), ".mat"), "ECOGDataset", "trialAll", "-mat", "-v7.3");
        toc

        Exported(idxAll(index)) = true;
    end

    return;
end