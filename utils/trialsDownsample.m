function [trialsECOG, fd] = trialsDownsample(trialsECOG, fs0, fd)
    channels = 1 : size(trialsECOG{1}, 1);
    cfg = [];
    cfg.trials = 'all';
    data.trial = trialsECOG;
    data.time = cellfun(@(x) 1:size(x, 2), trialsECOG, "UniformOutput", false);
    data.label = cellfun(@(x) num2str(x), num2cell(channels)', 'UniformOutput', false);
    data.fsample = fs0;
    data.trialinfo = 1;
    data.sampleinfo = [1, size(trialsECOG{1}, 2)];
    data = ft_selectdata(cfg, data);

    % Filter
    disp("Downsampling...");

    if fd < fs0
        cfg = [];
        cfg.resamplefs = fd;
        cfg.trials = 'all';
        data = ft_resampledata(cfg, data);
        trialsECOG = data.trial;
    else
        warning("fdownsample should not be greater than fsample. Skip downsampling.");
    end
    
    return;
end

