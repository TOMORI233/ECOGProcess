function [CData, f, coi] = cwtMean(data, fs, fRange)
[~, f, coi] =cwt(data(:, 1), 'amor', fs);
[nSample, nTrial] = size(data);
if diff(fRange) > 0
    fIdx = max([find(f > fRange(2), 1, "last")+1, 1]) : min([find(f < fRange(1), 1)-1, length(f)]);
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