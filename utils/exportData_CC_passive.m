clear; clc; close all;

%% 7-10Freq passive
disp("Exporting 7-10Freq passive...");
SAVEPATH = "D:\Education\Lab\Projects\ECOG\MAT Data\CC\7-10Freq Passive\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\TDT Data\chouchou\cc20220520\Block-2';
BLOCKPATH{2} = 'E:\ECoG\TDT Data\chouchou\cc20220702\Block-2';
BLOCKPATH{3} = 'E:\ECoG\TDT Data\chouchou\cc20220706\Block-2';
BLOCKPATH{4} = 'E:\ECoG\TDT Data\chouchou\cc20220706\Block-3';
BLOCKPATH{5} = 'E:\ECoG\TDT Data\chouchou\cc20220801\Block-2';
BLOCKPATH{6} = 'E:\ECoG\TDT Data\chouchou\cc20220814\Block-2';
BLOCKPATH{7} = 'E:\ECoG\TDT Data\chouchou\cc20220908\Block-2';
params.choiceWin = [100, 600];
params.processFcn = @PassiveProcess_7_10Freq;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1, 1);

%% 1-9Freq active
disp("Exporting 1-9Freq passive...");
SAVEPATH = "D:\Education\Lab\Projects\ECOG\MAT Data\CC\1-9Freq Passive\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\TDT Data\chouchou\cc20220601\Block-1';
params.choiceWin = [100, 800];
params.processFcn = @PassiveProcess_1_9Freq;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 7);

%% Fcn
function exportDataFcn(BLOCKPATH, SAVEPATH, params, startIdx, endIdx)
    narginchk(3, 5);

    if nargin < 4
        startIdx = 1;
    end

    if nargin < 5
        endIdx = length(BLOCKPATH);
    end

    fd = 500; % Hz

    for index = startIdx:endIdx
        AREANAME = ["AC", "PFC"];
        temp = string(split(BLOCKPATH{index}, '\'));
        DateStr = temp(end - 1);
        mkdir(fullfile(SAVEPATH, DateStr));
        
        % AC
        disp("Loading AC Data...");
        params.posIndex = 1;
        tic
        [trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH{index}, params);
        ECOGDataset = ECOGDownsample(ECOGDataset, fd);
        ECOGDataset = ECOGFilter(ECOGDataset);
        disp("Saving...");
        save(strcat(SAVEPATH, DateStr, "\", DateStr, "_", AREANAME(params.posIndex), ".mat"), "ECOGDataset", "trialAll", "-mat", "-v7.3");
        toc
        
        % PFC
        disp("Loading PFC Data...");
        params.posIndex = 2;
        tic
        [~, ECOGDataset] = ECOGPreprocess(BLOCKPATH{index}, params);
        ECOGDataset = ECOGDownsample(ECOGDataset, fd);
        ECOGDataset = ECOGFilter(ECOGDataset);
        disp("Saving...");
        save(strcat(SAVEPATH, DateStr, "\", DateStr, "_", AREANAME(params.posIndex), ".mat"), "ECOGDataset", "trialAll", "-mat", "-v7.3");
        toc
    end

end