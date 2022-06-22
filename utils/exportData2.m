clear; clc; close all;

%% 7-10Freq active
disp("Exporting 7-10Freq active...");
SAVEPATH = "E:\ECoG\MAT Data\CC\7-10Freq Active\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\TDT Data\chouchou\cc20220517\Block-8';
BLOCKPATH{2} = 'E:\ECoG\TDT Data\chouchou\cc20220518\Block-1';
BLOCKPATH{3} = 'E:\ECoG\TDT Data\chouchou\cc20220519\Block-3';
BLOCKPATH{4} = 'E:\ECoG\TDT Data\chouchou\cc20220520\Block-1';
BLOCKPATH{5} = 'E:\ECoG\TDT Data\chouchou\cc20220525\Block-1';
BLOCKPATH{6} = 'E:\ECoG\TDT Data\chouchou\cc20220530\Block-1';
params.choiceWin = [100, 600];
params.processFcn = @ActiveProcess_7_10Freq;
exportDataFcn(BLOCKPATH, SAVEPATH, params);

%% 1-9Freq active
disp("Exporting 1-9Freq active...");
SAVEPATH = "E:\ECoG\MAT Data\CC\1-9Freq Active\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\TDT Data\chouchou\cc20220523\Block-1';
BLOCKPATH{2} = 'E:\ECoG\TDT Data\chouchou\cc20220524\Block-1';
BLOCKPATH{3} = 'E:\ECoG\TDT Data\chouchou\cc20220601\Block-1';
BLOCKPATH{4} = 'E:\ECoG\TDT Data\chouchou\cc20220605\Block-1';
BLOCKPATH{5} = 'E:\ECoG\TDT Data\chouchou\cc20220609\Block-3';
BLOCKPATH{6} = 'E:\ECoG\TDT Data\chouchou\cc20220613\Block-4';
params.choiceWin = [100, 800];
params.processFcn = @ActiveProcess_1_9Freq;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 6);

%% LTST active
disp("Exporting LTST active...");
SAVEPATH = "E:\ECoG\MAT Data\CC\LTST Active\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\TDT Data\chouchou\cc20220521\Block-1';
BLOCKPATH{2} = 'E:\ECoG\TDT Data\chouchou\cc20220531\Block-3';
BLOCKPATH{3} = 'E:\ECoG\TDT Data\chouchou\cc20220606\Block-4';
BLOCKPATH{4} = 'E:\ECoG\TDT Data\chouchou\cc20220608\Block-1';
BLOCKPATH{5} = 'E:\ECoG\TDT Data\chouchou\cc20220610\Block-1';
params.choiceWin = [100, 800];
params.processFcn = @ActiveProcess_LTST;
exportDataFcn(BLOCKPATH, SAVEPATH, params);

%% What-When active
disp("Exporting What-When active...");
SAVEPATH = "E:\ECoG\MAT Data\CC\WhatWhen Active\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\TDT Data\chouchou\cc20220612\Block-1';
BLOCKPATH{2} = 'E:\ECoG\TDT Data\chouchou\cc20220614\Block-1';
BLOCKPATH{3} = 'E:\ECoG\TDT Data\chouchou\cc20220616\Block-2';
BLOCKPATH{4} = 'E:\ECoG\TDT Data\chouchou\cc20220617\Block-3';
BLOCKPATH{5} = 'E:\ECoG\TDT Data\chouchou\cc20220619\Block-1';
BLOCKPATH{6} = 'E:\ECoG\TDT Data\chouchou\cc20220620\Block-1';
params.choiceWin = [100, 800];
params.processFcn = @ActiveProcess_WhatWhen;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 5);

%% Fcn
function exportDataFcn(BLOCKPATH, SAVEPATH, params, startIdx, endIdx)
    narginchk(3, 5);

    if nargin < 4
        startIdx = 1;
    end

    if nargin < 5
        endIdx = length(BLOCKPATH);
    end

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
        disp("Saving...");
        save(strcat(SAVEPATH, DateStr, "\", DateStr, "_", AREANAME(params.posIndex), ".mat"), "ECOGDataset", "trialAll", "-mat", "-v7.3");
        toc
        
        % PFC
        disp("Loading PFC Data...");
        params.posIndex = 2;
        tic
        [~, ECOGDataset] = ECOGPreprocess(BLOCKPATH{index}, params);
        disp("Saving...");
        save(strcat(SAVEPATH, DateStr, "\", DateStr, "_", AREANAME(params.posIndex), ".mat"), "ECOGDataset", "trialAll", "-mat", "-v7.3");
        toc
    end

end