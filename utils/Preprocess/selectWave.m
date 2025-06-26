function trialsData = selectWave(data, fs, segTime, window)
% Inputs:
%   [data]: nch*nsample
%   [fs]: sample rate, in Hz
%   [segTime]: time for segmentation, in ms
%   [window]: [pre-segTime, post-segTime], in ms

windowIndex = fix(window / 1e3 * fs);
segIndex = arrayfun(@(x) fix(x / 1e3 * fs), segTime(:));
trialsData = arrayfun(@(x) data(:, x + windowIndex(1):x + windowIndex(2)), segIndex, "UniformOutput", false, "ErrorHandler", @mErrorFcn);

idx0 = cellfun(@(x) all(isnan(x), 'all'), trialsData);
idx1 = find(diff(idx0) == -1, 1, "first");
idx2 = find(diff(idx0) == 1, 1, "last");

if numel(idx1) > 1 || numel(idx2) > 1
    error("[window] too wide");
end

if idx0(1)
    trialsData{1} = nan(size(data, 1), diff(windowIndex) + 1);
    temp = segIndex(1) + windowIndex(1):segIndex(1) + windowIndex(2);
    idxTemp = find(temp > 0, 1);
    trialsData{1}(:, idxTemp:end) = data(:, temp(idxTemp:end));
end

if idx0(end)
    trialsData{end} = nan(size(data, 2), diff(windowIndex) + 1);
    temp = segIndex(end) + windowIndex(1):segIndex(end) + windowIndex(2);
    idxTemp = find(temp > size(data, 2), 1) - 1;
    trialsData{end}(:, 1:idxTemp) = data(:, temp(1:idxTemp));
end

return;
end