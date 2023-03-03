function varargout = ECOGResample(dataset, fResample, varargin)
    % Description: resample data
    % Input:
    %     dataset:
    %         1. ECOGDataset: TDT dataset of [LAuC] or [LPFC]
    %         2. trialsECOG: n*1 cell array of trial data (64*m matrix)
    %     fResample: resample rate
    %     fs: sample rate of dataset
    % Output:
    %     dataset:
    %         1. ECOGDataset: result of resampled dataset
    %         2. trialsECOG: result of resampled data
    %     fResample
    % Example:
    %     fd = 300;
    %     ECOGDataset = ECOGResample(ECOGDataset, fd);
    %     trialsECOG = ECOGResample(trialsECOG, fd, fs);

    mIp = inputParser;
    mIp.addRequired("dataset");
    mIp.addRequired("fResample", @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
    mIp.addOptional("fs", [], @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
    mIp.parse(dataset, fResample, varargin{:});

    switch class(dataset)
        case 'cell'
            trialsECOG = dataset;
            channels = 1:size(trialsECOG{1}, 1);
            sampleinfo = ones(length(trialsECOG), 2);
        case 'struct'
            trialsECOG = {dataset.data};
            fs = dataset.fs;
            channels = dataset.channels;
            sampleinfo = [1, size(dataset.data, 2)];
        otherwise
            error("Invalid syntax");
    end

    if isempty(fs)
        error("fs input missing for resampling trial data");
    end

    %% Preprocessing
    disp("Preprocessing...");
    t = (1 : size(trialsECOG{1}, 2)) / fs;
    cfg = [];
    cfg.trials = 'all';
    data.trial = trialsECOG';
    data.time = repmat({t}, 1, length(trialsECOG));
    data.label = cellfun(@(x) num2str(x), num2cell(channels)', 'UniformOutput', false);
    data.fsample = fs;
    data.trialinfo = ones(length(trialsECOG), 1);
    data.sampleinfo = sampleinfo;
    data = ft_selectdata(cfg, data);

    %% Resample
    disp("Resampling...");
    cfg = [];
    cfg.resamplefs = fResample;
    cfg.trials = 'all';
    data = ft_resampledata(cfg, data);

    %% output
    if isstruct(dataset)
        dataset.data = data.trial{1};
        dataset.fs = fResample;
        varargout{1} = dataset;
    else
        varargout{1} = data.trial';
    end

    varargout{2} = fResample;

    return;
end
