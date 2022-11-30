function [latency_mean, latency_se, latency_raw] = waveLatency_cumThreshold(wave, window, testWin, thr, fs, sponWin)
% Description: Split data by trials, window and segOption. Filter and
    %              resample data. Perform ICA on data.
    % Input:
    %     wave: wave should be the similar type as trialsECOG
    %     window: the window that corresponding to the size of trialsECOG
    %     testWin: window included to get the threshold
    %     thr: threshold to get latency
    %     sponWin: prior response to define threshold


t = linspace(window(1), window(2), size(wave{1, 1}, 2));
tIndex = t > testWin(1) & t < testWin(2);
sponTIndex = t > sponWin(1) & t < sponWin(2);
wave = changeCellRowNum(wave);

temp = cellfun(@(x) array2VectorCell(cumsum(abs(x(:, tIndex)), 2)), wave, "UniformOutput", false);
sponTemp = cellfun(@(x) array2VectorCell(sum(abs(x(:, sponTIndex)), 2) * thr), wave, "UniformOutput", false);

for cIndex= 1 : length(temp)
    chTemp = temp{cIndex};
    chSponTemp = sponTemp{cIndex};
    idx{cIndex, 1} = cell2mat(cellfun(@(x, y) min([length(chTemp{1}) find(x > y, 1, "first")]), chTemp, chSponTemp, "UniformOutput", false));
end

latency_raw = cellfun(@(x) x * 1000 / fs, idx, "UniformOutput", false);
latency_mean = cell2mat(cellfun(@(x) mean(x * 1000 / fs), idx, "UniformOutput", false));
latency_se = cell2mat(cellfun(@(x) std(x * 1000 / fs) / sqrt(length(x)), idx, "UniformOutput", false));

end

