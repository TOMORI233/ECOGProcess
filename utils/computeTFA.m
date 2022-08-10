function [t, f, TFR, coi] = computeTFA(chMean, fs0, fs)
    TFR = [];
    
    for chNum = 1:size(chMean, 1)
        [t, f, CData, coi] = mCWT(double(chMean(chNum, :)), fs0, 'morlet', fs);

        if isempty(TFR)
            TFR = zeros(length(f), length(t), size(chMean, 1));
        end

        TFR(:, :, chNum) = CData;
    end

    return;
end
