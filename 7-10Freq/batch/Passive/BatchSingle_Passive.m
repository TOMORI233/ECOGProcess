%% Process data of each day and batch processed data of each day
clear; clc; close all;

params.choiceWin = [100, 600];
params.processFcn = @PassiveProcess_7_10Freq;

params.monkeyID = 2; % 1-CC, 2-XX

CURRENTPATH = pwd;

if params.monkeyID == 1
    params.ROOTPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\CC\7-10Freq Passive\';
    DATESTRs = {'cc20220520', 'cc20220801', 'cc20220814', 'cc20221014', 'cc20221015'};
    POPUROOTPATH = [CURRENTPATH, '\CC\Population\'];
    SINGLEROOTPATH = [CURRENTPATH, '\CC\Single\'];
else
    params.ROOTPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\XX\7-10Freq Passive\';
    DATESTRs = {'xx20220711', 'xx20220820', 'xx20220822', 'xx20220913', 'xx20220914'};
    POPUROOTPATH = [CURRENTPATH, '\XX\Population\'];
    SINGLEROOTPATH = [CURRENTPATH, '\XX\Single\'];
end

params = windowConfig_7_10Freq(params);

%% Single day ----------------------------------------------------------------
params.dataOnlyOpt = "off"; % "on" will save data only

for index = 1:length(DATESTRs)
    params.DATESTRs = DATESTRs(index);
    params.PrePATH = [SINGLEROOTPATH, 'Preprocess\', DATESTRs{index}, '\'];

    % Exclude trials and bad channels
    params.icaOpt = "on"; % "on" here will perform ICA on all channels and decide bad channels after ICA
    params.userDefineOpt = "on";
    Pre_ProcessFcn(params);

    params.normOpt = "on"; % normalization option

    % PE
    params.icaOpt = "on"; % "off" in preprocess and "on" here will perform ICA on good channels
    params.MONKEYPATH = [SINGLEROOTPATH, 'PE\', DATESTRs{index}, '\'];
    params.AREANAME = 'AC';
    params.posIndex = 1; % 1-AC, 2-PFC
    PE_ProcessFcn(params);
    params.AREANAME = 'PFC';
    params.posIndex = 2; % 1-AC, 2-PFC
    PE_ProcessFcn(params);

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

    % Granger
    params.MONKEYPATH = [SINGLEROOTPATH, 'Granger\', DATESTRs{index}, '\'];
    params.DATAPATH = [];
    
    params.protocolType = 1; % 1-PE, 2-DM, 3-Prediction
    params.DATAPATH{1} = [SINGLEROOTPATH, 'PE\', DATESTRs{index}, '\AC_PE_Data.mat'];
    params.DATAPATH{2} = [SINGLEROOTPATH, 'PE\', DATESTRs{index}, '\PFC_PE_Data.mat'];
    params.windowGranger = [0, 500]; % ms
    params.trialType = 1; % 1-dev, 2-std
    Granger_ProcessFcn(params);
    params.trialType = 2; % 1-dev, 2-std
    Granger_ProcessFcn(params);
    
    params.protocolType = 3; % 1-PE, 2-DM, 3-Prediction
    params.DATAPATH{1} = [SINGLEROOTPATH, 'Prediction\', DATESTRs{index}, '\AC_Prediction_Data.mat'];
    params.DATAPATH{2} = [SINGLEROOTPATH, 'Prediction\', DATESTRs{index}, '\PFC_Prediction_Data.mat'];
    params.windowGranger = [0, 500];
    Granger_ProcessFcn(params);
    params.windowGranger = [3000, 3500];
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

%% Granger
params.DATAPATH = [];

params.MONKEYPATH = [POPUROOTPATH, 'Granger (no smoothing)\'];
params.nSmooth = 1;

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

params.protocolType = 3; % 1-PE, 2-DM, 3-Prediction
params.DATAPATH{1} = [POPUROOTPATH, 'Prediction\AC_Prediction_Data.mat'];
params.DATAPATH{2} = [POPUROOTPATH, 'Prediction\PFC_Prediction_Data.mat'];
params.windowGranger = [0, 500];
Granger_ProcessFcn(params);
params.windowGranger = [3000, 3500];
Granger_ProcessFcn(params);