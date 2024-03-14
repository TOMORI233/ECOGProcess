clear; clc; close all;

%% 7-10Freq active
TBPATH = "D:\Education\Lab\Projects\ECOG\MAT Data\PEOdd7-10.xlsx"; % table path
BLOCKROOTPATH = "E:\ECoG\TDT Data"; % TDT Block path
SAVEROOTPATH = "D:\Education\Lab\Projects\ECOG\MAT Data"; % MAT path to save
PROTOCOL = "7-10Freq Active";

tb = readtable(TBPATH);

% join blocks
joinIdx = {};

% skip recordings
skipIdx = [joinIdx{:}];

Monkeys = string(tb.Monkey);
Dates = rowFcn(@(x) strrep(x, ' ', ''), string(num2str(tb.Date)));
Blocks = rowFcn(@(x) strrep(x, ' ', ''), string(num2str(tb.ActiveBlock)));
Exported = tb.Exported_active;

BLOCKPATHs = arrayfun(@(x, y, z) char(fullfile(BLOCKROOTPATH, x, strcat(x, y), strcat("Block-", z))), Monkeys, Dates, Blocks, "UniformOutput", false);
SAVEPATHs = arrayfun(@(x) char(fullfile(SAVEROOTPATH, upper(x), PROTOCOL, "\")), Monkeys, "UniformOutput", false);

params.choiceWin = [100, 600];
params.processFcn = @ActiveProcess_7_10Freq;
params.fd = 500; % downsample, Hz
params.fhp = 0.1;
params.flp = 200;
tb.Exported_active = exportDataFcn(BLOCKPATHs, SAVEPATHs, params, Exported, skipIdx);
tb.Exported_active(skipIdx) = Exported(skipIdx);

for jIdx = 1:length(joinIdx)
    temp = string(split(BLOCKPATHs{joinIdx{jIdx}(1)}, '\'));
    DateStr = temp(end - 1);
    mkdir(fullfile(SAVEPATHs{joinIdx{jIdx}(1)}, DateStr));
    TDTDataset = [];
    
    for dIdx = 1:length(joinIdx{jIdx})
        TDTDataset{dIdx} = TDTbin2mat(BLOCKPATHs{joinIdx{jIdx}(dIdx)}, 'TYPE', {'epocs', 'streams'});
    end

    jointData = joinBlocks([], TDTDataset{:});
    trialAll = params.processFcn(jointData.epocs, params.choiceWin);

    ECOGDataset = jointData.streams.LAuC;
    ECOGDataset = ECOGResample(ECOGDataset, params.fd);
    ECOGDataset = ECOGFilter(ECOGDataset, params.fhp, params.flp, "Notch", "on");
    ECOGDataset.data = ECOGDataset.data(ECOGSitePatch("AC"), :);
    save(strcat(SAVEPATHs{joinIdx{jIdx}(dIdx)}, DateStr, "\", DateStr, "_AC.mat"), "ECOGDataset", "trialAll", "-mat", "-v7.3");
    
    ECOGDataset = jointData.streams.LPFC;
    ECOGDataset = ECOGResample(ECOGDataset, params.fd);
    ECOGDataset = ECOGFilter(ECOGDataset, params.fhp, params.flp, "Notch", "on");
    ECOGDataset.data = ECOGDataset.data(ECOGSitePatch("PFC"), :);
    save(strcat(SAVEPATHs{joinIdx{jIdx}(dIdx)}, DateStr, "\", DateStr, "_PFC.mat"), "ECOGDataset", "trialAll", "-mat", "-v7.3");
end

tb.Exported_active([joinIdx{:}]) = true;
writetable(tb, TBPATH);
