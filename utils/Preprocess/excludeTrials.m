function [tIdx, chIdx] = excludeTrials(trialsData, tTh, chTh)
    % Description: exclude trials with sum(Data > mean + 3 * variance | Data < mean - 3 * variance) / length(Data) > tTh
    % Input:
    %     trialsData: nTrials*1 cell vector with each cell containing an nCh*nSample matrix of data
    %     tTh: threshold of percentage of bad data. For one trial, if nSamples(bad) > tTh*nSamples(total)
    %          in any reserved channel, it will be excluded. (default: 0.2)
    %     chTh: threshold for excluding bad channels. The smaller, the more strict. (default: 0.05)
    % Output:
    %     tIdx: excluded trial index (double)
    %     chIdx: bad channel index (double)
    % Example:
    %     tTh = 0.2; % If 20% of data of the trial is not good, exclude it
    %     trialsECOG = selectEcog(ECOGDataset, trials, "dev onset", [-200, 1000]);
    %     tIdx = excludeTrials(trialsECOG, tTh);
    %     trialsECOG(tIdx) = [];
    %     trials(tIdx) = [];

    narginchk(1, 3);

    if nargin < 2
        tTh = 0.2;
    end

    if nargin < 3
        chTh = 0.05;
    end

    temp = changeCellRowNum(trialsData);
    chMean = cell2mat(cellfun(@mean, temp, "UniformOutput", false));
    chStd = cell2mat(cellfun(@std, temp, "UniformOutput", false));

    % sort channels
    chMeanAll = mean(cell2mat(trialsData));
    chStdAll = std(cell2mat(trialsData));
    chIdx = cellfun(@(x) sum(x > chMeanAll + 3 * chStdAll | x < chMeanAll - 3 * chStdAll, 2) / size(x, 2), temp, "UniformOutput", false);
    chIdx = cellfun(@(x) sum(x > tTh) < chTh * length(trialsData), chIdx); % marked true means reserved channels

    % sort trials
    tIdx = cellfun(@(x) sum(x(chIdx, :) > chMean(chIdx, :) + 3 * chStd(chIdx, :) | x(chIdx, :) < chMean(chIdx, :) - 3 * chStd(chIdx, :), 2) / size(x, 2), trialsData, "UniformOutput", false);
    tIdx = cellfun(@(x) ~any(x > tTh), tIdx); % marked true means reserved trials

    if any(~tIdx)
%         % preview
%         chData(1).chMean = chMean;
%         chData(1).color = 'r';
%         chData(1).legend = 'origin';
%         chData(2).chMean = cell2mat(cellfun(@mean, trialsData(tIdx), "UniformOutput", false));
%         chData(2).color = 'b';
%         chData(2).legend = 'after excluded';
%         chData(3).chMean = cell2mat(cellfun(@mean, trialsData(tIdx), "UniformOutput", false));
%         chData(3).color = [200, 200, 200] / 255;
%         chData(3).legend = 'residual';
%         plotRawWaveMulti(chData, [0, 1]);

        tIdx = find(~tIdx)';
        disp(['Trial ', num2str(tIdx), ' excluded.']);
    else
        tIdx = [];
        disp('All pass');
    end

    chIdx = find(~chIdx)';
    disp(['Bad Channels: ', num2str(chIdx)]);

    return;
end