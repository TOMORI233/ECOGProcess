clear; clc; close all;

BLOCKPATH = 'E:\ECoG\TDT Data\chouchou\cc20220530\Block-3';
posIndex = 1; % 1-AC, 2-PFC
posStr = ["LAuC", "LPFC"];

temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs'});
epocs = temp.epocs;

temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'streams'}, 'STORE', posStr(posIndex));
streams = temp.streams;

ECOGDataset = streams.(posStr(posIndex));
fs0 = ECOGDataset.fs;

AREANAME = ["AC", "PFC"];
temp = string(split(BLOCKPATH, '\'));
DateStr = temp(end - 1);

%% Processing
trialAll = CTScreeningProcess(epocs);

%% Plot
window = [0, 500];
freqAll = unique([trialAll.freq])';
chData = struct('chMean', cell(length(freqAll), 1));

for fIndex = 1:length(freqAll)
    trials = trialAll([trialAll.freq] == freqAll(fIndex));
    [~, chMean, ~] = selectEcog(ECOGDataset, trials, "trial onset", window);
    chData(fIndex).chMean = chMean;
end

plotRawWaveMulti(chData, window, "CT Screening");