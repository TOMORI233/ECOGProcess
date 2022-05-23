
clear; clc; close all;
%% load TDT data
BLOCKPATH = 'G:\ECoG\chouchou\cc20220521\Block-1';
data = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs','streams'});

%% define basic infomation
rootPath = 'E:\ECoG\processedData';
recordingTech = 'ECoG';
region = 'ACPFC';
sitePos = 'Connector';
AnimalCode = 'CC';

% daily change
Date = '20220523';
ProtocolName = 'PEOddLongTerm';

%% define and create save path
% rootpath\recordingTech\region\date\animalCode_sitePos\protocolName
savaPath = fullfile(rootPath,recordingTech,region,Date,[AnimalCode '_' sitePos],ProtocolName);

if ~exist(savePath,'dir')
    mkdir(savaPath = fullfile(rootPath,recordingTech,region,Date,[AnimalCode '_' sitePos],ProtocolName));
end

cd(savePath)
save data.mat data;

