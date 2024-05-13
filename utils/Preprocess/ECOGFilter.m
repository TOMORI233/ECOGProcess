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
    mIp.addParameter("Notch", "off", @(x) any(validatestring(x, {'on', 'off'})));
    mIp.addParameter("fNotch", 50, @(x) validateattributes(x, {'numeric'}, {'positive', 'vector'}));
    mIp.parse(dataset, fhp, flp, varargin{:});

    fs = mIp.Results.fs;
    NotchOpt = mIp.Results.Notch;
    fNotch = mIp.Results.fNotch;

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
        error("ECOGFilter(): fs input missing for filtering trial data");
    end

    if any(fNotch > fs / 2)
        error("ECOGFilter(): Notch frequency should not exceed fs/2");
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
    % cfg.dftfilter = 'yes';
    % cfg.dftfreq = [50 100 150]; % line noise frequencies in Hz for DFT filter (default = [50 100 150])
    data = ft_preprocessing(cfg, data);

    % Notch
    if strcmp(NotchOpt, "on")
        butter = path2func(fullfile(matlabroot, "toolbox/signal/signal/butter.m"));
        filtfilt = path2func(fullfile(matlabroot, "toolbox/signal/signal/filtfilt.m"));

        for fIndex = 1:length(fNotch)
            [b, a] = butter(3, (fNotch(fIndex) + [-1, 1]) / (fs / 2), "stop");
            data.trial = cellfun(@(x) filtfilt(b, a, x')', data.trial, "UniformOutput", false);
        end

    end
    
    %% output
    if isstruct(dataset)
        dataset.data = data.trial{1};
        varargout{1} = dataset;
    else
        varargout{1} = data.trial';
    end

    return;
end
