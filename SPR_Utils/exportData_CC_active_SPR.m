clear; clc; close all;

%% Block Freq Loc
disp("Exporting Block Freq-Loc active...");
SAVEPATH = "E:\ECOG\MAT Data\CC\BlkFreqLoc Active\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\chouchou\cc20220901\Block-1';
BLOCKPATH{2} = 'E:\ECoG\chouchou\cc20220903\Block-1';
BLOCKPATH{3} = 'E:\ECoG\chouchou\cc20220905\Block-1';
BLOCKPATH{4} = 'E:\ECoG\chouchou\cc20220907\Block-1';
BLOCKPATH{5} = 'E:\ECoG\chouchou\cc20220909\Block-1';
BLOCKPATH{6} = 'E:\ECoG\chouchou\cc20220914\Block-1';

params.choiceWin = [100, 600];
params.processFcn = @ActiveProcess_freqLoc;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

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