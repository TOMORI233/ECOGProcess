clear; clc; close all;
fd = 600;
%% Anesthesia: awake
disp("Exporting Anesthesia: awake...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TB\TB_Anesthesia_Osci_Awake\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECOG\xiaoxiao\xx20230531\Block-2'; % 20230531 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
params.patch = "matchIssue";
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% Anesthesia: 20mg/kg/h
disp("Anesthesia: 20mg/kg/h...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TB\TB_Anesthesia_Osci_Rate_20\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECOG\xiaoxiao\xx20230531\Block-5'; % 20230531 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
params.patch = "matchIssue";
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% Anesthesia: 40mg/kg/h
disp("Anesthesia: 40mg/kg/h...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TB\TB_Anesthesia_Osci_Rate_40\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECOG\xiaoxiao\xx20230531\Block-9'; % 20230531 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
params.patch = "matchIssue";
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% Annoying TB Base ICI, 12, 16
disp("Exporting Annoying TB Base ICI, 12, 16...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TB\Add_on_Annoying_BaseICI_12_16\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECOG\xiaoxiao\xx20230504\Block-3'; % 20230504 export
BLOCKPATH{2} = 'G:\ECOG\xiaoxiao\xx20230504\Block-6'; % 20230504 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
params.patch = "matchIssue";
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% Reword TB Base ICI, 12, 16
disp("Exporting Reword TB Base ICI, 12, 16...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TB\Add_on_Reword_BaseICI_12_16\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECOG\xiaoxiao\xx20230504\Block-4'; % 20230504 export
BLOCKPATH{2} = 'G:\ECOG\xiaoxiao\xx20230504\Block-7'; % 20230504 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
params.patch = "matchIssue";
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% Control TB Base ICI, 12, 16
disp("Exporting Control TB Base ICI, 12, 16...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TB\Add_on_Control_BaseICI_12_16\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECOG\xiaoxiao\xx20230504\Block-5'; % 20230504 export
BLOCKPATH{2} = 'G:\ECOG\xiaoxiao\xx20230504\Block-8'; % 20230504 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
params.patch = "matchIssue";
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);


%% LocalChange, 4.06 in 4, N=0,1,2,4,8
disp("Exporting ClickTrainLongTerm LocalChange, 4.06 in 4, N=0,1,2,4,8...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TB\Add_on_LocalChange_4ms_2s-1s_N01248\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECOG\xiaoxiao\xx20230404\Block-2'; % 20230404 export
BLOCKPATH{2} = 'G:\ECOG\xiaoxiao\xx20230513\Block-6'; % 20230630 export
BLOCKPATH{3} = 'G:\ECOG\xiaoxiao\xx20230515\Block-3'; % 20230630 export
BLOCKPATH{4} = 'G:\ECOG\xiaoxiao\xx20230516\Block-3'; % 20230630 export
params.processFcn = @PassiveProcess_clickTrainContinuous;
params.patch = "matchIssue";
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);
%% add_on, 4.06 in 4 Rep1, time course
disp("Exporting ClickTrainLongTerm add_on 4.06 in 4,Rep1, time course...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TB\Add_on_Reg_Rep1_TimeCourse\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECOG\xiaoxiao\xx20230310\Block-4'; % 20230313 export
BLOCKPATH{2} = 'G:\ECOG\xiaoxiao\xx20230513\Block-6'; % 20230630 export
BLOCKPATH{3} = 'G:\ECOG\xiaoxiao\xx20230515\Block-3'; % 20230630 export
BLOCKPATH{4} = 'G:\ECOG\xiaoxiao\xx20230516\Block-3'; % 20230630 export
params.processFcn = @PassiveProcess_clickTrainContinuous;
params.patch = "matchIssue";
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% add_on, 0.5,1,2,4s 4.06 in 4 Rep1
disp("Exporting ClickTrainLongTerm add_on 0.5,1,3,5,4.06 in 4,Rep1...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TB\Add_on_Reg_Rep1_Dur\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECOG\xiaoxiao\xx20230310\Block-3'; % 20230313 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
params.patch = "matchIssue";
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% add_on, 4.06 in 4 Rep1 mix
disp("Exporting ClickTrainLongTerm add_on 4.06 in 4,Rep1 mix...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TB\Add_on_Reg_Insert_Rep1_mix\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECOG\xiaoxiao\xx20230308\Block-3'; % 20230308 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
params.patch = "bankIssue";
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);
%% add_on, 4.06 in 4 2s-1s
disp("Exporting ClickTrainLongTerm add_on 4.06 in 4,2s-1s...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TB\Add_on_Reg_Insert_2s-1s\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECOG\xiaoxiao\xx20230306\Block-3'; % 20230306 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
params.patch = "bankIssue";
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);
%% Species_2_4ms_Ratio
disp("Exporting ClickTrainLongTerm Species_2_4ms_Ratio  ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\SpeciesNew\Species_2_4ms_Ratio\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221118\Block-3'; % 20221118 export,
params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);


%% Species_6_8ms_Ratio
disp("Exporting ClickTrainLongTerm Species_6_8ms_Ratio  ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\SpeciesNew\Species_6_8ms_Ratio\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221118\Block-4'; % 20221118 export,
params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% Species_2_4_6_8_Duaration_1o5
disp("Exporting ClickTrainLongTerm Species_2_4_6_8_Duaration_1o5  ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\SpeciesNew\Species_2_4_6_8_Duaration_1o5\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221120\Block-2'; % 20221120 export,
params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% Species_2_4_6_8_Duaration_1o015
disp("Exporting ClickTrainLongTerm Species_2_4_6_8_Duaration_1o015  ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\SpeciesNew\Species_2_4_6_8_Duaration_1o015\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221120\Block-3'; % 20221120 export,
params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% Species_2_4_Oscillation_1o5
disp("Exporting ClickTrainLongTerm Species_2_4_Oscillation_1o5  ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\SpeciesNew\Species_2_4_Oscillation_1o5\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221120\Block-4'; % 20221120 export,
params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% Rhythm,TITS_4_15_20_25_noise_3s_4s_Reg_Irreg_Rev
disp("Exporting ClickTrainLongTerm TITS_4_25_noise_3s_4s_Reg_Irreg_Rev  ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TITS_4_25_noise_3s_4s_Reg_Irreg_Rev\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221115\Block-3'; % 20221115 export,
params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% Rhythm,TITS_Offset_15_Reg_Irreg_Noise_DiffDur_500_1000ms
disp("Exporting ClickTrainLongTerm TITS_Offset_15_Reg_Irreg_Noise_DiffDur_500_1000ms  ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TITS_Offset_15_Reg_Irreg_Noise_DiffDur_500_1000ms\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221114\Block-3'; % 20221114 export,
params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% Rhythm,TITS_15_30_3s_13s_Reg_Irreg_Rev
disp("Exporting ClickTrainLongTerm TITS_15_30_3s_13s_Reg_Irreg_Rev  ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TITS_15_30_3s_13s_Reg_Irreg_Rev\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221114\Block-4'; % 20221114 export,
params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% Rhythm,TITS_Offset_30_DiffRep_5_40
disp("Exporting ClickTrainLongTerm TITS_Offset_15_DiffRep_5_40  ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TITS_Offset_15_DiffRep_5_40\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221111\Block-2'; % 20221111 export,
params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% Rhythm,TITS_Offset_15_DiffRep 
disp("Exporting ClickTrainLongTerm TITS_Offset_15_DiffRep  ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TITS_Offset_15_DiffRep\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221110\Block-4'; % 20221110 export,
params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% Rhythm,TITS_Offset_30_DiffRep 
disp("Exporting ClickTrainLongTerm TITS_Offset_30_DiffRep  ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TITS_Offset_30_DiffRep\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221110\Block-3'; % 20221110 export,
params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);


%% Rhythm,TITS_Offset_60_24_26o4 
disp("Exporting ClickTrainLongTerm TITS_Offset_60_24_26o4  ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TITS_Offset_60_24_26o4\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221109\Block-4'; % 20221109 export,
params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% Rhythm,TITS_Offset_SPL 
disp("Exporting ClickTrainLongTerm TITS_Offset_SPL  ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TITS_Offset_SPL\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221108\Block-5'; % 20221108 export,
params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% Rhythm,TITS_Offset_Irreg_15_120 
disp("Exporting ClickTrainLongTerm TITS_Offset_Reg_Irreg_15_120 ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TITS_Offset_Reg_Irreg_15_120\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221108\Block-4'; % 20221108 export,
params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% Rhythm,TITS_X_24_Reg_Irreg    
disp("Exporting ClickTrainLongTerm TITS_X_24_Reg_Irreg ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TITS_X_24_Reg_Irreg\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221108\Block-3'; % 20221108 export,
params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% Rhythm,TITS_ToneFixed    
disp("Exporting ClickTrainLongTerm TITS_ToneFixed ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TITS_ToneFixed\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221107\Block-4'; % 20221107 export, 
params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% Rhythm, TITS 400_700     
disp("Exporting ClickTrainLongTerm TITS 400_700 ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\TITS_400_700\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221107\Block-3'; % 20221107 export,
params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);




%% species, Base ICI & Ratio 16ms
disp("Exporting ClickTrainLongTerm species_ICI 16ms, ratio ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Species_Ratio_ICI16\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221101\Block-3'; % 20221101 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% species, Base ICI & Ratio 12ms
disp("Exporting ClickTrainLongTerm species_ICI 12ms, ratio ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Species_Ratio_ICI12\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221101\Block-4'; % 20221101 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);


%% species, Base ICI & Ratio 8ms
disp("Exporting ClickTrainLongTerm species_ICI 8ms, ratio ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Species_Ratio_ICI8\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221101\Block-5'; % 20221101 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% add_on, part1, reg vs irreg, no reg in irreg
disp("Exporting ClickTrainLongTerm add_on part 1, reg VS irreg ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Add_on_Basic_ICI4\";
BLOCKPATH = [];
BLOCKPATH{1} = 'F:\ECoG\xiaoxiao\xx20221015\Block-3'; % 20221017 export
BLOCKPATH{2} = 'G:\ECoG\xiaoxiao\xx20221018\Block-4'; % 10dB louder
BLOCKPATH{3} = 'G:\ECoG\xiaoxiao\xx20221024\Block-4'; % 20221024 export, 10dB louder
BLOCKPATH{4} = 'G:\ECoG\xiaoxiao\xx20221025\Block-1'; % 20221025 export, 10dB louder
BLOCKPATH{5} = 'G:\ECoG\xiaoxiao\xx20221026\Block-1'; % 20221026 export, 10dB louder
BLOCKPATH{6} = 'G:\ECoG\xiaoxiao\xx20221027\Block-1'; % 20221027 export, 10dB louder

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 6);

%% add_on, part2, tone 250_246, 250_200
disp("Exporting ClickTrainLongTerm add_on part 2, tone ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Add_on_Basic_Tone\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221015\Block-4'; % 20221017 export
BLOCKPATH{2} = 'G:\ECoG\xiaoxiao\xx20221018\Block-5'; % 10dB louder
BLOCKPATH{3} = 'G:\ECoG\xiaoxiao\xx20221024\Block-5'; % 20221024 export, 10dB louder
BLOCKPATH{4} = 'G:\ECoG\xiaoxiao\xx20221025\Block-2'; % 20221025 export, 10dB louder
BLOCKPATH{5} = 'G:\ECoG\xiaoxiao\xx20221026\Block-2'; % 20221026 export, 10dB louder
BLOCKPATH{6} = 'G:\ECoG\xiaoxiao\xx20221027\Block-2'; % 20221027 export, 10dB louder

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 6);

%% add_on, part3, norm_sqrt, base ICI = 4ms
disp("Exporting ClickTrainLongTerm add_on part 3, reg VS irreg, base ICI = 4 ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Add_on_Basic_NormSqrt_ICI4\";
BLOCKPATH = [];
BLOCKPATH{1} = 'F:\ECoG\xiaoxiao\xx20221017\Block-3'; % 20221017 export
BLOCKPATH{2} = 'G:\ECoG\xiaoxiao\xx20221019\Block-3'; % 10dB louder
BLOCKPATH{3} = 'G:\ECoG\xiaoxiao\xx20221024\Block-6'; % 20221024 export, 10dB louder
BLOCKPATH{4} = 'G:\ECoG\xiaoxiao\xx20221027\Block-3'; % 20221027 export, 10dB louder


params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 4);

%% add_on, part4, norm_sqrt, base ICI = 8ms
disp("Exporting ClickTrainLongTerm add_on part 4, reg VS irreg, base ICI = 8 ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Add_on_Basic_NormSqrt_ICI8\";
BLOCKPATH = [];
BLOCKPATH{1} = 'F:\ECoG\xiaoxiao\xx20221017\Block-4'; % 20221017 export
BLOCKPATH{2} = 'G:\ECoG\xiaoxiao\xx20221019\Block-4'; % 10dB louder
BLOCKPATH{3} = 'G:\ECoG\xiaoxiao\xx20221024\Block-7'; % 20221024 export, 10dB louder
BLOCKPATH{4} = 'G:\ECoG\xiaoxiao\xx20221027\Block-4'; % 20221027 export, 10dB louder

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 4);

%% add_on, part5, duration 0.5,1,2,3,4,5
disp("Exporting ClickTrainLongTerm add_on part 5, duration 0.5,1,2,3,4,5 ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Add_on_Basic_Duration_0o5_5\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221020\Block-3'; % 20221020 export， errors in order txt
BLOCKPATH{2} = 'G:\ECoG\xiaoxiao\xx20221021\Block-5'; % 20221020 export 
BLOCKPATH{3} = 'G:\ECoG\xiaoxiao\xx20221024\Block-8'; % 20221024 export, 10dB louder
BLOCKPATH{4} = 'G:\ECoG\xiaoxiao\xx20221025\Block-3'; % 20221025 export, 10dB louder
BLOCKPATH{5} = 'G:\ECoG\xiaoxiao\xx20221026\Block-3'; % 20221026 export, 10dB louder
BLOCKPATH{6} = 'G:\ECoG\xiaoxiao\xx20221027\Block-5'; % 20221027 export, 10dB louder

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 6);

% %% add_on, part6, click train oscillation 500_250_125_60_30
% disp("Exporting ClickTrainLongTerm add_on part 6, click train oscillation 500_250_125_60_30 ...");
% SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Add_on_Basic_Oscillation_500_250_125_60_30\";
% BLOCKPATH = [];
% BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221021\Block-6'; % 20221024 export, do not have control 
% 
% 
% params.processFcn = @PassiveProcess_clickTrainContinuous;
% exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% add_on, part6.2, click train oscillation 500_250_125_60_30_control
disp("Exporting ClickTrainLongTerm add_on part 6.2, click train oscillation 500_250_125_60_30 ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Add_on_Basic_Oscillation_control_500_250_125_60_30\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221024\Block-1'; % 20221024 export
BLOCKPATH{2} = 'G:\ECoG\xiaoxiao\xx20221025\Block-4'; % 20221025 export, 10dB louder
BLOCKPATH{3} = 'G:\ECoG\xiaoxiao\xx20221026\Block-4'; % 20221026 export, 10dB louder
BLOCKPATH{4} = 'G:\ECoG\xiaoxiao\xx20221027\Block-6'; % 20221027 export, 10dB louder


params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 4);

%% add_on, part7, click train oscillation Tone 250_200_5000_4000
disp("Exporting ClickTrainLongTerm add_on part 7, click train oscillation Tone 250_200_5000_4000 ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Add_on_Basic_Oscillation_Tone_250_5000\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221024\Block-2'; % 20221024 export
BLOCKPATH{2} = 'G:\ECoG\xiaoxiao\xx20221025\Block-5'; % 20221025 export, 10dB louder
BLOCKPATH{3} = 'G:\ECoG\xiaoxiao\xx20221026\Block-5'; % 20221026 export, 10dB louder
BLOCKPATH{4} = 'G:\ECoG\xiaoxiao\xx20221027\Block-7'; % 20221027 export, 10dB louder

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 4);

%% add_on, part8, click train variance 50_2
disp("Exporting ClickTrainLongTerm add_on part 9, click train variance 50_2 ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Add_on_Basic_Var_50_2\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221024\Block-9'; % 20221024 export
BLOCKPATH{2} = 'G:\ECoG\xiaoxiao\xx20221025\Block-6'; % 20221025 export, 10dB louder
BLOCKPATH{3} = 'G:\ECoG\xiaoxiao\xx20221026\Block-6'; % 20221026 export, 10dB louder
BLOCKPATH{4} = 'G:\ECoG\xiaoxiao\xx20221027\Block-8'; % 20221027 export, 10dB louder

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 4);

%% add_on, part9, click train variance 400_50
disp("Exporting ClickTrainLongTerm add_on part 8, click train variance 400_50 ...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Add_on_Basic_Var_400_50\";
BLOCKPATH = [];
BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221024\Block-3'; % 20221024 export
BLOCKPATH{2} = 'G:\ECoG\xiaoxiao\xx20221025\Block-7'; % 20221025 export, 10dB louder
BLOCKPATH{3} = 'G:\ECoG\xiaoxiao\xx20221026\Block-7'; % 20221026 export, 10dB louder
BLOCKPATH{4} = 'G:\ECoG\xiaoxiao\xx20221027\Block-9'; % 20221027 export, 10dB louder

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 4);


%% duration 1s 2s 3s 4s 5s-1sm 4.06-4
disp("Exporting ClickTrainLongTerm duration...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Duration1-5s_1s_4o06_4\";
BLOCKPATH = [];
BLOCKPATH{1} = 'F:\ECoG\xiaoxiao\xx20221012\Block-3'; % 20221012 export
BLOCKPATH{2} = 'F:\ECoG\xiaoxiao\xx20221013\Block-3'; % 20221013 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 2);

%% duration 1s 2s 3s 4s 5s-1sm 4-4.06
disp("Exporting ClickTrainLongTerm duration...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Duration1-5s_1s_4_4o06\";
BLOCKPATH = [];
BLOCKPATH{1} = 'F:\ECoG\xiaoxiao\xx20221012\Block-4'; % 20221012 export
BLOCKPATH{2} = 'F:\ECoG\xiaoxiao\xx20221013\Block-4'; % 20221013 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 2);

%% successive tone 250-246,240,200
disp("Exporting ClickTrainLongTerm successive...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Successive_Tone_250-246_240_200\";
BLOCKPATH = [];
BLOCKPATH{1} = 'F:\ECoG\xiaoxiao\xx20221011\Block-4'; % 20221011 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);


%% clickTrainLongTerm successive 0.025_0.05
disp("Exporting ClickTrainLongTerm successive...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Successive_0o025_0o05\";
BLOCKPATH = [];
BLOCKPATH{1} = 'F:\ECoG\xiaoxiao\xx20221011\Block-3'; % 20221011 export

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% clickTrainLongTerm successive 0.1_0.2
disp("Exporting ClickTrainLongTerm successive...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Successive_0o1_0o2\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220927\Block-3';
BLOCKPATH{2} = 'E:\ECoG\xiaoxiao\xx20220929\Block-3';
BLOCKPATH{3} = 'E:\ECoG\xiaoxiao\xx20220930\Block-3';% 20221007 export


params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% clickTrainLongTerm successive 0.3_0.5
disp("Exporting ClickTrainLongTerm successive...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Successive_0o3_0o5\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220927\Block-4';
BLOCKPATH{2} = 'E:\ECoG\xiaoxiao\xx20220929\Block-4';% 20221007 export


params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% clickTrainLongTerm Basic 4-4.06
% disp("Exporting ClickTrainLongTerm Basic 4-4.06...");
% SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Basic_ICI4\";
% BLOCKPATH = [];
% BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220623\Block-3';
% BLOCKPATH{2} = 'E:\ECoG\xiaoxiao\xx20220625\Block-2';
% BLOCKPATH{3} = 'E:\ECoG\xiaoxiao\xx20220626\Block-1';
% BLOCKPATH{4} = 'E:\ECoG\xiaoxiao\xx20220711\Block-3';
% BLOCKPATH{5} = 'E:\ECoG\xiaoxiao\xx20220715\Block-3';
% BLOCKPATH{6} = 'E:\ECoG\xiaoxiao\xx20220725\Block-3';% 20221007 export
% 
% 
% params.processFcn = @PassiveProcess_clickTrainContinuous;
% exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);


%% clickTrainLongTerm Basic 8-8.12
% disp("Exporting ClickTrainLongTerm Basic 8-8.12...");
% SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Basic_ICI8\";
% BLOCKPATH = [];
% BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220623\Block-4';
% BLOCKPATH{2} = 'E:\ECoG\xiaoxiao\xx20220625\Block-3';
% BLOCKPATH{3} = 'E:\ECoG\xiaoxiao\xx20220626\Block-2';
% BLOCKPATH{4} = 'E:\ECoG\xiaoxiao\xx20220711\Block-4';
% BLOCKPATH{5} = 'E:\ECoG\xiaoxiao\xx20220715\Block-4';
% BLOCKPATH{6} = 'E:\ECoG\xiaoxiao\xx20220725\Block-4';% 20221007 export
% 
% 
% 
% params.processFcn = @PassiveProcess_clickTrainContinuous;
% exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);


%% clickTrainLongTerm Basic 20-20.3
% disp("Exporting ClickTrainLongTerm Basic 20-20.3...");
% SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Basic_ICI20\";
% BLOCKPATH = [];
% BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220623\Block-5';
% BLOCKPATH{2} = 'E:\ECoG\xiaoxiao\xx20220625\Block-4';
% BLOCKPATH{3} = 'E:\ECoG\xiaoxiao\xx20220626\Block-3';
% BLOCKPATH{4} = 'E:\ECoG\xiaoxiao\xx20220711\Block-5';
% BLOCKPATH{5} = 'E:\ECoG\xiaoxiao\xx20220715\Block-5';
% BLOCKPATH{6} = 'E:\ECoG\xiaoxiao\xx20220725\Block-5';% 20221007 export
% 
% 
% 
% params.processFcn = @PassiveProcess_clickTrainContinuous;
% exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);


%% clickTrainLongTerm Basic 40-40.6
% disp("Exporting ClickTrainLongTerm Basic 40-40.6...");
% SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Basic_ICI40\";
% BLOCKPATH = [];
% BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220623\Block-6';
% BLOCKPATH{2} = 'E:\ECoG\xiaoxiao\xx20220625\Block-5';
% BLOCKPATH{3} = 'E:\ECoG\xiaoxiao\xx20220626\Block-4';
% BLOCKPATH{4} = 'E:\ECoG\xiaoxiao\xx20220711\Block-6';
% BLOCKPATH{5} = 'E:\ECoG\xiaoxiao\xx20220716\Block-4';
% BLOCKPATH{6} = 'E:\ECoG\xiaoxiao\xx20220720\Block-2';% 20221007 export
% 
% 
% 
% params.processFcn = @PassiveProcess_clickTrainContinuous;
% exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);


%% clickTrainLongTerm Basic 80-81.2
% disp("Exporting ClickTrainLongTerm Basic 80-81.2...");
% SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Basic_ICI80\";
% BLOCKPATH = [];
% BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220623\Block-7';
% BLOCKPATH{2} = 'E:\ECoG\xiaoxiao\xx20220625\Block-6';
% BLOCKPATH{3} = 'E:\ECoG\xiaoxiao\xx20220626\Block-5';
% BLOCKPATH{4} = 'E:\ECoG\xiaoxiao\xx20220711\Block-7';
% BLOCKPATH{5} = 'E:\ECoG\xiaoxiao\xx20220716\Block-5';
% BLOCKPATH{6} = 'E:\ECoG\xiaoxiao\xx20220720\Block-3';% 20221007 export
% 
% 
% params.processFcn = @PassiveProcess_clickTrainContinuous;
% exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);


%% clickTrainLongTerm Basic ICI Threshold
disp("Exporting ClickTrainLongTerm ICI Threshold...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Basic_ICIThr\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220702\Block-3';
BLOCKPATH{2} = 'E:\ECoG\xiaoxiao\xx20220706\Block-3'; % 20221007 export
BLOCKPATH{3} = 'G:\ECoG\xiaoxiao\xx20220808\Block-3'; %20221007 #3-5 block not added
BLOCKPATH{4} = 'G:\ECoG\xiaoxiao\xx20220809\Block-2';
BLOCKPATH{5} = 'G:\ECoG\xiaoxiao\xx20220812\Block-2'; %20221019 #3-5 block added

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 3);

%% clickTrainLongTerm Basic IrregVar
disp("Exporting ClickTrainLongTerm Basic IrregVar...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Basic_IrregVar\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220702\Block-4';
BLOCKPATH{2} = 'E:\ECoG\xiaoxiao\xx20220706\Block-5';
BLOCKPATH{3} = 'E:\ECoG\xiaoxiao\xx20220712\Block-3';
BLOCKPATH{4} = 'E:\ECoG\xiaoxiao\xx20220721\Block-3'; % 20221007 export
% BLOCKPATH{5} = 'E:\ECoG\xiaoxiao\xx20220809\Block-3';% 20221007 #5 block not added

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% clickTrainLongTerm Basic Insert
% disp("Exporting ClickTrainLongTerm Basic Insert...");
% SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Basic_Insert\";
% BLOCKPATH = [];
% BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220702\Block-3';
% BLOCKPATH{2} = 'E:\ECoG\xiaoxiao\xx20220706\Block-4';
% BLOCKPATH{3} = 'E:\ECoG\xiaoxiao\xx20220713\Block-4';
% BLOCKPATH{4} = 'E:\ECoG\xiaoxiao\xx20220722\Block-3';
% BLOCKPATH{5} = 'E:\ECoG\xiaoxiao\xx20220812\Block-3';% 20221007 #5-8 block not added
% BLOCKPATH{6} = 'E:\ECoG\xiaoxiao\xx20220820\Block-3';
% BLOCKPATH{7} = 'E:\ECoG\xiaoxiao\xx20220822\Block-3';

params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

%% clickTrainLongTerm Basic Norm Sqrt
disp("Exporting ClickTrainLongTerm Basic Norm Sqrt...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Basic_NormSqrt\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220829\Block-2';


params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);


%% clickTrainLongTerm Species ICIBind248204080Ratio1o1
disp("Exporting ClickTrainLongTerm Species ICIBind248204080Ratio1o1...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Species_ICIBind248204080Ratio1o1\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220830\Block-4';
BLOCKPATH{2} = 'E:\ECoG\xiaoxiao\xx20220831\Block-4';
BLOCKPATH{3} = 'E:\ECoG\xiaoxiao\xx20220901\Block-4';
BLOCKPATH{4} = 'E:\ECoG\xiaoxiao\xx20220902\Block-4';
BLOCKPATH{5} = 'E:\ECoG\xiaoxiao\xx20220903\Block-4';
BLOCKPATH{6} = 'E:\ECoG\xiaoxiao\xx20220905\Block-4';
BLOCKPATH{7} = 'E:\ECoG\xiaoxiao\xx20220906\Block-4';


params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);


%% clickTrainLongTerm Species RatioDetect4o1o2o3o4
disp("Exporting ClickTrainLongTerm Species RatioDetect4o1o2o3o4...");
SAVEPATH = "E:\ECOG\MAT Data\XX\ClickTrainLongTerm\Species_RatioDetect4o1o2o3o4\";
BLOCKPATH = [];
BLOCKPATH{1} = 'E:\ECoG\xiaoxiao\xx20220830\Block-2';
BLOCKPATH{2} = 'E:\ECoG\xiaoxiao\xx20220831\Block-3';
BLOCKPATH{3} = 'E:\ECoG\xiaoxiao\xx20220901\Block-3';
BLOCKPATH{4} = 'E:\ECoG\xiaoxiao\xx20220902\Block-3';
BLOCKPATH{5} = 'E:\ECoG\xiaoxiao\xx20220903\Block-3';
BLOCKPATH{6} = 'E:\ECoG\xiaoxiao\xx20220905\Block-3';
BLOCKPATH{7} = 'E:\ECoG\xiaoxiao\xx20220906\Block-3';


params.processFcn = @PassiveProcess_clickTrainContinuous;
exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, 1);

