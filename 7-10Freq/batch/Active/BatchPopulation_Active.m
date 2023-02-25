%% Batch raw data
clear; clc; close all;

params.choiceWin = [100, 600];
params.processFcn = @ActiveProcess_7_10Freq;

params.monkeyID = 1; % 1-CC, 2-XX

%% Parameter setting
if params.monkeyID == 1
    params.ROOTPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\CC\7-10Freq Active\';
    DATESTRs = {'cc20220520', 'cc20220706', 'cc20220801', 'cc20221014', 'cc20221015'};
    POPUROOTPATH = 'CC\Population\';
    SINGLEROOTPATH = 'CC\Single\';
else
    params.ROOTPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\XX\7-10Freq Active\';
    DATESTRs = {'xx20220711', 'xx20220812', 'xx20220820', 'xx20220822', 'xx20220913'};
    POPUROOTPATH = 'XX\Population\';
    SINGLEROOTPATH = 'XX\Single\';
end

params.DATESTRs = DATESTRs;
params.PrePATH = [POPUROOTPATH, 'Preprocess\'];

%% Exclude trials and bad channels
params.icaOpt = "off"; % on or off
params.userDefineOpt = "off";
Pre_ProcessFcn(params);

%% PE
params.icaOpt = "on"; % on or off
params.MONKEYPATH = [POPUROOTPATH, 'PE\'];
params.AREANAME = 'AC';
params.posIndex = 1; % 1-AC, 2-PFC
PE_ProcessFcn(params);

params.AREANAME = 'PFC';
params.posIndex = 2; % 1-AC, 2-PFC
PE_ProcessFcn(params);

%% DM
params.MONKEYPATH = [POPUROOTPATH, 'DM\'];
params.AREANAME = 'AC';
params.posIndex = 1; % 1-AC, 2-PFC
DM_ProcessFcn(params);
params.AREANAME = 'PFC';
params.posIndex = 2; % 1-AC, 2-PFC
DM_ProcessFcn(params);

%% Prediction
params.MONKEYPATH = [POPUROOTPATH, 'Prediction\'];
params.AREANAME = 'AC';
params.posIndex = 1; % 1-AC, 2-PFC
Prediction_ProcessFcn(params);
params.AREANAME = 'PFC';
params.posIndex = 2; % 1-AC, 2-PFC
Prediction_ProcessFcn(params);

%% Compare single
params.MONKEYPATH = [POPUROOTPATH, 'Compare\'];
params.DATAPATH{1} = [POPUROOTPATH, 'PE\AC_PE_tuning.mat'];
params.DATAPATH{2} = [POPUROOTPATH, 'PE\PFC_PE_tuning.mat'];
params.DATAPATH{3} = [POPUROOTPATH, 'DM\AC_DM_tuning.mat'];
params.DATAPATH{4} = [POPUROOTPATH, 'DM\PFC_DM_tuning.mat'];
Compare_ProcessFcn(params);

%% Granger
params.DATAPATH = [];

% no smoothing
params.MONKEYPATH = [POPUROOTPATH, 'Granger (no smoothing)\'];
params.nSmooth = 1;
% smoothing
% params.MONKEYPATH = [POPUROOTPATH, 'Granger\'];
% params.nSmooth = 2;

params.protocolType = 1; % 1-PE, 2-DM, 3-Prediction
params.DATAPATH{1} = [POPUROOTPATH, 'PE\AC_PE_Data.mat'];
params.DATAPATH{2} = [POPUROOTPATH, 'PE\PFC_PE_Data.mat'];
params.windowGranger = [0, 500]; % ms
params.trialType = 1; % 1-dev, 2-std
Granger_ProcessFcn(params);
params.trialType = 2; % 1-dev, 2-std
Granger_ProcessFcn(params);

params.protocolType = 2; % 1-PE, 2-DM, 3-Prediction
params.DATAPATH{1} = [POPUROOTPATH, 'DM\AC_DM_Data.mat'];
params.DATAPATH{2} = [POPUROOTPATH, 'DM\PFC_DM_Data.mat'];
params.windowGranger = [0, 500]; % ms
params.trialType = 1; % 1-correct, 2-wrong
Granger_ProcessFcn(params);
params.trialType = 2; % 1-correct, 2-wrong
Granger_ProcessFcn(params);

params.protocolType = 3; % 1-PE, 2-DM, 3-Prediction
params.DATAPATH{1} = [POPUROOTPATH, 'Prediction\AC_Prediction_Data.mat'];
params.DATAPATH{2} = [POPUROOTPATH, 'Prediction\PFC_Prediction_Data.mat'];
for nStd = [1 3 7]
    params.windowGranger = [500 * (nStd - 1), 500 * nStd];
    Granger_ProcessFcn(params);
end