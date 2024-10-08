function comp = mICA(dataset, windowICA, arg3, varargin)
% Description: Split data by trials, window and segOption. Filter and
%              resample data. Perform ICA on data.
% Input:
%     dataset:
%         1. ECOGDataset: TDT dataset of [LAuC] or [LPFC]
%         2. trialsECOG: n*1 cell array of trial data (64*m matrix)
%     windowICA: 2*1 vector of time window of trial data, in ms
%     arg3:
%         1. trials: n*1 struct array of trial information
%         2. fs: ECOGDataset.fs, Hz
%     fsD: sample rate for downsampling, < fs
%     segOption: "trial onset" | "dev onset" | "push onset" | "last std"
%     chs2doICA: channel number to perform ICA on (e.g. [1:25,27:64], default='all')
% Output:
%     comp: result of ICA (FieldTrip)
% Example:
%     comp = mICA(ECOGDataset, windowICA, trials, [fsD], [segOption]);
%     comp = mICA(trialsECOG, windowICA, fs, [fsD]);

ft_setPath2Top;

mIp = inputParser;
mIp.addRequired("dataset");
mIp.addRequired("windowICA", @(x) validateattributes(x, {'numeric'}, {'2d', 'increasing'}));
mIp.addRequired("arg3", @(x) isnumeric(x) || isstruct(x));
mIp.addOptional("fsD", [], @(x) validateattributes(x, {'numeric'}, {'numel', 1, 'positive'}));
mIp.addOptional("segOption", "trial onset", @(x) any(validatestring(x, {'trial onset', 'dev onset', 'push onset', 'last std'})));
mIp.addParameter("chs2doICA", 'all');
mIp.parse(dataset, windowICA, arg3, varargin{:});

ft_setPath2Top;

fsD = mIp.Results.fsD;
segOption = mIp.Results.segOption;
chs2doICA = mIp.Results.chs2doICA;

switch class(arg3)
    case 'double'
        fs = arg3;
    case 'struct'
        trials = arg3;
    otherwise
        error("Invalid syntax");
end

switch class(dataset)
    case 'cell'
        trialsECOG = dataset;
        channels = 1:size(trialsECOG{1}, 1);
        sampleinfo = ones(length(trialsECOG), 2);
    case 'struct'
        ECOGDataset = dataset;
        fs = ECOGDataset.fs;
        channels = ECOGDataset.channels;
        [trialsECOG, ~, ~, sampleinfo] = selectEcog(ECOGDataset, trials, segOption, windowICA);
    otherwise
        error("Invalid syntax");
end

if ~strcmp(chs2doICA, 'all')
    temp = channels;
    temp(~ismember(temp, chs2doICA)) = [];
    chs2doICA = cellfun(@(x) num2str(x), num2cell(temp)', 'UniformOutput', false);
end

%% Preprocessing
disp("Preprocessing...");
t = linspace(windowICA(1), windowICA(2), size(trialsECOG{1}, 2)) / 1000;

cfg = [];
cfg.trials = 'all';
data.trial = trialsECOG';
data.time = repmat({t}, 1, length(trialsECOG));
data.label = cellfun(@(x) num2str(x), num2cell(channels)', 'UniformOutput', false);
data.fsample = fs;
data.trialinfo = ones(length(trialsECOG), 1);
data.sampleinfo = sampleinfo;
data = ft_selectdata(cfg, data);

%% Resampling
disp("Resampling...");

if ~isempty(fsD) && fsD < fs
    cfg = [];
    cfg.resamplefs = fsD;
    cfg.trials = 'all';
    data = ft_resampledata(cfg, data);
else
    warning("Sample rate [fsD] for resampling should not be greater than raw sample rate [fs]. Skip resampling.");
end

%% ICA
disp("Performing ICA...");
cfg = [];
cfg.method = 'runica'; % default
% cfg.method = 'fastica';
cfg.channel = chs2doICA;
comp = ft_componentanalysis(cfg, data);

disp("ICA done.");
return;
end