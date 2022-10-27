function [TFR, t, f, coi] = computeTFA(chMean, fs, fsD, freqLimits)
    narginchk(2, 4);

    if nargin < 3
        fsD = [];
    end

    if nargin < 4
        freqLimits = [0, 128];
    end

    TFR = cell(size(chMean, 1), 1);
    
    for chNum = 1:size(chMean, 1)
        [t, f, TFR{chNum}, coi] = mCWT(double(chMean(chNum, :)), fs, 'morlet', fsD, freqLimits);
    end

    return;
end
