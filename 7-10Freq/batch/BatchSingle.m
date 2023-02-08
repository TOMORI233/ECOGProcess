%% Batch
clear; clc; close all;

params.choiceWin = [100, 600];
params.processFcn = @ActiveProcess_7_10Freq;

params.monkeyID = 1; % 1-CC, 2-XX

if params.monkeyID == 1
    params.ROOTPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\CC\7-10Freq Active\';
    DATESTRs = {'cc20220520', 'cc20220706', 'cc20220801', 'cc20221014', 'cc20221015'};
    MONKEYPATH = 'CC\';
else
    params.ROOTPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\XX\7-10Freq Active\';
    DATESTRs = {'xx20220711', 'xx20220812', 'xx20220820', 'xx20220822', 'xx20220913'};
    MONKEYPATH = 'XX\';
end

params.icaOpt = "off"; % on or off

%% Single day
for index = 1:length(DATESTRs)
    params.DATESTRs = DATESTRs(index);
    params.PrePATH = [MONKEYPATH, 'Single\Preprocess\', DATESTRs{index}, '\'];

    %% exclude trials
    Pre_ProcessFcn(params);

    %% PE
    params.MONKEYPATH = [MONKEYPATH, 'Single\PE\', DATESTRs{index}, '\'];
    params.AREANAME = 'AC';
    params.posIndex = 1; % 1-AC, 2-PFC
    PE_ProcessFcn(params);
    params.AREANAME = 'PFC';
    params.posIndex = 2; % 1-AC, 2-PFC
    PE_ProcessFcn(params);

    %% DM
    params.MONKEYPATH = [MONKEYPATH, 'Single\DM\', DATESTRs{index}, '\'];
    params.AREANAME = 'AC';
    params.posIndex = 1; % 1-AC, 2-PFC
    DM_ProcessFcn(params);
    params.AREANAME = 'PFC';
    params.posIndex = 2; % 1-AC, 2-PFC
    DM_ProcessFcn(params);

    %% Prediction
    params.MONKEYPATH = [MONKEYPATH, 'Single\Prediction\', DATESTRs{index}, '\'];
    params.AREANAME = 'AC';
    params.posIndex = 1; % 1-AC, 2-PFC
    Prediction_ProcessFcn(params);
    params.AREANAME = 'PFC';
    params.posIndex = 2; % 1-AC, 2-PFC
    Prediction_ProcessFcn(params);

    %% Compare single
    params.MONKEYPATH = [MONKEYPATH, 'Single\Compare\', DATESTRs{index}, '\'];
    params.DATAPATH{1} = [MONKEYPATH, 'Single\PE\', DATESTRs{index}, '\AC_PE_tuning.mat'];
    params.DATAPATH{2} = [MONKEYPATH, 'Single\PE\', DATESTRs{index}, '\PFC_PE_tuning.mat'];
    params.DATAPATH{3} = [MONKEYPATH, 'Single\DM\', DATESTRs{index}, '\AC_DM_tuning.mat'];
    params.DATAPATH{4} = [MONKEYPATH, 'Single\DM\', DATESTRs{index}, '\PFC_DM_tuning.mat'];
    Compare_ProcessFcn(params);

    %% Granger
    params.MONKEYPATH = [MONKEYPATH, 'Single\Granger\', DATESTRs{index}, '\'];
    params.DATAPATH = [];

    params.protocolType = 1; % 1-PE, 2-DM, 3-Prediction
    params.DATAPATH{1} = [MONKEYPATH, 'Single\PE\', DATESTRs{index}, '\AC_PE_Data.mat'];
    params.DATAPATH{2} = [MONKEYPATH, 'Single\PE\', DATESTRs{index}, '\PFC_PE_Data.mat'];
    params.trialType = 1; % 1-dev, 2-std
    Granger_ProcessFcn(params);
    params.trialType = 2; % 1-dev, 2-std
    Granger_ProcessFcn(params);

    params.protocolType = 2; % 1-PE, 2-DM, 3-Prediction
    params.DATAPATH{1} = [MONKEYPATH, 'Single\DM\', DATESTRs{index}, '\AC_DM_Data.mat'];
    params.DATAPATH{2} = [MONKEYPATH, 'Single\DM\', DATESTRs{index}, '\PFC_DM_Data.mat'];
    params.trialType = 1; % 1-correct, 2-wrong
    Granger_ProcessFcn(params);
    params.trialType = 2; % 1-correct, 2-wrong
    Granger_ProcessFcn(params);

    params.protocolType = 3; % 1-PE, 2-DM, 3-Prediction
    params.DATAPATH{1} = [MONKEYPATH, 'Single\Prediction\', DATESTRs{index}, '\AC_Prediction_Data.mat'];
    params.DATAPATH{2} = [MONKEYPATH, 'Single\Prediction\', DATESTRs{index}, '\PFC_Prediction_Data.mat'];
    params.trialType = 1; % 1-nStd=1, 2-nStd=7
    Granger_ProcessFcn(params);
    params.trialType = 2; % 1-nStd=1, 2-nStd=7
    Granger_ProcessFcn(params);

    params = rmfield(params, "DATAPATH");
end