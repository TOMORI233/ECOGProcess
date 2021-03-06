function comp = realignIC(comp, window, t1, t2)
    % Description: realign IC by std descend
    % Input:
    %     comp: result of ICA (FieldTrip)
    %     window: time window of data of each trial
    %     t1: starting time point of interest, in ms
    %     t2: ending time point of interest, in ms
    % Output:
    %     comp: with topo, unmixing and trial realigned
    % Example:
    %     window = [-2000, 2000];
    %     comp = mICA(ECOGDataset, trialAll(10:40), window, "dev onset", fs);
    %     t1 = [-2000, -1500, -1000, -500, 0];
    %     t2 = t1 + 200;
    %     comp1 = realignIC(comp, window, t1, t2);

    ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
    fs = comp.fsample;

    tIdx1 = max(fix((t1 - window(1)) / 1000 * fs), 1);
    tIdx2 = min(fix((t2 - window(1)) / 1000 * fs), size(ICMean, 2));
    pw = std(ICMean(:, tIdx1:tIdx2), [], 2);
    
    [~, idx] = sort(pw, "descend");
    comp.trial = cellfun(@(x) x(idx, :), comp.trial, "UniformOutput", false);
    comp.topo = comp.topo(:, idx);
    comp.unmixing = comp.unmixing(idx, :);

    return;
end