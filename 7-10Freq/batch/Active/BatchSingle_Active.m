%% Process data of each day and batch processed data of each day
clear; clc; close all;
set(0, "DefaultAxesFontWeight", "bold");

params.choiceWin = [100, 600];
params.processFcn = @ActiveProcess_7_10Freq;
params.normOpt = "off"; % Normalization

params.monkeyID = 2; % 1-CC, 2-XX

CURRENTPATH = pwd;

if params.monkeyID == 1
    params.ROOTPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\CC\7-10Freq Active\';
    DATESTRs = {'cc20220520', 'cc20220706', 'cc20220801', 'cc20221014', 'cc20221015'};
%     DATESTRs = {'cc20220520', 'cc20220706', 'cc20220801', 'cc20221014'};
%     DATESTRs = {'cc20220908'}; % ISI=700
%     DATESTRs = {'cc20221019'}; % ISI=400
    POPUROOTPATH = [CURRENTPATH, '\CC\Population\'];
    SINGLEROOTPATH = [CURRENTPATH, '\CC\Single\'];
else
    params.ROOTPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\XX\7-10Freq Active\';
    DATESTRs = {'xx20220711', 'xx20220812', 'xx20220820', 'xx20220822', 'xx20220913'};
%     DATESTRs = {'xx20221017'}; % ISI=400
    POPUROOTPATH = [CURRENTPATH, '\XX\Population\'];
    SINGLEROOTPATH = [CURRENTPATH, '\XX\Single\'];
end

params = windowConfig_7_10Freq(params);

%% Single day ----------------------------------------------------------------
params.dataOnlyOpt = "on"; % "on" will save data only

for index = 1:length(DATESTRs)
    params.DATESTRs = DATESTRs(index);
    params.PrePATH = [SINGLEROOTPATH, 'Preprocess\', DATESTRs{index}, '\'];

    % Exclude trials and bad channels
    params.icaOpt = "on"; % "on" here will perform ICA on all channels and decide bad channels after ICA
    params.userDefineOpt = "off";
    Pre_ProcessFcn(params);

    % PE
    % params.icaOpt = "on"; % "off" in preprocess and "on" here will perform ICA on good channels
    % params.MONKEYPATH = [SINGLEROOTPATH, 'PE\', DATESTRs{index}, '\'];
    % params.AREANAME = 'AC';
    % params.posIndex = 1; % 1-AC, 2-PFC
    % PE_ProcessFcn(params);
    % params.AREANAME = 'PFC';
    % params.posIndex = 2; % 1-AC, 2-PFC
    % PE_ProcessFcn(params);

    % DM
    % params.MONKEYPATH = [SINGLEROOTPATH, 'DM\', DATESTRs{index}, '\'];
    % params.AREANAME = 'AC';
    % params.posIndex = 1; % 1-AC, 2-PFC
    % DM_ProcessFcn(params);
    % params.AREANAME = 'PFC';
    % params.posIndex = 2; % 1-AC, 2-PFC
    % DM_ProcessFcn(params);

    % Prediction
    params.MONKEYPATH = [SINGLEROOTPATH, 'Prediction\', DATESTRs{index}, '\'];
    params.AREANAME = 'AC';
    params.posIndex = 1; % 1-AC, 2-PFC
    Prediction_ProcessFcn(params);
    params.AREANAME = 'PFC';
    params.posIndex = 2; % 1-AC, 2-PFC
    Prediction_ProcessFcn(params);

    if strcmpi(params.dataOnlyOpt, "on")
        continue;
    end

    % Compare single
    params.MONKEYPATH = [SINGLEROOTPATH, 'Compare\', DATESTRs{index}, '\'];
    params.DATAPATH{1} = [SINGLEROOTPATH, 'PE\', DATESTRs{index}, '\AC_PE_MMN_tuning.mat'];
    params.DATAPATH{2} = [SINGLEROOTPATH, 'PE\', DATESTRs{index}, '\PFC_PE_MMN_tuning.mat'];
    params.DATAPATH{3} = [SINGLEROOTPATH, 'DM\', DATESTRs{index}, '\AC_DM_tuning.mat'];
    params.DATAPATH{4} = [SINGLEROOTPATH, 'DM\', DATESTRs{index}, '\PFC_DM_tuning.mat'];
    Compare_ProcessFcn(params);

    % Granger
    params.MONKEYPATH = [SINGLEROOTPATH, 'Granger\', DATESTRs{index}, '\'];
    params.nSmooth = 2;
    params.DATAPATH = [];
    
    params.protocolType = 1; % 1-PE, 2-DM, 3-Prediction
    params.DATAPATH{1} = [SINGLEROOTPATH, 'PE\', DATESTRs{index}, '\AC_PE_Data.mat'];
    params.DATAPATH{2} = [SINGLEROOTPATH, 'PE\', DATESTRs{index}, '\PFC_PE_Data.mat'];
    params.windowGranger = [0, 500]; % ms
    params.trialType = 1; % 1-dev, 2-std
    Granger_ProcessFcn(params);
    params.trialType = 2; % 1-dev, 2-std
    Granger_ProcessFcn(params);
    
    params.protocolType = 2; % 1-PE, 2-DM, 3-Prediction
    params.DATAPATH{1} = [SINGLEROOTPATH, 'DM\', DATESTRs{index}, '\AC_DM_Data.mat'];
    params.DATAPATH{2} = [SINGLEROOTPATH, 'DM\', DATESTRs{index}, '\PFC_DM_Data.mat'];
    params.windowGranger = [0, 500]; % ms
    params.trialType = 1; % 1-correct, 2-wrong
    Granger_ProcessFcn(params);
    params.trialType = 2; % 1-correct, 2-wrong
    Granger_ProcessFcn(params);
    
    params.protocolType = 3; % 1-PE, 2-DM, 3-Prediction
    params.DATAPATH{1} = [SINGLEROOTPATH, 'Prediction\', DATESTRs{index}, '\AC_Prediction_Data.mat'];
    params.DATAPATH{2} = [SINGLEROOTPATH, 'Prediction\', DATESTRs{index}, '\PFC_Prediction_Data.mat'];
    params.windowGranger = [0, 1000];
    Granger_ProcessFcn(params);
    params.windowGranger = [1000, 3500];
    Granger_ProcessFcn(params);

    params = rmfield(params, "DATAPATH");
end

%% Population ----------------------------------------------------------------
params.DATESTRs = DATESTRs;
params.PrePATH = [POPUROOTPATH, 'Preprocess\'];
params.dataOnlyOpt = "off"; % "on" will save data only

%% PE
params.MONKEYPATH = [POPUROOTPATH, 'PE\'];
params.AREANAME = 'AC';
params.posIndex = 1; % 1-AC, 2-PFC
params.SINGLEPATH = [];
for index = 1:length(DATESTRs)
    params.SINGLEPATH{index, 1} = [SINGLEROOTPATH, 'PE\', DATESTRs{index}, '\AC_PE_Data.mat'];
end
PE_ProcessFcn(params);

params.AREANAME = 'PFC';
params.posIndex = 2; % 1-AC, 2-PFC
params.SINGLEPATH = [];
for index = 1:length(DATESTRs)
    params.SINGLEPATH{index, 1} = [SINGLEROOTPATH, 'PE\', DATESTRs{index}, '\PFC_PE_Data.mat'];
end
PE_ProcessFcn(params);

%% DM
params.MONKEYPATH = [POPUROOTPATH, 'DM\'];
params.AREANAME = 'AC';
params.posIndex = 1; % 1-AC, 2-PFC
params.SINGLEPATH = [];
for index = 1:length(DATESTRs)
    params.SINGLEPATH{index, 1} = [SINGLEROOTPATH, 'DM\', DATESTRs{index}, '\AC_DM_Data.mat'];
end
DM_ProcessFcn(params);

params.AREANAME = 'PFC';
params.posIndex = 2; % 1-AC, 2-PFC
params.SINGLEPATH = [];
for index = 1:length(DATESTRs)
    params.SINGLEPATH{index, 1} = [SINGLEROOTPATH, 'DM\', DATESTRs{index}, '\PFC_DM_Data.mat'];
end
DM_ProcessFcn(params);

%% Prediction
params.MONKEYPATH = [POPUROOTPATH, 'Prediction\'];
params.AREANAME = 'AC';
params.posIndex = 1; % 1-AC, 2-PFC
params.SINGLEPATH = [];
for index = 1:length(DATESTRs)
    params.SINGLEPATH{index, 1} = [SINGLEROOTPATH, 'Prediction\', DATESTRs{index}, '\AC_Prediction_Data.mat'];
end
Prediction_ProcessFcn(params);

params.AREANAME = 'PFC';
params.posIndex = 2; % 1-AC, 2-PFC
params.SINGLEPATH = [];
for index = 1:length(DATESTRs)
    params.SINGLEPATH{index, 1} = [SINGLEROOTPATH, 'Prediction\', DATESTRs{index}, '\PFC_Prediction_Data.mat'];
end
Prediction_ProcessFcn(params);

%% Compare single
params.MONKEYPATH = [POPUROOTPATH, 'Compare\'];
params.DATAPATH = [];
params.DATAPATH{1} = [POPUROOTPATH, 'PE\AC_PE_tuning.mat'];
params.DATAPATH{2} = [POPUROOTPATH, 'PE\PFC_PE_tuning.mat'];
params.DATAPATH{3} = [POPUROOTPATH, 'DM\AC_DM_tuning.mat'];
params.DATAPATH{4} = [POPUROOTPATH, 'DM\PFC_DM_tuning.mat'];
Compare_ProcessFcn(params);

%% Granger
params.DATAPATH = [];

% smooth
% params.MONKEYPATH = [POPUROOTPATH, 'Granger\'];
% params.nSmooth = 2;

% no smooth
params.MONKEYPATH = [POPUROOTPATH, 'Granger (no smoothing)\'];
params.nSmooth = 1;

params.protocolType = 1; % 1-PE, 2-DM, 3-Prediction
params.DATAPATH{1} = [POPUROOTPATH, 'PE\AC_PE_Data.mat'];
params.DATAPATH{2} = [POPUROOTPATH, 'PE\PFC_PE_Data.mat'];
params.windowGranger = [200, 500]; % ms
params.trialType = 1; % 1-dev, 2-std
Granger_ProcessFcn(params);
params.trialType = 2; % 1-dev, 2-std
Granger_ProcessFcn(params);

% params.protocolType = 2; % 1-PE, 2-DM, 3-Prediction
% params.DATAPATH{1} = [POPUROOTPATH, 'DM\AC_DM_Data.mat'];
% params.DATAPATH{2} = [POPUROOTPATH, 'DM\PFC_DM_Data.mat'];
% params.windowGranger = [0, 500]; % ms
% params.trialType = 1; % 1-correct, 2-wrong
% Granger_ProcessFcn(params);
% params.trialType = 2; % 1-correct, 2-wrong
% Granger_ProcessFcn(params);
% 
% params.protocolType = 3; % 1-PE, 2-DM, 3-Prediction
% params.DATAPATH{1} = [POPUROOTPATH, 'Prediction\AC_Prediction_Data.mat'];
% params.DATAPATH{2} = [POPUROOTPATH, 'Prediction\PFC_Prediction_Data.mat'];
% params.windowGranger = [0, 500];
% Granger_ProcessFcn(params);
% params.windowGranger = [3000, 3500];
% Granger_ProcessFcn(params);

%% Granger PT
params.DATAPATH = [];

% smooth
params.MONKEYPATH = [POPUROOTPATH, 'Granger PT\'];
params.nSmooth = 2;

% no smooth
% params.MONKEYPATH = [POPUROOTPATH, 'Granger PT (no smoothing)\'];
% params.nSmooth = 1;

params.protocolType = 1; % 1-PE, 2-DM, 3-Prediction
params.DATAPATH{1} = [POPUROOTPATH, 'PE\AC_PE_Data.mat'];
params.DATAPATH{2} = [POPUROOTPATH, 'PE\PFC_PE_Data.mat'];
params.windowGranger = [0, 500]; % ms
params.trialType = 1; % 1-dev, 2-std
GrangerPT_ProcessFcn(params);
params.trialType = 2; % 1-dev, 2-std
GrangerPT_ProcessFcn(params);

params.protocolType = 2; % 1-PE, 2-DM, 3-Prediction
params.DATAPATH{1} = [POPUROOTPATH, 'DM\AC_DM_Data.mat'];
params.DATAPATH{2} = [POPUROOTPATH, 'DM\PFC_DM_Data.mat'];
params.windowGranger = [0, 500]; % ms
params.trialType = 1; % 1-correct, 2-wrong
GrangerPT_ProcessFcn(params);
params.trialType = 2; % 1-correct, 2-wrong
GrangerPT_ProcessFcn(params);

params.protocolType = 3; % 1-PE, 2-DM, 3-Prediction
params.DATAPATH{1} = [POPUROOTPATH, 'Prediction\AC_Prediction_Data.mat'];
params.DATAPATH{2} = [POPUROOTPATH, 'Prediction\PFC_Prediction_Data.mat'];
params.windowGranger = [0, 500];
GrangerPT_ProcessFcn(params);
params.windowGranger = [3000, 3500];
GrangerPT_ProcessFcn(params);
