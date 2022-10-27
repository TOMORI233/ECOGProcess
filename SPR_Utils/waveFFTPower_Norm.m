function [normPow, soundTrialsFFT, sponTrialsFFT]  = waveFFTPower_Norm(soundTrialsFFT, sponTrialsFFT, method, ff, fScale)

narginchk(3, 5);

if nargin > 4
    if numel(fScale) > 1
        fIndex = find(ff{1} >= fScale(1) & ff{1} <= fScale(2));
        fIndex_Spon = find(ff{2} >= fScale(1) & ff{2} <= fScale(2));
    else
        fIndex = fScale;
        fIndex_Spon = fScale;
    end
    for cIndex = 1 : length(soundTrialsFFT)
        soundTrialsFFT{cIndex} = cell2mat(cellfun(@(x) max(x(fIndex)), soundTrialsFFT{cIndex}, "UniformOutput", false));
        sponTrialsFFT{cIndex} = cell2mat(cellfun(@(x) max(x(fIndex_Spon)), sponTrialsFFT{cIndex}, "UniformOutput", false));
    end
end


switch method
    case 1
        normPow = cellfun(@(x, y)  x./y, soundTrialsFFT, sponTrialsFFT, "UniformOutput", false);
    case 2
        normPow = cellfun(@(x, y)  (x - y)./(x + y), soundTrialsFFT, sponTrialsFFT, "UniformOutput", false);
end


