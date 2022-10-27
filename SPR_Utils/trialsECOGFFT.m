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


for ch = chIdx
    chTemp = array2VectorCell(temp{ch});
    switch method % power, dB
        case 1
            [f, P{ch, 1}, ~] = cellfun(@(x) mFFT_Pow(x(tIdx), fs), chTemp, 'UniformOutput', false);
        case 2 % magnitude
            [f, ~,  P{ch, 1}] = cellfun(@(x) mFFT_Base(x(tIdx), fs), chTemp, 'UniformOutput', false);
    end
    ff = f{1};
    PMean(ch, :) = smoothdata(mean(cell2mat(P{ch, 1})),'gaussian', 1);
end