clear; clc; close all;

%% 7-10Freq active
disp("Exporting 7-10Freq active...");
SAVEPATH = "D:\Education\Lab\Projects\ECOG\MAT Data\XX\7-10Freq Active\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\TDT Data\xiaoxiao\xx20220627\Block-1';
BLOCKPATH{2} = 'E:\ECoG\TDT Data\xiaoxiao\xx20220706\Block-1';
BLOCKPATH{3} = 'E:\ECoG\TDT Data\xiaoxiao\xx20220711\Block-1';
BLOCKPATH{4} = 'E:\ECoG\TDT Data\xiaoxiao\xx20220715\Block-2';
BLOCKPATH{5} = 'E:\ECoG\TDT Data\xiaoxiao\xx20220720\Block-1';
BLOCKPATH{6} = 'E:\ECoG\TDT Data\xiaoxiao\xx20220808\Block-2';
BLOCKPATH{7} = 'E:\ECoG\TDT Data\xiaoxiao\xx20220812\Block-1';
BLOCKPATH{8} = 'E:\ECoG\TDT Data\xiaoxiao\xx20220820\Block-1';
BLOCKPATH{9} = 'E:\ECoG\TDT Data\xiaoxiao\xx20220822\Block-1';
BLOCKPATH{10} = 'E:\ECoG\TDT Data\xiaoxiao\xx20220913\Block-1';
BLOCKPATH{11} = 'E:\ECoG\TDT Data\xiaoxiao\xx20220914\Block-1';
BLOCKPATH{12} = 'E:\ECoG\TDT Data\xiaoxiao\xx20220917\Block-1';
params.choiceWin = [100, 600];
params.processFcn = @ActiveProcess_7_10Freq;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 10);

%% 1-9Freq active
disp("Exporting 1-9Freq active...");
SAVEPATH = "D:\Education\Lab\Projects\ECOG\MAT Data\XX\1-9Freq Active\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\TDT Data\xiaoxiao\xx20220628\Block-3';
BLOCKPATH{2} = 'E:\ECoG\TDT Data\xiaoxiao\xx20220707\Block-1';
BLOCKPATH{3} = 'E:\ECoG\TDT Data\xiaoxiao\xx20220712\Block-1';
BLOCKPATH{4} = 'E:\ECoG\TDT Data\xiaoxiao\xx20220716\Block-1';
BLOCKPATH{5} = 'E:\ECoG\TDT Data\xiaoxiao\xx20220721\Block-1';
BLOCKPATH{6} = 'E:\ECoG\TDT Data\xiaoxiao\xx20220726\Block-3';
params.choiceWin = [100, 800];
params.processFcn = @ActiveProcess_1_9Freq;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 6);

%% LTST active
disp("Exporting LTST active...");
SAVEPATH = "D:\Education\Lab\Projects\ECOG\MAT Data\XX\LTST Active\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\TDT Data\chouchou\cc20220521\Block-1';
BLOCKPATH{2} = 'E:\ECoG\TDT Data\chouchou\cc20220531\Block-3';
BLOCKPATH{3} = 'E:\ECoG\TDT Data\chouchou\cc20220608\Block-1';
BLOCKPATH{4} = 'E:\ECoG\TDT Data\chouchou\cc20220610\Block-1';
params.choiceWin = [100, 800];
params.processFcn = @ActiveProcess_LTST;
exportDataFcn(BLOCKPATH, SAVEPATH, params);

%% What-When active
disp("Exporting What-When active...");
SAVEPATH = "D:\Education\Lab\Projects\ECOG\MAT Data\CC\WhatWhen Active\";
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