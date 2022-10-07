function [ff, PMean, P]  = trialsECOGFFT(trialsECoG, fs, tIdx, chIdx)
narginchk(2, 4)
if nargin < 3
    tIdx = 1 : size(trialsECoG{1}, 2);
    chIdx = 1 : size(trialsECoG{1}, 1);
end

if nargin < 4
    chIdx = 1 : size(trialsECoG{1}, 1);
end

temp = changeCellRowNum(trialsECoG);


for ch = chIdx
    chTemp = array2VectorCell(temp{ch});
    [f, ~, P{ch, 1}] = cellfun(@(x) mFFT(x(tIdx), fs), chTemp, 'UniformOutput', false);
    ff = f{1};
    PMean(ch, :) = smoothdata(mean(cell2mat(P{ch, 1})),'gaussian', 1);
end