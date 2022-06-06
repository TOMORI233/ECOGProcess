%% Data loading
clear; clc; close all;
% BLOCKPATH = 'E:\ECoG\TDT Data\chouchou\cc20220517\Block-9';
% BLOCKPATH = 'E:\ECoG\TDT Data\chouchou\cc20220518\Block-2';
% BLOCKPATH = 'E:\ECoG\TDT Data\chouchou\cc20220519\Block-4';
% BLOCKPATH = 'E:\ECoG\TDT Data\chouchou\cc20220520\Block-2';
BLOCKPATH = 'E:\ECoG\TDT Data\chouchou\cc20220525\Block-2';
% BLOCKPATH = 'E:\ECoG\TDT Data\chouchou\cc20220530\Block-2';
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

%% Parameter setting
fs = 300; % Hz, for downsampling

%% Processing
trialAll = PassiveProcess_7_10Freq(epocs);
devFreqAll = [trialAll.devFreq];
stdFreqAll = cellfun(@(x) x(1), {trialAll.freqSeq});
dRatioAll = roundn(devFreqAll ./ stdFreqAll, -2);
dRatio = unique(dRatioAll);
dRatio(dRatio == 0) = [];

%% Prediction
window = [-2500, 6000]; % ms
[chMean, ~] = joinSTD(trialAll, ECOGDataset, window);
FigP(1) = plotRawWave(chMean, [], window);
drawnow;
FigP(2) = plotTFA(chMean, fs0, fs, window);
drawnow;

%% Prediction error
window = [-2000, 2000]; % ms

for dIndex = 1:length(dRatio)
    trials = trialAll(dRatioAll == dRatio(dIndex));
    [~, chMean, chStd] = selectEcog(ECOGDataset, trials, "dev onset", window);
    FigPE1(dIndex) = plotRawWave(chMean, chStd, window, ['dRatio=', num2str(dRatio(dIndex)), '(N=', num2str(length(trials)), ')']);
    drawnow;
    FigPE2(dIndex) = plotTFA(chMean, fs0, fs, window, ['dRatio=', num2str(dRatio(dIndex)), '(N=', num2str(length(trials)), ')']);
    drawnow;
end

% Scale
scaleAxes([FigPE1, FigPE2], "x", [-500, 1000]);
scaleAxes([FigP(1), FigPE1], "y", [-80, 80]);
scaleAxes([FigP(2), FigPE2], "c", [], [0, 20]);

%% Layout
plotLayout([FigP(1), FigPE1], posIndex);