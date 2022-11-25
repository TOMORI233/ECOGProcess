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
    % Output:
    %     comp: result of ICA (FieldTrip)
    % Example:
    %     comp = mICA(ECOGDataset, windowICA, trials, [fsD], [segOption]);
    %     comp = mICA(trialsECOG, windowICA, fs, [fsD]);

    mInputParser = inputParser;
    mInputParser.addRequired("dataset");
    mInputParser.addRequired("windowICA", @(x) validateattributes(x, {'numeric'}, {'2d', 'increasing'}));
    mInputParser.addRequired("arg3", @(x) isnumeric(x) || isstruct(x));
    mInputParser.addOptional("fsD", 500, @(x) validateattributes(x, {'numeric'}, {'numel', 1, 'positive'}));
    mInputParser.addOptional("segOption", "trial onset", @(x) any(validatestring(x, {'trial onset', 'dev onset', 'push onset', 'last std'})));
    mInputParser.parse(dataset, windowICA, arg3, varargin{:});

    fsD = mInputParser.Results.fsD;
    segOption = mInputParser.Results.segOption;

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

    % Filter
    cfg = [];
    cfg.demean = 'no';
    cfg.lpfilter = 'yes';
    cfg.lpfreq = 50;
    cfg.hpfilter = 'yes';
    cfg.hpfreq = 0.5;
    cfg.hpfiltord = 3;
    cfg.dftfreq = [50 100 150]; % line noise frequencies in Hz for DFT filter (default = [50 100 150])
    data = ft_preprocessing(cfg, data);

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
    cfg.method = 'runica';
    comp = ft_componentanalysis(cfg, data);

    disp("ICA done.");
    return;
end
