
clear; clc; close all;
%% Parameter setting
BLOCKPATH = 'E:\ECoG\chouchou\cc20220618\Block-1';
params.posIndex = 1; % 1-AC, 2-PFC
params.choiceWin = [100, 800];
params.processFcn = @ActiveProcess_clickTrainWM;
fs = 500; % Hz, for downsampling
temp = TDTbin2mat(BLOCKPATH,'T2',1);
fs0 = temp.streams.LAuC.fs;
[trialAll, ~] = ECOGPreprocess(BLOCKPATH, params, 1);
% trialAll(120).soundOnsetSeq(1) / fs0

temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'streams'}, 'STORE', posStr(posIndex));
streams = temp.streams;

ECOGDataset = streams.(posStr(posIndex));
fs0 = ECOGDataset.fs;

%% check waveform
figure
plot(ECOGDataset.data(42,:));
%% merge blocks
% BLOCKPATH1 = 'E:\ECoG\chouchou\cc20220606\Block-1';
% BLOCKPATH2 = 'E:\ECoG\chouchou\cc20220606\Block-2';
% data1 = TDTbin2mat(BLOCKPATH1,'T2',480);
% data2 = TDTbin2mat(BLOCKPATH2);
% opts.sfNames = posStr(posIndex);
% opts.efNames = ["num0", "push", "erro", "ordr"];
% data = joinBlocks(opts, data1, data2);
% epocs = data.epocs;
% ECOGDataset = data.streams.(posStr(posIndex));
% fs0 = ECOGDataset.fs;