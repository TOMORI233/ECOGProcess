clear; clc; close all;

%% add_on, part1, reg vs irreg, no reg in irreg
disp("Exporting ClickTrainLongTerm add_on part 1, reg VS irreg ...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Add_on_Basic_ICI4\";
BLOCKPATH = [];
BLOCKPATH{1} = 'F:\ECoG\chouchou\cc20221015\Block-3'; % 20221017 export
BLOCKPATH{2} = 'G:\ECoG\chouchou\cc20221024\Block-1'; % 20221024 export
BLOCKPATH{3} = 'G:\ECoG\chouchou\cc20221025\Block-1'; % 20221025 export
BLOCKPATH{4} = 'G:\ECoG\chouchou\cc20221026\Block-1'; % 20221026 export
BLOCKPATH{5} = 'G:\ECoG\chouchou\cc20221027\Block-1'; % 20221027 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 5);

%% add_on, part2, tone 250_246, 250_240
disp("Exporting ClickTrainLongTerm add_on part 2, tone ...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Add_on_Basic_Tone\";
BLOCKPATH = [];
BLOCKPATH{1} = 'F:\ECoG\chouchou\cc20221015\Block-4'; % 20221017 export, 250_246_240
BLOCKPATH{2} = 'G:\ECoG\chouchou\cc20221021\Block-4'; % 20221021 export, 250_246_200
BLOCKPATH{3} = 'G:\ECoG\chouchou\cc20221024\Block-2'; % 20221024 export, 250_246_200
BLOCKPATH{4} = 'G:\ECoG\chouchou\cc20221025\Block-2'; % 20221025 export
BLOCKPATH{5} = 'G:\ECoG\chouchou\cc20221026\Block-2'; % 20221026 export
BLOCKPATH{6} = 'G:\ECoG\chouchou\cc20221027\Block-2'; % 20221026 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 6);

%% add_on, part3, norm_sqrt, base ICI = 4ms
disp("Exporting ClickTrainLongTerm add_on part 3, reg VS irreg, base ICI = 4 ...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Add_on_Basic_NormSqrt_ICI4\";
BLOCKPATH = [];
BLOCKPATH{1} = 'F:\ECoG\chouchou\cc20221017\Block-3'; % 20221017 export
BLOCKPATH{2} = 'G:\ECoG\chouchou\cc20221025\Block-3'; % 20221025 export
BLOCKPATH{3} = 'G:\ECoG\chouchou\cc20221026\Block-3'; % 20221026 export
BLOCKPATH{4} = 'G:\ECoG\chouchou\cc20221027\Block-3'; % 20221027 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 4);

%% add_on, part4, norm_sqrt, base ICI = 8ms
disp("Exporting ClickTrainLongTerm add_on part 4, reg VS irreg, base ICI = 8 ...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Add_on_Basic_NormSqrt_ICI8\";
BLOCKPATH = [];
BLOCKPATH{1} = 'F:\ECoG\chouchou\cc20221017\Block-4'; % 20221017 export
BLOCKPATH{2} = 'G:\ECoG\chouchou\cc20221025\Block-4'; % 20221025 export
BLOCKPATH{3} = 'G:\ECoG\chouchou\cc20221026\Block-4'; % 20221026 export
BLOCKPATH{4} = 'G:\ECoG\chouchou\cc20221027\Block-4'; % 20221027 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 4);

%% add_on, part5, duration 0.5,1,2,3,4,5
disp("Exporting ClickTrainLongTerm add_on part 5, duration 0.5,1,2,3,4,5 ...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Add_on_Basic_Duration_0o5_5\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\chouchou\cc20221020\Block-3'; % 20221020 export, errors in order txt
BLOCKPATH{2} = 'G:\ECoG\chouchou\cc20221021\Block-3'; % 20221021 export
BLOCKPATH{3} = 'G:\ECoG\chouchou\cc20221024\Block-3'; % 20221024 export
BLOCKPATH{4} = 'G:\ECoG\chouchou\cc20221025\Block-5'; % 20221025 export
BLOCKPATH{5} = 'G:\ECoG\chouchou\cc20221026\Block-5'; % 20221026 export
BLOCKPATH{6} = 'G:\ECoG\chouchou\cc20221027\Block-5'; % 20221027 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 6);

% %% add_on, part6, click train oscillation 500_250_125_60_30
% disp("Exporting ClickTrainLongTerm add_on part 6, click train oscillation 500_250_125_60_30 ...");
% SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Add_on_Basic_Oscillation_500_250_125_60_30\";
% BLOCKPATH = [];
% BLOCKPATH{1} = 'G:\ECoG\chouchou\cc20221022\Block-3'; % 20221024 export, do not have control 
% 
% params.processFcn = @PassiveProcess_clickTrainContinuous;
% exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

%% add_on, part6.2, click train oscillation 500_250_125_60_30_control
disp("Exporting ClickTrainLongTerm add_on part 6.2, click train oscillation 500_250_125_60_30 ...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Add_on_Basic_Oscillation_control_500_250_125_60_30\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\chouchou\cc20221024\Block-4'; % 20221024 export
BLOCKPATH{2} = 'G:\ECoG\chouchou\cc20221025\Block-6'; % 20221025 export
BLOCKPATH{3} = 'G:\ECoG\chouchou\cc20221026\Block-6'; % 20221026 export
BLOCKPATH{4} = 'G:\ECoG\chouchou\cc20221027\Block-6'; % 20221027 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 4);

