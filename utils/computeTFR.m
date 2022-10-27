function [TFR, t, f, coi] = computeTFR(chMean, fs, fsD, freqLimits, fRange)
    narginchk(2, 5);

    if nargin < 3
        fsD = [];
    end

    if nargin < 4 || isempty(freqLimits)
        freqLimits = [0, 128];
    end

    TFR = cell(size(chMean, 1), 1);
    
    for chNum = 1:size(chMean, 1)
        [t, f, TFR{chNum}, coi] = mCWT(double(chMean(chNum, :)), fs, 'morlet', fsD, freqLimits);
    end

    if nargin >= 5

        if numel(fRange) == 1
            [~, idx] = min(abs(f - fRange));
        elseif numel(fRange) == 2
            idx = find(f > fRange(2), 1, "last") + 1:find(f < fRange(1), 1) - 1;
        else
            error("Invalid frequency range input");
        end
        
        if isempty(idx)
            error("Data within frequency range not found");
        end

        TFR = cellfun(@(x) mean(x(idx, :), 1), TFR, "UniformOutput", false);
        f = f(idx);
    end

    return;
end
