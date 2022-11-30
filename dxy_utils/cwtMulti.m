function [CData, f, coi] = cwtMulti(data, fs, fRange)
    [nSample, nTrial] = size(data);
    [~, f, coi] =cwt(data(:, 1), 'amor', fs);
    fIdx = max([find(f > fRange(2), 1, "last") + 1, 1]):min([find(f < fRange(1), 1) - 1, length(f)]);
    CData = zeros(nSample, nTrial);

    parfor index = 1:nTrial
        wt = cwt(data(:, index), 'amor', fs);
        CData(:, index) = mean(abs(wt(fIdx, :)), 1);
    end

    return;
end