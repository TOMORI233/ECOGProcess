clear; clc; close all;
BLOCKPATH = 'G:\ECoG\chouchou\cc20220803\Block-1';
data = TDTbin2mat(BLOCKPATH);
fs0 = data.streams.LAuC.fs;
wave = data.streams.LAuC.data;

%% Preprocessing
ECOGDataset = data.streams.LAuC;
channels = ECOGDataset.channels;
trialsECOG = {ECOGDataset.data};
t = linspace(0, size(trialsECOG{1}, 2) / fs0, size(trialsECOG{1}, 2));

plotRawWave(wave, [], [0, t(end) * 1000]);

cfg = [];
data = [];
cfg.trials = true(length(trialsECOG), 1);
data.trial = trialsECOG';
data.time = {t};
data.label = cellfun(@(x) num2str(x), num2cell(channels)', 'UniformOutput', false);
data.fsample = fs0;
data.trialinfo = 1;
data.sampleinfo = [0, size(trialsECOG{1}, 2)];
data = ft_selectdata(cfg, data);

cfg = [];
cfg.demean = 'no';
cfg.lpfilter = 'yes';
cfg.lpfreq = 50;
cfg.hpfilter = 'yes';
cfg.hpfreq = 0.5;
cfg.hpfiltord = 3;
cfg.dftfreq       = [50 100 150]; % line noise frequencies in Hz for DFT filter (default = [50 100 150])
data = ft_preprocessing(cfg, data);

plotRawWave(data.trial{1}, [], [0, t(end) * 1000]);
plotTFA(data.trial{1}, fs0, 300, [0, t(end) * 1000]);