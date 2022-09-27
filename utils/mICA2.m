function comp = mICA2(trialsECOG, sampleinfo, channels, window, fs0, fs)
    % Description: Split data by trials, window and segOption. Filter and
    %              resample data. Perform ICA on data.
    %              For joint data of serveral days.
    % Input:
    %     trialsECOG: n*1 cell array of trial data (64*m matrix)
    %     sampleinfo: n*2 [startIdx, endIdx] of each trial
    %     channels: ECOGDataset.channels
    %     fs0: ECOGDataset.fs0
    %     fs: sample rate for downsampling, < fs0
    % Output:
    %     comp: result of ICA (FieldTrip)

    narginchk(5, 6);

    if nargin < 6
        fs = fs0; % Hz, for downsampling
    end

    %% Preprocessing
    disp("Preprocessing...");
    t = linspace(window(1), window(2), size(trialsECOG{1}, 2)) / 1000;

    cfg = [];
    cfg.trials = 'all';
    data.trial = trialsECOG';
    data.time = repmat({t}, 1, length(trialsECOG));
    data.label = cellfun(@(x) num2str(x), num2cell(channels)', 'UniformOutput', false);
    data.fsample = fs0;
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
    cfg.dftfreq       = [50 100 150]; % line noise frequencies in Hz for DFT filter (default = [50 100 150])
    data = ft_preprocessing(cfg, data);

    %% Resampling
    disp("Resampling...");

    if fs < fs0
        cfg = [];
        cfg.resamplefs = fs;
        cfg.trials = 'all';
        data = ft_resampledata(cfg, data);
    else
        warning("resamplefs should not be greater than fsample. Skip resampling.");
    end

    %% ICA
    disp("Performing ICA...");
    cfg = [];
    cfg.method = 'runica';
    comp = ft_componentanalysis(cfg, data);

    disp("ICA done.");
    return;
end
