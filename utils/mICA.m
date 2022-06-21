function [comp, ICAres] = mICA(ECOGDataset, trials, window, segOption, fs)
    narginchk(4, 5);

    if nargin < 5
        fs = 500; % Hz
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
    cfg = [];
    cfg.resamplefs = fs;
    cfg.trials = (1:length(data.trial))';
    data = ft_resampledata(cfg, data);

    %% ICA
    disp("Performing ICA...");
    cfg = [];
    cfg.method = 'runica';
    comp = ft_componentanalysis(cfg, data);
    ICAres = cellfun(@(x) comp.unmixing * x, trialsECOG, "UniformOutput", false);

    %% Adjustment
    disp("Adjusting...");

    for index = 1:size(comp.topo, 2)
        temp = comp.topo(:, index);

        if max(temp) < abs(min(temp))
            disp(['IC', num2str(index), ' reverse']);
            comp.topo(:, index) = -temp;
            temp = changeCellRowNum(ICAres);
            temp(index) = {-temp{index}};
            ICAres = changeCellRowNum(temp);
        end

    end

    disp("ICA done.");
    return;
end
