function ECOGDataset = ECOGFilter(ECOGDataset, fhp, flp)
    narginchk(1, 3);

    if nargin < 2
        fhp = 0.5;
    end

    if nargin < 3
        flp = 100;
    end

    fs0 = ECOGDataset.fs;
    channels = ECOGDataset.channels;

    cfg = [];
    cfg.trials = 'all';
    data.trial = {ECOGDataset.data};
    data.time = {(1:size(ECOGDataset.data, 2)) / fs0};
    data.label = cellfun(@(x) num2str(x), num2cell(channels)', 'UniformOutput', false);
    data.fsample = fs0;
    data.trialinfo = 1;
    data.sampleinfo = [1, size(ECOGDataset.data, 2)];
    data = ft_selectdata(cfg, data);

    % Filter
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

    ECOGDataset.data = data.trial{1};
    return;
end