function ECOGDataset = mResample2(ECOGDataset, fs, fhp, flp)
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

    narginchk(1, 4);

    if nargin < 2
        fs = 500; % Hz, for downsampling
        fhp = 0.5;
        flp = 100;
    end
    
    if nargin < 3
        fhp = 0.5;
        flp = 100;
    end

    if nargin < 4
        flp = 100;
    end
    %% Preprocessing
    disp("Preprocessing...");
    fs0 = ECOGDataset.fs;
    channels = ECOGDataset.channels;
    t = 1/fs : 1/fs : size(ECOGDataset.data, 2)/fs;

    cfg = [];
    cfg.trials = true(1, 1);
    data.trial = {ECOGDataset.data};
    data.time = {t};
    data.label = cellfun(@(x) num2str(x), num2cell(channels)', 'UniformOutput', false);
    data.fsample = fs0;
    data.trialinfo = 1;
    data.sampleinfo = [1 size(ECOGDataset.data, 2)];
    data = ft_selectdata(cfg, data);

    % Filter
    cfg = [];
    cfg.demean = 'no';
    if flp == Inf
        cfg.lpfilter = 'no';
    else
        cfg.lpfilter = 'yes';
        cfg.lpfreq = flp;
    end
    
    if fhp == 0
        cfg.hpfilter = 'no';
    else
        cfg.hpfilter = 'yes';
        cfg.hpfreq = fhp;
    end

    cfg.hpfiltord = 2;
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
    ECOGDataset.data = data.trial{1};
    ECOGDataset.fs = fs;
