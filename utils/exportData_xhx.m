clear; clc; close all;

%% 7-10Freq active
disp("Exporting 7-10Freq active...");
tb = readtable("D:\Education\Lab\Projects\ECOG\MAT Data\PEOdd7-10.xlsx");
BLOCKROOTPATH = "E:\ECoG\TDT Data";

Monkeys = string(tb.Monkey);
Dates = string(num2str(tb.Date));
Blocks = string(num2str(tb.ActiveBlock));

BLOCKPATHs = arrayfun(@(x, y, z) char(fullfile(BLOCKROOTPATH, x, strcat(x, y), strcat("Block-", z))), Monkeys, Dates, Blocks, "UniformOutput", false);
SAVEPATHs = arrayfun(@(x) char(fullfile("D:\Education\Lab\Projects\ECOG\MAT Data", upper(x), "7-10Freq Active\")), Monkeys, "UniformOutput", false);

params.choiceWin = [100, 600];
params.processFcn = @ActiveProcess_7_10Freq;
exportDataFcn(BLOCKPATHs, SAVEPATHs, params, 24);

%% Fcn
function exportDataFcn(BLOCKPATHs, SAVEPATHs, params, startIdx, endIdx)
    narginchk(3, 5);

    if nargin < 4
        startIdx = 1;
    end

    if nargin < 5
        endIdx = length(BLOCKPATHs);
    end

    fd = 500; % Hz

    for index = startIdx:endIdx
        AREANAME = ["AC", "PFC"];
        temp = string(split(BLOCKPATHs{index}, '\'));
        DateStr = temp(end - 1);
        mkdir(fullfile(SAVEPATHs{index}, DateStr));
        
        % AC
        disp("Loading AC Data...");
        params.posIndex = 1;
        tic
        [trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATHs{index}, params);
        ECOGDataset = ECOGDownsample(ECOGDataset, fd);
        ECOGDataset = ECOGFilter(ECOGDataset);
        disp("Saving...");
        save(strcat(SAVEPATHs{index}, DateStr, "\", DateStr, "_", AREANAME(params.posIndex), ".mat"), "ECOGDataset", "trialAll", "-mat", "-v7.3");
        toc
        
        % PFC
        disp("Loading PFC Data...");
        params.posIndex = 2;
        tic
        [~, ECOGDataset] = ECOGPreprocess(BLOCKPATHs{index}, params);
        ECOGDataset = ECOGDownsample(ECOGDataset, fd);
        ECOGDataset = ECOGFilter(ECOGDataset);
        disp("Saving...");
        save(strcat(SAVEPATHs{index}, DateStr, "\", DateStr, "_", AREANAME(params.posIndex), ".mat"), "ECOGDataset", "trialAll", "-mat", "-v7.3");
        toc
    end

end