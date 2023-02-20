%% Batch
clear; clc; close all;

params.choiceWin = [100, 600];
params.processFcn = @PassiveProcess_7_10Freq;

params.monkeyID = 1; % 1-CC, 2-XX

if params.monkeyID == 1
    params.ROOTPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\CC\7-10Freq Passive\';
    DATESTRs = {'cc20220520', 'cc20220801', 'cc20220814', 'cc20221014', 'cc20221015'};
    MONKEYPATH = 'CC\Population\';
else
    params.ROOTPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\XX\7-10Freq Passive\';
    DATESTRs = {'xx20220711', 'xx20220820', 'xx20220822', 'xx20220913', 'xx20220914'};
    MONKEYPATH = 'XX\Population\';
end

params.icaOpt = "off"; % on or off
params.DATESTRs = DATESTRs;
params.PrePATH = [MONKEYPATH, 'Preprocess\'];

%% Exclude trials and bad channels
params.userDefineOpt = "off";
Pre_ProcessFcn(params);

%% PE
params.MONKEYPATH = [MONKEYPATH, 'PE\'];
params.AREANAME = 'AC';
params.posIndex = 1; % 1-AC, 2-PFC
PE_ProcessFcn(params);
params.AREANAME = 'PFC';
params.posIndex = 2; % 1-AC, 2-PFC
PE_ProcessFcn(params);

%% Prediction
params.MONKEYPATH = [MONKEYPATH, 'Prediction\'];
params.AREANAME = 'AC';
params.posIndex = 1; % 1-AC, 2-PFC
Prediction_ProcessFcn(params);
params.AREANAME = 'PFC';
params.posIndex = 2; % 1-AC, 2-PFC
Prediction_ProcessFcn(params);

%% Granger
params.MONKEYPATH = [MONKEYPATH, 'Granger\'];
params.DATAPATH = [];

params.protocolType = 1; % 1-PE, 2-DM, 3-Prediction
params.DATAPATH{1} = [MONKEYPATH, 'PE\AC_PE_Data.mat'];
params.DATAPATH{2} = [MONKEYPATH, 'PE\PFC_PE_Data.mat'];
params.trialType = 1; % 1-dev, 2-std
Granger_ProcessFcn(params);
params.trialType = 2; % 1-dev, 2-std
Granger_ProcessFcn(params);

params.protocolType = 3; % 1-PE, 2-DM, 3-Prediction
params.DATAPATH{1} = [MONKEYPATH, 'Prediction\AC_Prediction_Data.mat'];
params.DATAPATH{2} = [MONKEYPATH, 'Prediction\PFC_Prediction_Data.mat'];
params.trialType = 1; % 1-nStd=1, 2-nStd=7
Granger_ProcessFcn(params);
params.trialType = 2; % 1-nStd=1, 2-nStd=7
Granger_ProcessFcn(params);
