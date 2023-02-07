function [H, P] = waveFFTPower_pValue(soundTrialsFFT, sponTrialFFT, ff, fScale, method)

narginchk(4, 5);

if nargin < 5
    method = 2;
end
if numel(fScale) > 1
    fIndex = find(ff{1} >= fScale(1) & ff{1} <= fScale(2));
else
    fIndex = fScale;
end
if isnumeric(soundTrialsFFT{1})
    soundTrialsFFT = cellfun(@(x) num2cell(x, 2), soundTrialsFFT, "UniformOutput", false);
    sponTrialFFT = cellfun(@(x) num2cell(x, 2), sponTrialFFT, "UniformOutput", false);
end

switch method
    case 1
        for cIndex = 1 : length(soundTrialsFFT)
            temp = cellfun(@(x) x(fIndex), soundTrialsFFT{cIndex}, "UniformOutput", false);
            target{cIndex} = cell2mat(cellfun(@(x) max(x), temp, "UniformOutput", false));
            base{cIndex} = reshape(cell2mat(cellfun(@(x) x(x ~= max(x)), temp, "UniformOutput", false)), [], 1);
        end

    case 2
        for cIndex = 1 : length(soundTrialsFFT)
            temp = cellfun(@(x) x(fIndex), soundTrialsFFT{cIndex}, "UniformOutput", false);
            temp2 = cellfun(@(x) interp1(ff{2}, x, ff{1}, "linear"), sponTrialFFT{cIndex}, "UniformOutput", false);
            temp2 = cellfun(@(x) x(fIndex), temp2, "UniformOutput", false);
            [targetTemp, index] = cellfun(@(x) max(x), temp, "UniformOutput", false);
            target{cIndex} = cell2mat(targetTemp);
            selIdx = min([length(temp2), length(index)]);
            base{cIndex} = cell2mat(cellfun(@(x, y) max(x(y)), temp2(1 : selIdx), index(1 : selIdx), "UniformOutput", false));
        end

    case 3
        fIndex_Base = find(ff{2} >= fScale(1) & ff{2} <= fScale(2));
        for cIndex = 1 : length(soundTrialsFFT)
            temp = cellfun(@(x) x(fIndex), soundTrialsFFT{cIndex}, "UniformOutput", false);
            temp2 = cellfun(@(x) x(fIndex_Base), sponTrialFFT{cIndex}, "UniformOutput", false);
            target{cIndex} = cell2mat(cellfun(@(x) max(x), temp, "UniformOutput", false));
            base{cIndex} = cell2mat(cellfun(@(x) max(x), temp2, "UniformOutput", false));
        end
end


[H, P] = cellfun(@(x, y) ttest2(x, y, 'Alpha', 0.05), target, base, "UniformOutput", false);
H = cell2mat(H)';
P = cell2mat(P)';




