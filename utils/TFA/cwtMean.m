function [CData, f, coi] = cwtMean(data, fs, fRange)
[~, f, coi] =cwt(data(:, 1), 'amor', fs);
[nSample, nTrial] = size(data);
if diff(fRange) > 0
    fIdx = find(f > fRange(1) & f < fRange(2));
    fIdx(1) = max([fIdx(1) - 1, 1]);
    fIdx(2) = min([fIdx(2) + 1, length(f)]);
else
    fIdx = 1 : length(f);
end

CData = zeros(length(fIdx), nSample, nTrial);
parfor index = 1:nTrial
    wt = cwt(data(:, index), 'amor', fs);
    CData(:, :, index) = abs(wt(fIdx, :));
end

f = f(fIdx);
return;
end