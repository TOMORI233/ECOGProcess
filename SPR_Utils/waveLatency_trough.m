function [latency_mean, latency_se, latency_raw, smthWave] = waveLatency_trough(wave, window, testWin, smthBin, fs)
% Description: Split data by trials, window and segOption. Filter and
%              resample data. Perform ICA on data.
% Input:
%     wave: wave should be the similar type as trialsECOG
%     window: the window that corresponding to the size of trialsECOG
%     testWin: window included to get the threshold
%     binsize: decide the size of wave used to calculate one sample of
%              amp that used to construct the amp train.
%     smthBin: bin size to smooth

t = linspace(window(1), window(2), size(wave{1, 1}, 2));
tIndex = t > testWin(1) & t < testWin(2);
tTest = t(tIndex)';
wave = changeCellRowNum(wave);
smthSample = ceil(smthBin * fs / 1000);

% Attention: smoothdata fcn conduct smooth by column, so transpose
%            ( 64 * n to n * 64)
smthWave = cellfun(@(x) smoothdata(x(:, tIndex)','gaussian',smthSample)', wave, "UniformOutput", false);
[~, minIdx] = cellfun(@(x) min(x, [], 2), smthWave, "UniformOutput", false);
for mIndex= 1 : length(minIdx)
    minIdx{mIndex}(minIdx{mIndex} == 1) = [];
end
tMin = cellfun(@(x) tTest(x), minIdx, "UniformOutput", false);
latency_raw = tMin;
latency_mean = cell2mat(cellfun(@(x) mean(x), tMin, "UniformOutput", false));
latency_se = cell2mat(cellfun(@(x) std(x) / sqrt(length(x)), tMin, "UniformOutput", false));
end
