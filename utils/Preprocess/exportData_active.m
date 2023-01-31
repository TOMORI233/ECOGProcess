clear; clc; close all;

%% 7-10Freq active
TBPATH = "D:\Education\Lab\Projects\ECOG\MAT Data\PEOdd7-10.xlsx"; % table path
BLOCKROOTPATH = "E:\ECoG\TDT Data"; % TDT Block path
SAVEROOTPATH = "D:\Education\Lab\Projects\ECOG\MAT Data"; % MAT path to save
PROTOCOL = "7-10Freq Active";

tb = readtable(TBPATH);

% skip recordings
skipIdx = [];

Monkeys = string(tb.Monkey);
Dates = rowFcn(@(x) strrep(x, ' ', ''), string(num2str(tb.Date)));
Blocks = rowFcn(@(x) strrep(x, ' ', ''), string(num2str(tb.ActiveBlock)));
Exported = tb.Exported_active;

BLOCKPATHs = arrayfun(@(x, y, z) char(fullfile(BLOCKROOTPATH, x, strcat(x, y), strcat("Block-", z))), Monkeys, Dates, Blocks, "UniformOutput", false);
SAVEPATHs = arrayfun(@(x) char(fullfile(SAVEROOTPATH, upper(x), PROTOCOL, "\")), Monkeys, "UniformOutput", false);

params.choiceWin = [100, 600];
params.processFcn = @ActiveProcess_7_10Freq;
tb.Exported_active = exportDataFcn(BLOCKPATHs, SAVEPATHs, params, Exported, skipIdx);
tb.Exported_active(skipIdx) = Exported(skipIdx);
writetable(tb, TBPATH);

%% Fcn
function Exported = exportDataFcn(BLOCKPATHs, SAVEPATHs, params, Exported, skipIdx)
    fd = 500; % Hz
    fhp = 0.1; % Hz
    flp = 200; % Hz

    Exported(skipIdx) = true;
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
        ECOGDataset = ECOGResample(ECOGDataset, fd);
        ECOGDataset = ECOGFilter(ECOGDataset, fhp, flp);
        disp("Saving...");
        save(strcat(SAVEPATHs{idxAll(index)}, DateStr, "\", DateStr, "_", AREANAME(params.posIndex), ".mat"), "ECOGDataset", "trialAll", "-mat", "-v7.3");
        toc
        
        % PFC
        disp("Loading PFC Data...");
        params.posIndex = 2;
        tic
        [~, ECOGDataset] = ECOGPreprocess(BLOCKPATHs{idxAll(index)}, params);
        ECOGDataset = ECOGResample(ECOGDataset, fd);
        ECOGDataset = ECOGFilter(ECOGDataset, fhp, flp);
        disp("Saving...");
        save(strcat(SAVEPATHs{idxAll(index)}, DateStr, "\", DateStr, "_", AREANAME(params.posIndex), ".mat"), "ECOGDataset", "trialAll", "-mat", "-v7.3");
        toc

        Exported(idxAll(index)) = true;
    end

    return;
end