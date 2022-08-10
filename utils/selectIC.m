function [comp, idx] = selectIC(comp, window, t1, t2)
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
    
    win1 = [t1 t2];
    tIdx1 = max(fix((win1(1) - window(1)) / 1000 * fs), 1);
    tIdx2 = min(fix((win1(2) - window(1)) / 1000 * fs), size(ICMean, 2));
    pw(:, 1) = std(ICMean(:, tIdx1:tIdx2), [], 2);

    win2 = win1 - diff(win1);
    tIdx1 = max(fix((win2(1) - window(1)) / 1000 * fs), 1);
    tIdx2 = min(fix((win2(2) - window(1)) / 1000 * fs), size(ICMean, 2));
    pw(:, 2) = std(ICMean(:, tIdx1:tIdx2), [], 2);
%     plotRawWave(ICMean(:, tIdx1:end), [], [0 100]);
    idx = find(pw(:, 1) > 3 * pw(:, 2));
    comp.trial = cellfun(@(x) x(idx, :), comp.trial, "UniformOutput", false);
    comp.topo = comp.topo(:, idx);
    comp.unmixing = comp.unmixing(idx, :);

    return;
end