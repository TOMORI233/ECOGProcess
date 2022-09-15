function ECOGDataset = ECOGDownsample(ECOGDataset, fd)
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
    disp("Downsampling...");

    if fd < fs0
        cfg = [];
        cfg.resamplefs = fd;
        cfg.trials = 'all';
        data = ft_resampledata(cfg, data);
        ECOGDataset.data = data.trial{1};
        ECOGDataset.fs = fd;
    else
        warning("fdownsample should not be greater than fsample. Skip downsampling.");
    end
    
    return;
end