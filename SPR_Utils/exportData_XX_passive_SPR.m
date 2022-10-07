clear; clc; close all;

% %% clickTrainLongTerm successive 0.1_0.2
% disp("Exporting ClickTrainLongTerm successive...");
% SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\successive\0o1_0o2\";
% BLOCKPATH = [];
% BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220927\Block-3';
% BLOCKPATH{2} = 'E:\ECoG\xiaoxiao\xx20220929\Block-3';
% BLOCKPATH{3} = 'E:\ECoG\xiaoxiao\xx20220930\Block-3';
% 
% 
% params.processFcn = @PassiveProcess_clickTrainContinuous;
% exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);
% 
% %% clickTrainLongTerm successive 0.3_0.5
% disp("Exporting ClickTrainLongTerm successive...");
% SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\successive\0o3_0o5\";
% BLOCKPATH = [];
% BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220927\Block-4';
% BLOCKPATH{2} = 'E:\ECoG\xiaoxiao\xx20220929\Block-4';
% 
% 
% params.processFcn = @PassiveProcess_clickTrainContinuous;
% exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

%% clickTrainLongTerm Base 4-4.06
disp("Exporting ClickTrainLongTerm Base 4-4.06...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Base_ICI4\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220623\Block-3';
BLOCKPATH{2} = 'E:\ECoG\xiaoxiao\xx20220624\Block-2';
BLOCKPATH{3} = 'E:\ECoG\xiaoxiao\xx20220625\Block-2';
BLOCKPATH{4} = 'E:\ECoG\xiaoxiao\xx20220626\Block-1';
BLOCKPATH{5} = 'E:\ECoG\xiaoxiao\xx20220711\Block-3';
BLOCKPATH{6} = 'E:\ECoG\xiaoxiao\xx20220715\Block-3';
BLOCKPATH{7} = 'E:\ECoG\xiaoxiao\xx20220725\Block-3';


params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

%% clickTrainLongTerm Base 8-8.12
disp("Exporting ClickTrainLongTerm Base 8-8.12...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Base_ICI8\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220623\Block-4';
BLOCKPATH{2} = 'E:\ECoG\xiaoxiao\xx20220624\Block-3';
BLOCKPATH{3} = 'E:\ECoG\xiaoxiao\xx20220625\Block-3';
BLOCKPATH{4} = 'E:\ECoG\xiaoxiao\xx20220626\Block-2';
BLOCKPATH{5} = 'E:\ECoG\xiaoxiao\xx20220711\Block-4';
BLOCKPATH{6} = 'E:\ECoG\xiaoxiao\xx20220715\Block-4';
BLOCKPATH{7} = 'E:\ECoG\xiaoxiao\xx20220725\Block-4';



params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);


%% clickTrainLongTerm Base 20-20.3
disp("Exporting ClickTrainLongTerm Base 20-20.3...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Base_ICI20\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220623\Block-5';
BLOCKPATH{2} = 'E:\ECoG\xiaoxiao\xx20220624\Block-4';
BLOCKPATH{3} = 'E:\ECoG\xiaoxiao\xx20220625\Block-4';
BLOCKPATH{4} = 'E:\ECoG\xiaoxiao\xx20220626\Block-3';
BLOCKPATH{5} = 'E:\ECoG\xiaoxiao\xx20220711\Block-5';
BLOCKPATH{6} = 'E:\ECoG\xiaoxiao\xx20220715\Block-5';
BLOCKPATH{7} = 'E:\ECoG\xiaoxiao\xx20220725\Block-5';


params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

%% clickTrainLongTerm Base 40-40.6
disp("Exporting ClickTrainLongTerm Base 40-40.6...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Base_ICI40\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220623\Block-6';
BLOCKPATH{2} = 'E:\ECoG\xiaoxiao\xx20220624\Block-5';
BLOCKPATH{3} = 'E:\ECoG\xiaoxiao\xx20220625\Block-5';
BLOCKPATH{4} = 'E:\ECoG\xiaoxiao\xx20220626\Block-4';
BLOCKPATH{5} = 'E:\ECoG\xiaoxiao\xx20220711\Block-6';
BLOCKPATH{6} = 'E:\ECoG\xiaoxiao\xx20220716\Block-4';
BLOCKPATH{7} = 'E:\ECoG\xiaoxiao\xx20220720\Block-2';



params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

%% clickTrainLongTerm Base 80-81.2
disp("Exporting ClickTrainLongTerm Base 80-81.2...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Base_ICI80\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220623\Block-7';
BLOCKPATH{2} = 'E:\ECoG\xiaoxiao\xx20220624\Block-6';
BLOCKPATH{3} = 'E:\ECoG\xiaoxiao\xx20220625\Block-6';
BLOCKPATH{4} = 'E:\ECoG\xiaoxiao\xx20220626\Block-5';
BLOCKPATH{5} = 'E:\ECoG\xiaoxiao\xx20220711\Block-7';
BLOCKPATH{6} = 'E:\ECoG\xiaoxiao\xx20220716\Block-5';
BLOCKPATH{7} = 'E:\ECoG\xiaoxiao\xx20220720\Block-3';


params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

%% clickTrainLongTerm Base ICI Threshold
disp("Exporting ClickTrainLongTerm ICI Threshold...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Base_ICIThr\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220518\Block-3';
BLOCKPATH{2} = 'E:\ECoG\xiaoxiao\xx20220702\Block-3';


params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

%% clickTrainLongTerm Base IrregVar
disp("Exporting ClickTrainLongTerm Base IrregVar...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Base_IrregVar\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220519\Block-6';
BLOCKPATH{2} = 'E:\ECoG\xiaoxiao\xx20220702\Block-5';
BLOCKPATH{3} = 'E:\ECoG\xiaoxiao\xx20220704\Block-5';
BLOCKPATH{4} = 'E:\ECoG\xiaoxiao\xx20220706\Block-5';
BLOCKPATH{5} = 'E:\ECoG\xiaoxiao\xx20220712\Block-2';
BLOCKPATH{6} = 'E:\ECoG\xiaoxiao\xx20220714\Block-2';
BLOCKPATH{7} = 'E:\ECoG\xiaoxiao\xx20220720\Block-2';
BLOCKPATH{8} = 'E:\ECoG\xiaoxiao\xx20220722\Block-4';


params.processFcn = @PassiveProcess_clickTrainContinuous;
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