%% Batch
clear; clc; close all;

params.choiceWin = [100, 600];
params.processFcn = @PassiveProcess_7_10Freq;

params.monkeyID = 1; % 1-CC, 2-XX

if params.monkeyID == 1
    params.ROOTPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\CC\7-10Freq Passive\';
    DATESTRs = {'cc20220520', 'cc20220801', 'cc20220814', 'cc20221014', 'cc20221015'};
    MONKEYPATH = 'CC\Single\';
else
    params.ROOTPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\XX\7-10Freq Passive\';
    DATESTRs = {'xx20220711', 'xx20220820', 'xx20220822', 'xx20220913', 'xx20220914'};
    MONKEYPATH = 'XX\Single\';
end

params.icaOpt = "off"; % on or off

%% Single day
for index = 1:length(DATESTRs)
    params.DATESTRs = DATESTRs(index);
    params.PrePATH = [MONKEYPATH, 'Preprocess\', DATESTRs{index}, '\'];

    %% exclude trials
    Pre_ProcessFcn(params);

    %% PE
    params.MONKEYPATH = [MONKEYPATH, 'PE\', DATESTRs{index}, '\'];
    params.AREANAME = 'AC';
    params.posIndex = 1; % 1-AC, 2-PFC
    PE_ProcessFcn(params);
    params.AREANAME = 'PFC';
    params.posIndex = 2; % 1-AC, 2-PFC
    PE_ProcessFcn(params);

    %% Prediction
    params.MONKEYPATH = [MONKEYPATH, 'Prediction\', DATESTRs{index}, '\'];
    params.AREANAME = 'AC';
    params.posIndex = 1; % 1-AC, 2-PFC
    Prediction_ProcessFcn(params);
    params.AREANAME = 'PFC';
    params.posIndex = 2; % 1-AC, 2-PFC
    Prediction_ProcessFcn(params);

    %% Granger
    params.MONKEYPATH = [MONKEYPATH, 'Granger\', DATESTRs{index}, '\'];
    params.DATAPATH = [];

    params.protocolType = 1; % 1-PE, 2-DM, 3-Prediction
    params.DATAPATH{1} = [MONKEYPATH, 'PE\', DATESTRs{index}, '\AC_PE_Data.mat'];
    params.DATAPATH{2} = [MONKEYPATH, 'PE\', DATESTRs{index}, '\PFC_PE_Data.mat'];
    params.trialType = 1; % 1-dev, 2-std
    Granger_ProcessFcn(params);
    params.trialType = 2; % 1-dev, 2-std
    Granger_ProcessFcn(params);

    params.protocolType = 3; % 1-PE, 2-DM, 3-Prediction
    params.DATAPATH{1} = [MONKEYPATH, 'Prediction\', DATESTRs{index}, '\AC_Prediction_Data.mat'];
    params.DATAPATH{2} = [MONKEYPATH, 'Prediction\', DATESTRs{index}, '\PFC_Prediction_Data.mat'];
    params.trialType = 1; % 1-nStd=1, 2-nStd=7
    Granger_ProcessFcn(params);
    params.trialType = 2; % 1-nStd=1, 2-nStd=7
    Granger_ProcessFcn(params);

    params = rmfield(params, "DATAPATH");
end