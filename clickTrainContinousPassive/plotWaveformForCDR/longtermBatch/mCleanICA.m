function [compTemp, comp] = mCleanICA(trialsECOG, opts)
    % Description: Split data by trials, window and segOption. Filter and
    %              resample data. Perform ICA on data.
    % Input:
    %     filterRes: .mat file saved after process of TDT Block.
    %     stimCode: click train type selected to conduct ICA.
    % Output:
    %     comp: result of ICA (FieldTrip)


optsNames = fieldnames(opts);
for index = 1:size(optsNames, 1)
    eval([optsNames{index}, '=opts.', optsNames{index}, ';']);
end

    %% Preprocessing
    disp("Preprocessing...");
    cfg = [];
    cfg.trials = true(length(trialsECOG), 1);
    data.trial = trialsECOG;
    data.time = repmat({t}, 1, length(trialsECOG));
    
    data.label = cellfun(@(x) num2str(x), num2cell(chs)', 'UniformOutput', false);
    data.fsample = fs;
    data.trialinfo = ones(length(trialsECOG), 1);
    data.sampleinfo = repmat([1, 2], length(trialsECOG), 1);
    data = ft_selectdata(cfg, data);



    %% ICA
    disp("Performing ICA...");
    cfg = [];
    cfg.method = 'runica';
    comp = ft_componentanalysis(cfg, data);

%% 
    window = [t(1) t(end)];
    t1 = [-S1Duration 0];
    t2 = t1 + 500;
    compTemp = comp;
    compTemp = realignIC(compTemp, window, t1, t2);
    topoTemp = zeros(64, size(compTemp.topo, 2));
    topoTemp(chs, :) = compTemp.topo;
    compTemp.topo = topoTemp;
    
    disp("ICA done.");
    return;
end
