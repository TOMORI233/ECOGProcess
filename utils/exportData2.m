clear; clc; close all;

% 7-10Freq active
% SAVEPATH = "E:\ECoG\MAT Data\CC\7-10Freq Active\";
% BLOCKPATH{1} = 'E:\ECoG\TDT Data\chouchou\cc20220517\Block-8';
% BLOCKPATH{2} = 'E:\ECoG\TDT Data\chouchou\cc20220518\Block-1';
% BLOCKPATH{3} = 'E:\ECoG\TDT Data\chouchou\cc20220519\Block-3';
% BLOCKPATH{4} = 'E:\ECoG\TDT Data\chouchou\cc20220520\Block-1';
% BLOCKPATH{5} = 'E:\ECoG\TDT Data\chouchou\cc20220525\Block-1';
% BLOCKPATH{6} = 'E:\ECoG\TDT Data\chouchou\cc20220530\Block-1';
% params.choiceWin = [0, 600];
% params.processFcn = @ActiveProcess_7_10Freq;

% 1-9Freq active
% SAVEPATH = "E:\ECoG\MAT Data\CC\1-9Freq Active\";
% BLOCKPATH{1} = 'E:\ECoG\TDT Data\chouchou\cc20220523\Block-1';
% BLOCKPATH{2} = 'E:\ECoG\TDT Data\chouchou\cc20220524\Block-1';
% BLOCKPATH{3} = 'E:\ECoG\TDT Data\chouchou\cc20220601\Block-1';
% params.choiceWin = [0, 600];
% params.processFcn = @ActiveProcess_1_9Freq;

% LTST active
SAVEPATH = "E:\ECoG\MAT Data\CC\LTST Active\";
BLOCKPATH{1} = 'E:\ECoG\TDT Data\chouchou\cc20220521\Block-1';
BLOCKPATH{2} = 'E:\ECoG\TDT Data\chouchou\cc20220531\Block-3';
params.choiceWin = [0, 600];
params.processFcn = @ActiveProcess_LTST;

for index = 1:length(BLOCKPATH)
    AREANAME = ["AC", "PFC"];
    temp = string(split(BLOCKPATH{index}, '\'));
    DateStr = temp(end - 1);
    mkdir(fullfile(SAVEPATH, DateStr));
    
    % AC
    disp("Loading AC Data...");
    params.posIndex = 1;
    tic
    [trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH{index}, params);
    save(strcat(SAVEPATH, DateStr, "\", DateStr, "_", AREANAME(params.posIndex), ".mat"), "ECOGDataset", "trialAll", "-mat", "-v7.3");
    toc
    
    % PFC
    disp("Loading PFC Data...");
    params.posIndex = 2;
    tic
    [~, ECOGDataset] = ECOGPreprocess(BLOCKPATH{index}, params);
    save(strcat(SAVEPATH, DateStr, "\", DateStr, "_", AREANAME(params.posIndex), ".mat"), "ECOGDataset", "trialAll", "-mat", "-v7.3");
    toc
end