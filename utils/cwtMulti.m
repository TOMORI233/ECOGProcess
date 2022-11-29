function [CData, f, coi] = cwtMulti(data, fs, fRange)
    [nSample, nTrial] = size(data);
    [~, f, coi] =cwt(data(:, 1), 'amor', fs);
    fIdx = find(f > fRange(1) & f < fRange(2));
    fIdx(1) = max([fIdx(1) - 1, 1]);
    fIdx(2) = min([fIdx(2) + 1, length(f)]);
    CData = zeros(nSample, nTrial);

    parfor index = 1:nTrial
        wt = cwt(data(:, index), 'amor', fs);
        CData(:, index) = mean(abs(wt(fIdx, :)), 1);
    end

    return;
end