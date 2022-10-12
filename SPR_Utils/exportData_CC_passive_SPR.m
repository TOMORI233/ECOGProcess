clear; clc; close all;



%% successive tone 250-246,240,200
disp("Exporting ClickTrainLongTerm successive...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\successive_Tone_250-246_240_200\";
BLOCKPATH = [];
BLOCKPATH{1} = 'F:\ECoG\chouchou\cc20221011\Block-5'; % 20221011 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);


%% clickTrainLongTerm successive 0.025_0.05
disp("Exporting ClickTrainLongTerm successive...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\successive_0o025_0o05\";
BLOCKPATH = [];
BLOCKPATH{1} = 'F:\ECoG\chouchou\cc20221011\Block-4'; % 20221011 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

%% clickTrainLongTerm successive 0.1_0.2
disp("Exporting ClickTrainLongTerm successive...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\successive_0o1_0o2\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\chouchou\cc20220927\Block-3';
BLOCKPATH{2} = 'E:\ECoG\chouchou\cc20220928\Block-5';
BLOCKPATH{3} = 'E:\ECoG\chouchou\cc20221004\Block-3'; % 20221011 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

%% clickTrainLongTerm successive 0.3_0.5
disp("Exporting ClickTrainLongTerm successive...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\successive_0o3_0o5\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\chouchou\cc20220927\Block-4';
BLOCKPATH{2} = 'E:\ECoG\chouchou\cc20220928\Block-6';
BLOCKPATH{3} = 'E:\ECoG\chouchou\cc20220930\Block-6';
BLOCKPATH{4} = 'E:\ECoG\chouchou\cc20221004\Block-4'; % 20221007 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

%% clickTrainLongTerm successive 1_2
disp("Exporting ClickTrainLongTerm successive...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\successive_1_2\";
BLOCKPATH = [];

BLOCKPATH{1} = 'E:\ECoG\chouchou\cc20221005\Block-8'; 
BLOCKPATH{2} = 'E:\ECoG\chouchou\cc20221006\Block-1'; % 20221007 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

%% clickTrainLongTerm Basic 4-4.06
disp("Exporting ClickTrainLongTerm Basic 4-4.06...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Basic_ICI4\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\chouchou\cc20220610\Block-3';
BLOCKPATH{2} = 'E:\ECoG\chouchou\cc20220616\Block-5';
BLOCKPATH{3} = 'E:\ECoG\chouchou\cc20220619\Block-3';
BLOCKPATH{4} = 'E:\ECoG\chouchou\cc20220625\Block-2';
BLOCKPATH{5} = 'E:\ECoG\chouchou\cc20220630\Block-3';
BLOCKPATH{6} = 'E:\ECoG\chouchou\cc20220705\Block-3';
BLOCKPATH{7} = 'E:\ECoG\chouchou\cc20220713\Block-1';
BLOCKPATH{8} = 'E:\ECoG\chouchou\cc20220721\Block-1';
BLOCKPATH{9} = 'E:\ECoG\chouchou\cc20220724\Block-1'; % 20221007 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

%% clickTrainLongTerm Basic 8-8.12
disp("Exporting ClickTrainLongTerm Basic 8-8.12...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Basic_ICI8\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\chouchou\cc20220610\Block-4';
BLOCKPATH{2} = 'E:\ECoG\chouchou\cc20220616\Block-6';
BLOCKPATH{3} = 'E:\ECoG\chouchou\cc20220619\Block-4';
BLOCKPATH{4} = 'E:\ECoG\chouchou\cc20220625\Block-3';
BLOCKPATH{5} = 'E:\ECoG\chouchou\cc20220630\Block-4';
BLOCKPATH{6} = 'E:\ECoG\chouchou\cc20220705\Block-4';
BLOCKPATH{7} = 'E:\ECoG\chouchou\cc20220713\Block-2';
BLOCKPATH{8} = 'E:\ECoG\chouchou\cc20220721\Block-2';
BLOCKPATH{9} = 'E:\ECoG\chouchou\cc20220724\Block-2'; % 20221007 export


params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);


%% clickTrainLongTerm Basic 20-20.3
disp("Exporting ClickTrainLongTerm Basic 20-20.3...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Basic_ICI20\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\chouchou\cc20220610\Block-5';
BLOCKPATH{2} = 'E:\ECoG\chouchou\cc20220616\Block-7';
BLOCKPATH{3} = 'E:\ECoG\chouchou\cc20220619\Block-5';
BLOCKPATH{4} = 'E:\ECoG\chouchou\cc20220625\Block-4';
BLOCKPATH{5} = 'E:\ECoG\chouchou\cc20220630\Block-5';
BLOCKPATH{6} = 'E:\ECoG\chouchou\cc20220705\Block-5';
BLOCKPATH{7} = 'E:\ECoG\chouchou\cc20220714\Block-4';
BLOCKPATH{8} = 'E:\ECoG\chouchou\cc20220721\Block-3';
BLOCKPATH{9} = 'E:\ECoG\chouchou\cc20220724\Block-4'; % 20221007 export


params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

%% clickTrainLongTerm Basic 40-40.6
disp("Exporting ClickTrainLongTerm Basic 40-40.6...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Basic_ICI40\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\chouchou\cc20220610\Block-6';
BLOCKPATH{2} = 'E:\ECoG\chouchou\cc20220616\Block-8';
BLOCKPATH{3} = 'E:\ECoG\chouchou\cc20220619\Block-6';
BLOCKPATH{4} = 'E:\ECoG\chouchou\cc20220625\Block-5';
BLOCKPATH{5} = 'E:\ECoG\chouchou\cc20220630\Block-6';
BLOCKPATH{6} = 'E:\ECoG\chouchou\cc20220705\Block-6';
BLOCKPATH{7} = 'E:\ECoG\chouchou\cc20220714\Block-5';
BLOCKPATH{8} = 'E:\ECoG\chouchou\cc20220721\Block-5';
BLOCKPATH{9} = 'E:\ECoG\chouchou\cc20220724\Block-5'; % 20221007 export


params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

%% clickTrainLongTerm Basic 80-81.2
disp("Exporting ClickTrainLongTerm Basic 80-81.2...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Basic_ICI80\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\chouchou\cc20220610\Block-7';
BLOCKPATH{2} = 'E:\ECoG\chouchou\cc20220616\Block-9';
BLOCKPATH{3} = 'E:\ECoG\chouchou\cc20220619\Block-7';
BLOCKPATH{4} = 'E:\ECoG\chouchou\cc20220625\Block-6';
BLOCKPATH{5} = 'E:\ECoG\chouchou\cc20220630\Block-7';
BLOCKPATH{6} = 'E:\ECoG\chouchou\cc20220705\Block-7';
BLOCKPATH{7} = 'E:\ECoG\chouchou\cc20220714\Block-6';
BLOCKPATH{8} = 'E:\ECoG\chouchou\cc20220721\Block-6';
BLOCKPATH{9} = 'E:\ECoG\chouchou\cc20220724\Block-6'; % 20221007 export


params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

%% clickTrainLongTerm Basic ICI Threshold
disp("Exporting ClickTrainLongTerm Basic ICI Threshold...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Basic_ICIThr\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\chouchou\cc20220518\Block-3';
BLOCKPATH{2} = 'E:\ECoG\chouchou\cc20220702\Block-3';
BLOCKPATH{3} = 'E:\ECoG\chouchou\cc20220704\Block-3';
BLOCKPATH{4} = 'E:\ECoG\chouchou\cc20220706\Block-3';
BLOCKPATH{5} = 'E:\ECoG\chouchou\cc20220712\Block-5';
BLOCKPATH{6} = 'E:\ECoG\chouchou\cc20220714\Block-1';
BLOCKPATH{7} = 'E:\ECoG\chouchou\cc20220720\Block-1';
BLOCKPATH{8} = 'E:\ECoG\chouchou\cc20220722\Block-2'; % 20221007 export


params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

%% clickTrainLongTerm Basic IrregVar
disp("Exporting ClickTrainLongTerm Basic IrregVar...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Basic_IrregVar\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\chouchou\cc20220519\Block-6';
BLOCKPATH{2} = 'E:\ECoG\chouchou\cc20220702\Block-5';
BLOCKPATH{3} = 'E:\ECoG\chouchou\cc20220704\Block-5';
BLOCKPATH{4} = 'E:\ECoG\chouchou\cc20220706\Block-5';
BLOCKPATH{5} = 'E:\ECoG\chouchou\cc20220712\Block-2';
BLOCKPATH{6} = 'E:\ECoG\chouchou\cc20220714\Block-2';
BLOCKPATH{7} = 'E:\ECoG\chouchou\cc20220720\Block-2';
BLOCKPATH{8} = 'E:\ECoG\chouchou\cc20220722\Block-4'; % 20221007 export


params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

%% clickTrainLongTerm Basic Insert
disp("Exporting ClickTrainLongTerm Basic Insert...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Basic_Insert\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\chouchou\cc20220702\Block-4';
BLOCKPATH{2} = 'E:\ECoG\chouchou\cc20220706\Block-4';
BLOCKPATH{3} = 'E:\ECoG\chouchou\cc20220712\Block-3';
BLOCKPATH{4} = 'E:\ECoG\chouchou\cc20220714\Block-3';
BLOCKPATH{5} = 'E:\ECoG\chouchou\cc20220720\Block-3';

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);



%% clickTrainLongTerm Basic Norm Sqrt
disp("Exporting ClickTrainLongTerm Basic Norm Sqrt...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Basic_NormSqrt\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\chouchou\cc20220827\Block-1';


params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

%% clickTrainLongTerm Species ICIBind248204080Ratio1o1
disp("Exporting ClickTrainLongTerm Species ICIBind248204080Ratio1o1...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Species_ICIBind248204080Ratio1o1\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\chouchou\cc20220830\Block-7';
BLOCKPATH{2} = 'E:\ECoG\chouchou\cc20220831\Block-6';
BLOCKPATH{3} = 'E:\ECoG\chouchou\cc20220901\Block-6';
BLOCKPATH{4} = 'E:\ECoG\chouchou\cc20220902\Block-6';
BLOCKPATH{5} = 'E:\ECoG\chouchou\cc20220903\Block-5';
BLOCKPATH{6} = 'E:\ECoG\chouchou\cc20220905\Block-5';
BLOCKPATH{7} = 'E:\ECoG\chouchou\cc20220906\Block-5';


params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);


%% clickTrainLongTerm Species RatioDetect4o1o2o3o4
disp("Exporting ClickTrainLongTerm Species RatioDetect4o1o2o3o4...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Species_RatioDetect4o1o2o3o4\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\chouchou\cc20220830\Block-5';
BLOCKPATH{2} = 'E:\ECoG\chouchou\cc20220831\Block-4';
BLOCKPATH{3} = 'E:\ECoG\chouchou\cc20220901\Block-4';
BLOCKPATH{4} = 'E:\ECoG\chouchou\cc20220902\Block-5';
BLOCKPATH{5} = 'E:\ECoG\chouchou\cc20220903\Block-4';
BLOCKPATH{6} = 'E:\ECoG\chouchou\cc20220905\Block-4';
BLOCKPATH{7} = 'E:\ECoG\chouchou\cc20220906\Block-4';


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