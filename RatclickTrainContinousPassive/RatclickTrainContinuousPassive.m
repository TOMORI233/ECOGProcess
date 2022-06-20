

%% Parameter setting
clear; clc; close all;
posStr = ["LAuC", "LPFC"];
params.posIndex = 1; % 1-AC, 2-PFC
posIndex = params.posIndex;
params.processFcn = @PassiveProcess_clickTrainContinuous;

fs = 500; % Hz, for downsampling


%% Processing
BLOCKPATH = 'E:\ECoG\HQYrat2\20220613\Block-3';

if contains(BLOCKPATH,'HQY')
    params.posIndex = 3; % 1-AC, 2-PFC
    posIndex = params.posIndex;
end

[trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH, params);

if ~isempty(ECOGDataset)
    fs0 = ECOGDataset.fs;
end

%% title & labels
stimStr = {'4-4.2ms Reg','4.2-4ms Reg','4-4.2ms Irreg','4.2-4ms Irreg'};
% S1Duration = [5005, 5255.3, 5000.2, 5250.2];
S1Duration = [2002.1, 2102.2, 2000.2, 2100.2];
Paradigm = 'ClickTrainSSALongTerm4';


%% Data saving params
temp = string(split(BLOCKPATH, '\'));
DateStr = temp(end - 1);
AREANAME = {'AC', 'PFC', 'ratAC'};
ROOTPATH = fullfile('E:\ECoG\ECoGClickTrainContinuous',DateStr,Paradigm);


%% ICA
devType = unique([trialAll.devOrdr]);
window = [0, 5000]; %=
topoSize = [8, 8];
if contains(BLOCKPATH,'HQY')
    topoSize = [4, 2];
    ECOGDatasetCopy = ECOGDataset;
    ECOGDataset.channels = 1:8;
    ECOGDataset.data = ECOGDatasetCopy.data(1:8,:);
end




[comp, trialsECOG] = mICA(ECOGDataset, trialAll, window, "dev onset", fs);

Fig1 = plotTopo(comp, topoSize);




%%
for dIndex = 1:length(devType)
    S = cellfun(@(x) comp.unmixing * x, trialsECOG([trialAll.devOrdr] == devType(dIndex)), "UniformOutput", false);
    chMean = cell2mat(cellfun(@mean, changeCellRowNum(S), "UniformOutput", false)) * 1e6;
    trials = trialAll([trialAll.devOrdr] == devType(dIndex));
    FigDev_Wave(dIndex) = plotRawWave(chMean, [], window - S1Duration(dIndex), ['IC, stiTyme: ', num2str(stimStr{dIndex}), '(N=', num2str(length(trials)), ')']);
    drawnow;
    FigDev_TFA(dIndex) = plotTFA(chMean, fs0, fs, window - S1Duration(dIndex), ['IC, stiTyme: ', num2str(stimStr{dIndex}), '(N=', num2str(length(trials)), ') ']);
    drawnow

end

setAxes([FigDev_Wave, FigDev_TFA], "xticklabel", setAxes([FigDev_Wave, FigDev_TFA], "xtick"));
% Scale
scaleAxes(FigDev_Wave, "y", [-10, 10]);
%     scaleAxes(FigDev_TFA, "c", [], [0, 20]);



%%


%
%     %saveFigures
%     devPath = fullfile(ROOTPATH,'ICAReulst');
%     if ~exist(devPath,"dir")
%         mkdir(devPath)
%     end
%     for figN = 1 : length(FigDev_Wave)
%         saveas(FigDev_Wave(figN),strcat(fullfile(devPath,stimStr{figN}), '_',  AREANAME{posIndex}, '_Waveform.jpg'));
%         saveas(FigDev_TFA(figN),strcat(fullfile(devPath,stimStr{figN}), '_',  AREANAME{posIndex}, '_TimeFrequency.jpg'));
%     end


%% ECoG Result
devType = unique([trialAll.devOrdr]);

for dIndex = 1:length(devType)

    trials = trialAll([trialAll.devOrdr] == devType(dIndex));
    [~, chMean, chStd] = selectEcog(ECOGDataset, trials, "trial onset", window);
    FigDev_Wave2(dIndex) = plotRawWave(chMean, chStd, window - S1Duration(dIndex), ['stiTyme: ', num2str(stimStr{dIndex}), '(N=', num2str(length(trials)), ')']);
    drawnow;
    FigDev_TFA2(dIndex) = plotTFA(chMean, fs0, fs, window - S1Duration(dIndex), ['stiTyme: ', num2str(stimStr{dIndex}), '(N=', num2str(length(trials)), ') ']);
    drawnow
end

% Scale
setAxes([FigDev_Wave, FigDev_TFA], "xticklabel", setAxes([FigDev_Wave, FigDev_TFA], "xtick"));

scaleAxes(FigDev_Wave2, "y", [-80, 80]);
scaleAxes(FigDev_TFA2, "c", [], [0, 20]);


%     % Layout
%     plotLayout(FigDev_Wave2, posIndex);
%
%     %saveFigures
%     devPath2 = fullfile(ROOTPATH,'rawDataResult');
%     if ~exist(devPath2,"dir")
%         mkdir(devPath2)
%     end
%     for figN = 1 : length(FigDev_Wave2)
%         saveas(FigDev_Wave2(figN),strcat(fullfile(devPath2,stimStr{figN}), '_',  AREANAME{posIndex}, '_Waveform.jpg'));
%         saveas(FigDev_TFA2(figN),strcat(fullfile(devPath2,stimStr{figN}), '_',  AREANAME{posIndex}, '_TimeFrequency.jpg'));
%     end

%%
% close all;


