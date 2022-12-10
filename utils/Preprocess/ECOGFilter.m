function varargout = ECOGFilter(dataset, fhp, flp, varargin)
    % Description: perform band pass filter on data
    % Input:
    %     dataset:
    %         1. ECOGDataset: TDT dataset of [LAuC] or [LPFC]
    %         2. trialsECOG: n*1 cell array of trial data (64*m matrix)
    %     fhp: high pass cutoff frequency
    %     flp: low pass cutoff frequency
    %     fs: sample rate of dataset
    % Output:
    %     1. dataset: result of filtered dataset
    %     2. trialsECOG: result of filtered data
    % Example:
    %     ECOGDataset = ECOGFilter(ECOGDataset, 0.1, 10);
    %     trialsECOG = ECOGFilter(trialsECOG, 0.1, 10, fs);

    mIp = inputParser;
    mIp.addRequired("dataset");
    mIp.addRequired("fhp", @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
    mIp.addRequired("flp", @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
    mIp.addOptional("fs", [], @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
    mIp.parse(dataset, fhp, flp, varargin{:});

    fs = mIp.Results.fs;

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
        error("fs input missing for filtering trial data");
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

    %% Filter
    disp("Filtering...");
    cfg = [];
    cfg.demean = 'no';
    cfg.lpfilter = 'yes';
    cfg.lpfreq = flp;
    cfg.hpfilter = 'yes';
    cfg.hpfreq = fhp;
    cfg.hpfiltord = 3;
    cfg.dftfilter = 'yes';
    cfg.dftfreq = [50 100 150]; % line noise frequencies in Hz for DFT filter (default = [50 100 150])
    data = ft_preprocessing(cfg, data);

    %% output
    if isstruct(dataset)
        dataset.data = data.trial{1};
        varargout{1} = dataset;
    else
        varargout{1} = data.trial';
    end

    return;
end
