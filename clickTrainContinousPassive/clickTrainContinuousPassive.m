

%% Parameter setting
clear; clc; close all;
params.posIndex = 3; % 1-AC, 2-PFC
posIndex = params.posIndex;
params.choiceWin = [100, 800];
params.processFcn = @PassiveProcess_clickTrainContinuous;

fs = 500; % Hz, for downsampling

%% Processing
% BLOCKPATH = 'E:\ECoG\chouchou\cc20220601\Block-4';
BLOCKPATH = 'E:\ECoG\HQYrat2\20220611\Block-2';

[trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH, params);

if ~isempty(ECOGDataset)
    fs0 = ECOGDataset.fs;
end
%% Data saving params
temp = string(split(BLOCKPATH, '\'));
DateStr = temp(end - 1);
Paradigm = 'ClickTrainContinuousPassive';
AREANAME = {'AC', 'PFC', 'ratAC'};
ROOTPATH = fullfile('E:\ECoG\ECoGBehaviorResult',Paradigm,DateStr);

%% title & labels
stimStr = {'4ms Reg','4.06ms Reg','4ms Irreg','4.06ms Irreg'};
posStr = ["LAuC", "LPFC"];

%% ICA
window = [0, 11000]; %=
ECOGDatasetCopy = ECOGDataset;
ECOGDataset.channels = 1:8;
ECOGDataset.data = ECOGDatasetCopy.data(1:8,:);
[comp, trialsECOG] = mICA(ECOGDataset, trialAll, window, "dev onset", fs);
S = cellfun(@(x) comp.unmixing * x, trialsECOG, "UniformOutput", false);
chMean = cell2mat(cellfun(@mean, changeCellRowNum(S), "UniformOutput", false)) * 1e6;

plotRawWave(chMean, [], window, "ICA");
plotTFA(chMean, fs0, fs, window, "ICA");
Fig1 = plotTopo(comp);
scaleAxes(Fig1, "c");


%% ECoG Result
devType = unique([trialAll.devOrdr]);
window = [0, 11000]; %=
for dIndex = 1:length(devType)

    trials = trialAll([trialAll.devOrdr] == devType(dIndex));
    [~, chMean, chStd] = selectEcog(ECOGDataset, trials, "trial onset", window);
    FigDev_Wave(dIndex) = plotRawWave(chMean, chStd, window, ['stiTyme: ', num2str(stimStr{dIndex}), '(N=', num2str(length(trials)), ')']);
    drawnow;
    FigDev_TFA(dIndex) = plotTFA(chMean, fs0, fs, window, ['stiTyme: ', num2str(stimStr{dIndex}), '(N=', num2str(length(trials)), ') ']);
    drawnow
end

% Scale
xticks = setAxes([FigDev_Wave,FigDev_TFA], 'xtick');
setAxes([FigDev_Wave,FigDev_TFA], 'xticklabel', xticks);
scaleAxes([FigDev_Wave,FigDev_TFA], "x", [0, 11000]);
scaleAxes(FigDev_Wave, "y", [-80, 80]);
scaleAxes(FigDev_TFA, "c", [], [0, 20]);

% Layout
plotLayout(FigDev_Wave, posIndex);

% saveFigures
% devPath = fullfile(ROOTPATH,'deviantResponse');
% if ~exist(devPath,"dir")
%     mkdir(devPath)
% end
% for figN = 1 : length(FigDev_Wave1_3)
%     saveas(FigDev_Wave1_3(figN),strcat(fullfile(devPath,pairStr{figN}), '_',  AREANAME{posIndex}, '_Waveform.jpg'));
%     saveas(FigDev_TFA1_3(figN),strcat(fullfile(devPath,pairStr{figN}), '_',  AREANAME{posIndex}, '_TimeFrequency.jpg'));
%      saveas(FigDev_Wave4_6(figN),strcat(fullfile(devPath,pairStr{figN}), '_',  AREANAME{posIndex}, '_Waveform.jpg'));
%     saveas(FigDev_TFA4_6(figN),strcat(fullfile(devPath,pairStr{figN}), '_',  AREANAME{posIndex}, '_TimeFrequency.jpg'));
%      saveas(FigDev_Wave7_9(figN),strcat(fullfile(devPath,pairStr{figN}), '_',  AREANAME{posIndex}, '_Waveform.jpg'));
%     saveas(FigDev_TFA7_9(figN),strcat(fullfile(devPath,pairStr{figN}), '_',  AREANAME{posIndex}, '_TimeFrequency.jpg'));
% end




%%
close all;