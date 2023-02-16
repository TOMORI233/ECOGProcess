function [tIdx, chIdx] = excludeTrials(trialsData, varargin)
    % Description: exclude trials with sum(Data > mean + 3 * variance | Data < mean - 3 * variance) / length(Data) > tTh
    % Input:
    %     trialsData: nTrials*1 cell vector with each cell containing an nCh*nSample matrix of data
    %     tTh: threshold of percentage of bad data. For one trial, if nSamples(bad) > tTh*nSamples(total)
    %          in any reserved channel, it will be excluded. (default: 0.2)
    %     chTh: threshold for excluding bad channels. The smaller, the stricter and the more bad channels. (default: 0.05)
    %     userDefineOpt: If set "on", bad channels will be defined by user.
    %                    If set "off", use [chTh] setting to exclude bad channels. (default: "off")
    %     previewOpt: If set "on", preview good trials (mean, red) against bad trials (single, grey). (default: "off")
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
    %     chs(chIdx) = [];
    %     chs = reshape(chs, topoSize)';
    %     chMean = cell2mat(cellfun(@mean, trialsECOG, "uni", false));
    %     plotRawWave(chMean, [], window, [], topoSize, chs); % Plot good channels only

    mIp = inputParser;
    mIp.addRequired("trialsData", @(x) iscell(x));
    mIp.addOptional("tTh", 0.2, @(x) validateattributes(x, {'numeric'}, {'scalar', '>', 0, '<', 1}));
    mIp.addOptional("arg3", []);
    mIp.addParameter("userDefineOpt", "off", @(x) any(validatestring(x, {'on', 'off'})));
    mIp.addParameter("previewOpt", "off", @(x) any(validatestring(x, {'on', 'off'})));
    mIp.parse(trialsData, varargin{:});

    tTh = mIp.Results.tTh;
    arg3 = mIp.Results.arg3;
    userDefineOpt = mIp.Results.userDefineOpt;
    previewOpt = mIp.Results.previewOpt;

    if ~isempty(arg3)

        switch class(arg3)
            case 'double'
                chTh = arg3;
                userDefineOpt = "off";
            case 'string'
                chTh = 0.05;
                userDefineOpt = "on";
            case 'char'
                chTh = 0.05;
                userDefineOpt = "on";
            otherwise
                error('Invalid syntax');
        end
    else
        chTh = 0.05;
    end

    temp = changeCellRowNum(trialsData);
    chMean = cell2mat(cellfun(@mean, temp, "UniformOutput", false));
    chStd = cell2mat(cellfun(@std, temp, "UniformOutput", false));

    % sort channels
    chMeanAll = mean(cell2mat(trialsData));
    chStdAll = std(cell2mat(trialsData));
    V = cellfun(@(x) sum(x > chMeanAll + 3 * chStdAll | x < chMeanAll - 3 * chStdAll, 2) / size(x, 2), temp, "UniformOutput", false);
    V = cellfun(@(x) x > tTh, V, "UniformOutput", false);
    badtrialIdx = cellfun(@(x) any(x), changeCellRowNum(V));
    V = cellfun(@(x) sum(x), V);
    goodChIdx = V < chTh * length(trialsData); % marked true means reserved channels

    % preview
    if strcmp(previewOpt, "on")
        temp = find(badtrialIdx);

        if ~isempty(temp)
            
            for index = 1:length(temp)
                chData(index).chMean = trialsData{temp(index)};
                chData(index).color = [200, 200, 200] / 255;
            end
    
            chData(index + 1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(trialsData(~badtrialIdx)), "UniformOutput", false));
            chData(index + 1).color = 'r';
        else
            chData.chMean = chMean;
            chData.color = 'r';
        end

        Fig = plotRawWaveMulti(chData, [0, 1]);
        scaleAxes(Fig, "y", "cutoffRange", [-200, 200], "symOpts", "max");
    end

    if strcmp(userDefineOpt, "on")
        channel = (1:length(goodChIdx))';
        nTrial_bad = arrayfun(@(x) [num2str(x), '/', num2str(length(trialsData))], V, "UniformOutput", false);
        mark = goodChIdx;
        disp(table(channel, nTrial_bad, mark));
        disp(['Possible bad channel numbers are: ', num2str(find(~goodChIdx)')]);
        badCHs = validateInput('Please input bad channel number (empty for auto): ', @(x) validateattributes(x, {'numeric'}, {'2d', 'integer'}));

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