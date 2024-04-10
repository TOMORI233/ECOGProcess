function p = mGrangerWaveletFourierDiffPT(cwtres1, cwtres2, f, coi, fs, fRange, nperm)
% This function performs two-tailed permutation test on differential GC by 
% shuffling data in the order of trials.
%
% The output [p] is a nChannelcmb*nFreq*nTime double matirx, where nChannelcmb=2*(nCh - 1).
% 
% [cwtres1] and [cwtres2] are nTrial*nCh*nFreq*nTime double matrices.
% The first channel is 'seed' and the rest channels are 'target'.
% The number of trials may be different for [cwtres1] and [cwtres2].
% 
% [f] is a descendent column vector in log scale.
% 
% [coi] does not influence the result.
% Leave it empty if you do not need it.
% 
% [fRange] specifies frequency limit for granger causality computation. (default: [] for all)
% 
% [nperm] specifies the total number of shuffling. (default: 1e3)

narginchk(5, 7);

if nargin < 6
    fRange = [];
end

if nargin < 7
    nperm = 1e3;
end

%% Wavelet transform
% Use existed cwt data
data1 = prepareDataFourier(cwtres1, f, coi, fs, fRange);
data2 = prepareDataFourier(cwtres2, f, coi, fs, fRange);

%% 
t0 = tic;
currentPath = pwd;
cd(fullfile(fileparts(which("ft_defaults")), 'connectivity', 'private'));

res1 = mGrangerWaveletImpl(data1);
res2 = mGrangerWaveletImpl(data2);

%% 
[nTrial1, nCh, nFreq, nTime] = size(cwtres1);
nTrial2 = size(cwtres2, 1);

randord1 = zeros(nperm, nTrial1);
randord2 = zeros(nperm, nTrial2);
for index = 1:nperm
    randord1(index, :) = randperm(nTrial1);
    randord2(index, :) = randperm(nTrial2);
end

[grangerspctrm1, grangerspctrm2] = deal(zeros((nCh - 1) * 2, nFreq, nTime, nperm + 1));
grangerspctrm1(:, :, :, 1) = res1.grangerspctrm;
grangerspctrm2(:, :, :, 1) = res2.grangerspctrm;
parfor index = 1:nperm
    % Trial randomization
    dataTemp = data1;
    dataTemp.fourierspctrm(:, 1, :, :) = data1.fourierspctrm(randord1(index, :), 1, :, :);
    grangerspctrm1(:, :, :, 1 + index) = mGrangerWaveletImpl(dataTemp).grangerspctrm;

    dataTemp = data2;
    dataTemp.fourierspctrm(:, 1, :, :) = data2.fourierspctrm(randord2(index, :), 1, :, :);
    grangerspctrm2(:, :, :, 1 + index) = mGrangerWaveletImpl(dataTemp).grangerspctrm;
end

grangerspctrmDiff = grangerspctrm1 - grangerspctrm2;
p = sum(abs(grangerspctrmDiff(:, :, :, 2:end)) > abs(grangerspctrmDiff(:, :, :, 1)), 4) ./ nperm;
disp(['Permutation test for differential GC done in ', num2str(toc(t0)), ' s']);
cd(currentPath);
return;
end