%% normal load settings
temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs'});
epocs = temp.epocs;

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