function [ff, PMean, P]  = trialsECOGFFT(trialsECoG, fs, tIdx, chIdx, method)
narginchk(2, 5)
if nargin < 3
    tIdx = 1 : size(trialsECoG{1}, 2);
    chIdx = 1 : size(trialsECoG{1}, 1);
    method = 1;
end

if nargin < 4
    chIdx = 1 : size(trialsECoG{1}, 1);
    method = 1;
end

if nargin < 5
    method = 1;
end

if isempty(chIdx)
    chIdx = 1 : size(trialsECoG{1}, 1);
end

temp = changeCellRowNum(trialsECoG);


mParpool = gcp;
chTemp = cellfun(@(x) array2VectorCell(x), temp, "uni", false);
P = cell(length(chTemp), 1);
for ch = 1 : length(chTemp)
switch method % power, dB
    case 1
        %             [f, P{ch, 1}, ~] = cellfun(@(x) mFFT_Pow(x(tIdx), fs), chTemp, 'UniformOutput', false);
        F = parfeval(mParpool, @cellfun, 2, @(x) mFFT_Pow(x(tIdx), fs), chTemp{ch, 1}, 'UniformOutput', false);
        P{ch, 1} = F.OutputArguments{2};
    case 2 % magnitude
        %             [f, ~,  P{ch, 1}] = cellfun(@(x) mFFT_Base(x(tIdx), fs), chTemp, 'UniformOutput', false);
        F = parfeval(mParpool, @cellfun, 3, @(x) mFFT_Base(x(tIdx), fs), chTemp{ch, 1}, 'UniformOutput', false);
        while isempty(F.OutputArguments)
            pause(0.1);
        end
        P{ch, 1} = F.OutputArguments{3};
end
end
ff = F.OutputArguments{1}{1};
PMean = cell2mat(cellfun(@(x) smoothdata(mean(cell2mat(x)),'gaussian', 1), P, "uni", false));

end





