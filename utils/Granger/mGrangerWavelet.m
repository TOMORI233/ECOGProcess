function res = mGrangerWavelet(trialsDataSeed, trialsDataTarget, fs, fRange, nperm)
% Compute granger causality using raw data.
% 
% [trialsDataSeed] is nTrial*1 cell with elements of 1*nSample vector.
% [trialsDataTarget] is nTrial*1 cell with elements of nChs*nSample matrix.
% [fRange] specifies frequency limit for granger causality computation. (default: [] for all)
% If [nperm] is larger than 1, perform permutation test by randomizing trial order.

narginchk(3, 5);

if nargin < 4
    fRange = [];
end

if nargin < 5
    nperm = 1;
end

%% Wavelet transform
data = prepareDataRaw(trialsDataSeed, trialsDataTarget, fs, fRange);
c = data.c;

%% granger causality computation
t0 = tic;
currentPath = pwd;
cd(fullfile(fileparts(which("ft_defaults")), 'connectivity', 'private'));

res = mGrangerWaveletImpl(data);
res.dimord = 'chancmb_freq_time';
res.freq = exp((res.freq - c) / 10);
res.coi = data.coi;
res.chancmbtype = {'from', 'to'};

[nTrial, nCh, nFreq, nTime] = size(data.fourierspctrm);

if nperm > 1
    disp("Performing permutation test...");
    
    grangerspctrm = zeros((nCh - 1) * 2, nFreq, nTime, nperm + 1);
    grangerspctrm(:, :, :, 1) = res.grangerspctrm;
    for index = 1:nperm
        fprintf('Randomization %d: ', index);
        tic;
        % trial randomization
        for chIdx = 1:size(data.fourierspctrm, 2)
            data.fourierspctrm(:, chIdx, :, :) = data.fourierspctrm(randperm(size(data.fourierspctrm, 1)), chIdx, :, :);
        end
    
        temp = mGrangerWaveletImpl(data);
        grangerspctrm(:, :, :, 1 + index) = temp.grangerspctrm;
        toc;
    end

    res.grangerspctrm = grangerspctrm;
    res.dimord = 'chancmb_freq_time_perm';
end

disp("Granger causality computation from wavelet transforms of time series data done");
cd(currentPath);
toc(t0);
return;
end