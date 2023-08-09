function Fig = plotRawWave256(chMean, chStd, window, titleStr)
narginchk(3, 4);
if nargin < 4 || isempty(titleStr)
    titleStr = '';
else
    titleStr = [' | ', char(titleStr)];
end
% split chMean to 4 cells
slides = siteMap256;
load(fullfile(fileparts(mfilename("fullpath")), "chMap_v1.mat"));
temp = sortrows(chMap, 2);
idx = temp(:, 1);
chMean = chMean(idx, :);
for sIndex = 1 : length(slides)
    Fig(sIndex) = plotRawWave(chMean, chStd, window, titleStr, [8, 11], slides{sIndex});
end
end