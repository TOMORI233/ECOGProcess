function ECOGDataset = mResample(ECOGDataset, trials, window, segOption, fs, fhp, flp)
% Description: Split data by trials, window and segOption. Filter and
    %              resample data. Perform ICA on data.
    % Input:
    %     ECOGDataset: TDT dataset of [LAuC] or [LPFC]
    %     trials: n*1 struct array of trial information
    %     window: time window of interest of each trial
    %     segOption: "trial onset" | "dev onset" | "push onset" | "last std"
    %     fs: sample rate for downsampling, < fs0
    % Output:
    %     comp: result of ICA (FieldTrip)

    narginchk(4, 7);

    if nargin < 5
        fs = 500; % Hz, for downsampling
        fhp = 0.5;
        flp = 100;
    end
    
    if nargin < 6
        fhp = 0.5;
        flp = 100;
    end

    if nargin < 7
        flp = 100;
    end
    %% Preprocessing
    disp("Preprocessing...");
    fs0 = ECOGDataset.fs;
    channels = ECOGDataset.channels;
    [trialsECOG, ~, ~, sampleinfo] = selectEcog(ECOGDataset, trials, segOption, window);
    t = linspace(window(1), window(2), size(trialsECOG{1}, 2)) / 1000;

    cfg = [];
    cfg.trials = true(length(trialsECOG), 1);
    data.trial = trialsECOG';
    data.time = repmat({t}, 1, length(trials));
    data.label = cellfun(@(x) num2str(x), num2cell(channels)', 'UniformOutput', false);
    data.fsample = fs0;
    data.trialinfo = ones(length(trials), 1);
    data.sampleinfo = sampleinfo;
    data = ft_selectdata(cfg, data);

    % Filter
    cfg = [];
    cfg.demean = 'no';
    cfg.lpfilter = 'yes';
    cfg.lpfreq = flp;
    cfg.hpfilter = 'yes';
    cfg.hpfreq = fhp;
    cfg.hpfiltord = 3;
    cfg.dftfreq       = [50 100 150]; % line noise frequencies in Hz for DFT filter (default = [50 100 150])
    data = ft_preprocessing(cfg, data);

    %% Resampling
    disp("Resampling...");

    if fs < fs0
        cfg = [];
        cfg.resamplefs = fs;
        cfg.trials = (1:length(data.trial))';
        data = ft_resampledata(cfg, data);
    else
        warning("resamplefs should not be greater than fsample. Skip resampling.");
    end

    ECOGDataset.data = data.trial';
    ECOGDataset.fs = fs;
