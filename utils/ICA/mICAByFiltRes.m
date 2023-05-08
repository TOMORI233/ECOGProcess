function [comp, chs] = mICAByFiltRes(filterRes, stimCode)
    % Description: Split data by trials, window and segOption. Filter and
    %              resample data. Perform ICA on data.
    % Input:
    %     filterRes: .mat file saved after process of TDT Block.
    %     stimCode: click train type selected to conduct ICA.
    % Output:
    %     comp: result of ICA (FieldTrip)




    %% Preprocessing
    disp("Preprocessing...");
    fs = filterRes(stimCode).fs;
    fs0 = filterRes(stimCode).fs0;
    
    trialsECOG = filterRes(stimCode).FDZData;
    t = filterRes(stimCode).t;
    trials = filterRes(stimCode).trials;
    channels = 1 : size(filterRes(stimCode).chMean, 1);
    % rest state
    t = filterRes(stimCode).t;
    restIdx = t > -4000 & t < 0;

    [~, chIdx] = excludeTrials(cellfun(@(x) x(:, restIdx), trialsECOG, 'UniformOutput', false), 1);
    exCh = [];
    chs = channels;
    temp = trialsECOG;
    while sum(~chIdx) > 0
        exCh = [exCh chs(~chIdx)];
        chs = channels(~ismember(channels, exCh));
        temp = trialsECOG;
        for trialN = 1 : length(temp)
            temp{trialN}(exCh, :) = [];
        end
        [~, chIdx] = excludeTrials(temp, 1);
    end
        
    cfg = [];
    cfg.trials = true(length(trialsECOG), 1);
    data.trial = temp';
    data.time = repmat({t}, 1, length(trials));
    
    data.label = cellfun(@(x) num2str(x), num2cell(chs)', 'UniformOutput', false);
    data.fsample = fs;
    data.trialinfo = ones(length(trials), 1);
    data.sampleinfo = [[filterRes(stimCode).trials.soundOnsetSeq]' [filterRes(stimCode).trials.soundOnsetSeq]' + size(trialsECOG{1}) / fs * fs0];
    data = ft_selectdata(cfg, data);

%     % Filter
%     cfg = [];
%     cfg.demean = 'no';
%     cfg.lpfilter = 'yes';
%     cfg.lpfreq = 50;
%     cfg.hpfilter = 'yes';
%     cfg.hpfreq = 0.5;
%     cfg.hpfiltord = 3;
%     cfg.dftfreq       = [50 100 150]; % line noise frequencies in Hz for DFT filter (default = [50 100 150])
%     data = ft_preprocessing(cfg, data);

    %% ICA
    disp("Performing ICA...");
    cfg = [];
    cfg.method = 'runica';
    comp = ft_componentanalysis(cfg, data);

    disp("ICA done.");
    return;
end
