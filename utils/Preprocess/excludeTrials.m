function [tIdx, chIdx] = excludeTrials(trialsData, varargin)
    % Description: exclude trials with sum(Data > mean + 3 * variance | Data < mean - 3 * variance) / length(Data) > tTh
    % Input:
    %     trialsData: nTrials*1 cell vector with each cell containing an nCh*nSample matrix of data
    %     tTh: threshold of percentage of bad data. For one trial, if nSamples(bad) > tTh*nSamples(total)
    %          in any reserved channel, it will be excluded. (default: 0.2)
    %     chTh: threshold for excluding bad channels. The smaller, the stricter and the more bad channels. (default: 0.05)
    %     userDefineOpt: If set "on", bad channels will be defined by user.
    %                    If set "off", use [chTh] setting to exclude bad channels. (default: "off")
    % Output:
    %     tIdx: excluded trial index (double)
    %     chIdx: bad channel index (double)
    % Example:
    %     window = [-200, 1000];
    %     topoSize = [8, 8]; % [x, y]
    %     tTh = 0.2; % If more than 20% of data of the trial is not good, exclude the trial
    %     chTh = 0.1; % If more than 10% of total trials in a channel are not good, exclude the channel
    %     trialsECOG = selectEcog(ECOGDataset, trials, "dev onset", window);
    %     [tIdx, chIdx] = excludeTrials(trialsECOG, tTh, chTh);
    %     trialsECOG(tIdx) = [];
    %     trials(tIdx) = [];
    %     chs = ECOGDataset.channels;
    %     chs(chIdx) = inf;
    %     chs = reshape(chs, topoSize)';
    %     chMean = cell2mat(cellfun(@mean, trialsECOG, "uni", false));
    %     plotRawWave(chMean, [], window, [], topoSize, chs); % Plot good channels only

    mIp = inputParser;
    mIp.addRequired("trialsData", @(x) iscell(x));
    mIp.addOptional("tTh", 0.2, @(x) validateattributes(x, {'numeric'}, {'scalar', '>', 0, '<', 1}));
    mIp.addOptional("chTh", 0.05, @(x) validateattributes(x, {'numeric'}, {'scalar', '>', 0, '<', 1}));
    mIp.addParameter("userDefineOpt", "off", @(x) any(validatestring(x, {'on', 'off'})));
    mIp.parse(trialsData, varargin{:});

    tTh = mIp.Results.tTh;
    chTh = mIp.Results.chTh;
    userDefineOpt = mIp.Results.userDefineOpt;

    % sort channels
    temp = changeCellRowNum(trialsData);
    chMean = cell2mat(cellfun(@mean, temp, "UniformOutput", false));
    chStd = cell2mat(cellfun(@std, temp, "UniformOutput", false));
    chMeanAll = mean(cell2mat(trialsData));
    chStdAll = std(cell2mat(trialsData));
    V = cellfun(@(x) sum(x > chMeanAll + 3 * chStdAll | x < chMeanAll - 3 * chStdAll, 2) / size(x, 2), temp, "UniformOutput", false);
    V = cellfun(@(x) x > tTh, V, "UniformOutput", false);
    badtrialIdx = cellfun(@(x) any(x), changeCellRowNum(V));
    V = cellfun(@(x) sum(x), V);
    goodChIdx = V < chTh * length(trialsData); % marked true means reserved channels
    channels = (1:length(goodChIdx))';
    nTrial_bad = arrayfun(@(x) [num2str(x), '/', num2str(length(trialsData))], V, "UniformOutput", false);
    mark = goodChIdx;
    disp(table(channels, nTrial_bad, mark));
    disp(['Possible bad channel numbers are: ', num2str(find(~goodChIdx)')]);

    if strcmp(userDefineOpt, "on")
        badCHs = validateInput('Please input bad channel number (empty for auto, 0 for preview): ', @(x) validateattributes(x, {'numeric'}, {'2d', 'integer', 'nonnegative'}));

        if isequal(badCHs, 0)
            previewRawWave(trialsData, badtrialIdx, V);
            badCHs = validateInput('Please input bad channel number (empty for auto): ', @(x) validateattributes(x, {'numeric'}, {'2d', 'integer', 'positive'}));
        end

        if ~isempty(badCHs)
            goodChIdx = true(1, length(goodChIdx));
            goodChIdx(badCHs) = false;
        end

    end

    % sort trials
    tIdx = cellfun(@(x) sum(x(goodChIdx, :) > chMean(goodChIdx, :) + 3 * chStd(goodChIdx, :) | x(goodChIdx, :) < chMean(goodChIdx, :) - 3 * chStd(goodChIdx, :), 2) / size(x, 2), trialsData, "UniformOutput", false);
    tIdx = cellfun(@(x) ~any(x > tTh), tIdx); % marked true means reserved trials

    if any(~tIdx)
        tIdx = find(~tIdx)';
        disp(['Trial ', num2str(tIdx), ' excluded.']);
    else
        tIdx = [];
        disp('All pass');
    end

    chIdx = find(~goodChIdx)';
    disp(['Bad Channels: ', num2str(chIdx)]);

    return;
end

function previewRawWave(trialsData, badtrialIdx, V)
    % Preview good trials (mean, red) against bad trials (single, grey)
    temp = find(badtrialIdx);

    if ~isempty(temp)
        
        for index = 1:length(temp)
            chData(index).chMean = trialsData{temp(index)};
            chData(index).color = [200, 200, 200] / 255;
            chData(index).skipChs = find(V == 0);
        end

        chData(index + 1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(trialsData(~badtrialIdx)), "UniformOutput", false));
        chData(index + 1).color = 'r';
    else
        chData.chMean = cell2mat(cellfun(@mean, changeCellRowNum(trialsData), "UniformOutput", false));
        chData.color = 'r';
    end

    Fig = plotRawWaveMulti(chData, [0, 1]);
    scaleAxes(Fig, "y", "cutoffRange", [-200, 200], "symOpts", "max");
    return;
end