%% add_on, part7, click train oscillation Tone 250_200_5000_4000
disp("Exporting ClickTrainLongTerm add_on part 7, click train oscillation Tone 250_200_5000_4000 ...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Add_on_Basic_Oscillation_Tone_250_5000\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\chouchou\cc20221024\Block-5'; % 20221024 export
BLOCKPATH{2} = 'G:\ECoG\chouchou\cc20221025\Block-7'; % 20221025 export
BLOCKPATH{3} = 'G:\ECoG\chouchou\cc20221026\Block-7'; % 20221026 export
BLOCKPATH{4} = 'G:\ECoG\chouchou\cc20221027\Block-7'; % 20221027 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 4);

%% add_on, part8, click train variance 50_2
disp("Exporting ClickTrainLongTerm add_on part 9, click train variance 50_2 ...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Add_on_Basic_Var_50_2\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\chouchou\cc20221024\Block-7'; % 20221024 export
BLOCKPATH{2} = 'G:\ECoG\chouchou\cc20221025\Block-8'; % 20221025 export
BLOCKPATH{3} = 'G:\ECoG\chouchou\cc20221026\Block-8'; % 20221026 export
BLOCKPATH{4} = 'G:\ECoG\chouchou\cc20221027\Block-8'; % 20221027 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 4);

%% add_on, part9, click train variance 400_50
disp("Exporting ClickTrainLongTerm add_on part 8, click train variance 400_50 ...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Add_on_Basic_Var_400_50\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\chouchou\cc20221024\Block-6'; % 20221024 export
BLOCKPATH{2} = 'G:\ECoG\chouchou\cc20221025\Block-9'; % 20221025 export
BLOCKPATH{3} = 'G:\ECoG\chouchou\cc20221026\Block-9'; % 20221026 export
BLOCKPATH{4} = 'G:\ECoG\chouchou\cc20221027\Block-9'; % 20221027 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 4);


%% duration 1s 2s 3s 4s 5s-1sm 4.06-4
disp("Exporting ClickTrainLongTerm duration...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Duration1-5s_1s_4o06_4\";
BLOCKPATH = [];
BLOCKPATH{1} = 'F:\ECoG\chouchou\cc20221012\Block-3'; % 20221012 export
BLOCKPATH{2} = 'F:\ECoG\chouchou\cc20221013\Block-3'; % 20221013 export
BLOCKPATH{3} = 'F:\ECoG\chouchou\cc20221014\Block-3'; % 20221016 export
params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 3);

%% duration 1s 2s 3s 4s 5s-1sm 4.06-4
disp("Exporting ClickTrainLongTerm duration...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Duration1-5s_1s_4_4o06\";
BLOCKPATH = [];
BLOCKPATH{1} = 'F:\ECoG\chouchou\cc20221012\Block-4'; % 20221012 export
BLOCKPATH{2} = 'F:\ECoG\chouchou\cc20221013\Block-4'; % 20221013 export
BLOCKPATH{3} = 'F:\ECoG\chouchou\cc20221014\Block-4'; % 20221016 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 3);


%% successive tone 250-246,240,200
disp("Exporting ClickTrainLongTerm successive...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Successive_Tone_250-246_240_200\";
BLOCKPATH = [];
BLOCKPATH{1} = 'F:\ECoG\chouchou\cc20221011\Block-5'; % 20221011 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);


%% clickTrainLongTerm successive 0.025_0.05
disp("Exporting ClickTrainLongTerm successive...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Successive_0o025_0o05\";
BLOCKPATH = [];
BLOCKPATH{1} = 'F:\ECoG\chouchou\cc20221011\Block-4'; % 20221011 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

%% clickTrainLongTerm successive 0.1_0.2
disp("Exporting ClickTrainLongTerm successive...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Successive_0o1_0o2\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\chouchou\cc20220927\Block-3';
BLOCKPATH{2} = 'E:\ECoG\chouchou\cc20220928\Block-5';
BLOCKPATH{3} = 'E:\ECoG\chouchou\cc20221004\Block-3'; % 20221011 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

%% clickTrainLongTerm successive 0.3_0.5
disp("Exporting ClickTrainLongTerm successive...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Successive_0o3_0o5\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\chouchou\cc20220927\Block-4';
BLOCKPATH{2} = 'E:\ECoG\chouchou\cc20220928\Block-6';
BLOCKPATH{3} = 'E:\ECoG\chouchou\cc20220930\Block-6';
BLOCKPATH{4} = 'E:\ECoG\chouchou\cc20221004\Block-4'; % 20221007 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, 1);

%% clickTrainLongTerm successive 1_2
disp("Exporting ClickTrainLongTerm successive...");
SAVEPATH = "E:\ECOG\MAT Data\CC\ClickTrainLongTerm\Successive_1_2\";
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