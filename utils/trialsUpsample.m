function [trialsECOG, fu] = trialsUpsample(trialsECOG, fs0, fu)
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

    if fu > fs0
        cfg = [];
        cfg.resamplefs = fu;
        cfg.trials = 'all';
        data = ft_resampledata(cfg, data);
        trialsECOG = data.trial;
    else
        warning("fUpsample should not be greater than fsample. Skip upsampling.");
    end
    
    return;
end
