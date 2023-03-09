function [tIdx, chIdx] = excludeTrials(trialsData, varargin)
    % Description: exclude trials with sum(Data > mean + 3 * variance | Data < mean - 3 * variance) / length(Data) > tTh
    % Input:
    %     trialsData: nTrials*1 cell vector with each cell containing an nCh*nSample matrix of data
    %     tTh: threshold of percentage of bad data. For one trial, if nSamples(bad) > tTh*nSamples(total)
    %          in any reserved channel, it will be excluded. (default: 0.2)
    %     chTh: threshold for excluding bad channels.
    %           If set [0, 1], it stands for percentage of trials.
    %           If set integer > 1, it stands for nTrials.
    %           The smaller, the stricter and the more bad channels. (default: 0.1)
    %     userDefineOpt: If set "on", bad channels will be defined by user.
    %                    If set "off", use [chTh] setting to exclude bad channels. (default: "off")
    % Output:
    %     tIdx: excluded trial index (double column vector)
    %     chIdx: bad channel index (double column vector)
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
    mIp.addOptional("chTh", 0.1, @(x) validateattributes(x, {'numeric'}, {'scalar', '>=', 0}));
    mIp.addParameter("userDefineOpt", "off", @(x) any(validatestring(x, {'on', 'off'})));
    mIp.parse(trialsData, varargin{:});

    tTh = mIp.Results.tTh;
    chTh = mIp.Results.chTh;
    userDefineOpt = mIp.Results.userDefineOpt;

    % statistics
    chMeanAll = mean(cell2mat(trialsData));
    chStdAll = std(cell2mat(trialsData));
    tIdxAll = cellfun(@(x) sum(x > chMeanAll + 3 * chStdAll | x < chMeanAll - 3 * chStdAll, 2) / size(x, 2), trialsData, "UniformOutput", false);

    temp = changeCellRowNum(trialsData);
    chMean = cell2mat(cellfun(@mean, temp, "UniformOutput", false));
    chStd = cell2mat(cellfun(@std, temp, "UniformOutput", false));
    tIdx = cellfun(@(x) sum(x > chMean + 3 * chStd | x < chMean - 3 * chStd, 2) / size(x, 2), trialsData, "UniformOutput", false);
    
    % sort channels
    V0_All = cellfun(@(x) sum(x > chMeanAll + 3 * chStdAll | x < chMeanAll - 3 * chStdAll, 2) / size(x, 2), temp, "UniformOutput", false);
    V_All = cellfun(@(x) x > tTh, V0_All, "UniformOutput", false);
    V0 = cellfun(@(x) sum(x > mean(x, 1) + 3 * std(x, [], 1) | x < mean(x, 1) - 3 * std(x, [], 1), 2) / size(x, 2), temp, "UniformOutput", false);
    V = cellfun(@(x) x > tTh, V0, "UniformOutput", false);

    badtrialIdx = cellfun(@(x, y) any(x) | any(y), changeCellRowNum(V_All), changeCellRowNum(V));

    V_All = cellfun(@(x) sum(x), V_All);
    V = cellfun(@(x) sum(x), V);

    % show channel-bad trials
    if chTh > 1 && chTh == fix(chTh)
        goodChIdx = V_All < chTh & V < chTh; % marked true means reserved channels
    elseif chTh < 1
        goodChIdx = V_All < chTh * length(trialsData) & V < chTh * length(trialsData); % marked true means reserved channels
    else
        error('Invalid channel threshold input.');
    end
    
    channels = (1:length(goodChIdx))'; % all channels
    nTrial_bad_All = arrayfun(@(x) [num2str(x), '/', num2str(length(trialsData))], V_All, "UniformOutput", false);
    nTrial_bad_Single = arrayfun(@(x) [num2str(x), '/', num2str(length(trialsData))], V, "UniformOutput", false);
    mark = repmat("good", [length(channels), 1]);
    mark(~goodChIdx) = "bad";
    disp(table(channels, nTrial_bad_All, nTrial_bad_Single, mark));
    if all(goodChIdx)
        disp('All channels are good.');
    else
        disp(['Possible bad channel numbers are: ', num2str(find(~goodChIdx)')]);
    end

    % bad channels defined by user
    if strcmp(userDefineOpt, "on")
        badCHs = validateInput('Please input bad channel number (0 for preview): ', @(x) validateattributes(x, {'numeric'}, {'2d', 'integer', 'nonnegative'}));

        if isequal(badCHs, 0)
            % raw wave
            plotRawWave(chMean, chStd, [0, 1], 'origin');
            scaleAxes("y", "cutoffRange", [-100, 100], "symOpts", "max");

            % good trials (mean, red) against bad trials (single, grey)
            previewRawWave(trialsData, badtrialIdx, V_All);

            % histogram
            temp = changeCellRowNum(tIdx);
            figure;
            maximizeFig;
            margins = [0.05, 0.05, 0.1, 0.1];
            paddings = [0.01, 0.03, 0.01, 0.01];
            for index = 1:length(channels)
                mSubplot(8, 8, index, "margins", margins, "paddings", paddings);
                binSize = 0.05;
                histogram(temp{index}, "Normalization", "probability", "BinWidth", binSize, "FaceColor", "b", "DisplayName", "Single");
                hold on;
                histogram(V0_All{index}, "Normalization", "probability", "BinWidth", binSize, "FaceColor", "r", "DisplayName", "All");
                if ismember(index, find(~goodChIdx))
                    title(['CH ', num2str(index), ' (bad)']);
                else
                    title(['CH ', num2str(index)]);
                end
                if index <= 56
                    xticklabels('');
                end
                if mod(index - 1, 8) ~= 0
                    yticklabels('');
                end
                if index == 1
                    legend(gca, "show");
                else
                    legend(gca, "hide");
                end
            end
            scaleAxes("x", [0.1, inf]);
            scaleAxes("y", "on", "type", "hist");
            lines.X = tTh;
            addLines2Axes(gcf, lines);

            k = 'N';
        else
            k = 'Y';
            goodChIdx = true(length(goodChIdx), 1);
            goodChIdx(badCHs) = false;
        end

        while strcmpi(k, 'n')
            badCHs = validateInput('Please input bad channel number: ', @(x) validateattributes(x, {'numeric'}, {'2d', 'integer', 'positive'}));
            
            % sort trials - preview
            goodChIdx = true(length(goodChIdx), 1);
            goodChIdx(badCHs) = false;
            tIdxTemp = cellfun(@(x) sum(x(goodChIdx, :) > chMean(goodChIdx, :) + 3 * chStd(goodChIdx, :) | x(goodChIdx, :) < chMean(goodChIdx, :) - 3 * chStd(goodChIdx, :), 2) / size(x, 2), trialsData, "UniformOutput", false);
            tIdxTemp = cellfun(@(x) ~any(x > tTh), tIdxTemp); % marked true means reserved trials
            if any(~tIdxTemp)
                disp(['Preview: Trial ', num2str(find(~tIdxTemp)'), ' will be excluded.']);
            else
                disp('Preview: All will pass.');
            end

            k = validateInput('Press Y or Enter to continue or N to reselect bad channels: ', @(x) any(validatestring(x, {'y', 'n', 'N', 'Y', ''})), 's');
        end

    end

    tIdx = cellfun(@(x) ~any(x(goodChIdx) > tTh), tIdx); % marked true means reserved trials
    if any(~tIdx)
        tIdx = find(~tIdx);
        disp(['Trial ', num2str(tIdx'), ' excluded.']);
    else
        tIdx = [];
        disp('All pass.');
    end

    chIdx = find(~goodChIdx);
    if ~isempty(chIdx)
        disp(['Bad Channels: ', num2str(chIdx')]);
    else
        disp('All channels are good.');
    end

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