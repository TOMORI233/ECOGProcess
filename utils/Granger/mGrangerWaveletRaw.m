function res = mGrangerWaveletRaw(trialsDataSeed, trialsDataTarget, fs, fRange, nperm)
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
disp('Granger causality computation starts...');
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
    disp(['Performing permutation test (total: ', num2str(nperm), ')...']);

    % Use fixed permutation order
    try
        % Delete this file for randomized permutation order
        load(fullfile(fileparts(mfilename("fullpath")), "private", "randord.mat"), "randord");
        if size(randord, 1) ~= nperm || size(randord, 2) ~= nTrial
            ME = MException('mGrangerWavelet:SizeNotMatch', ...
                            'Size of random order matrix does not match size of data');
            throw(ME);
        end
    catch ME
        disp(ME.message);
        disp('Generate random trial orders for seed channel');
        randord = zeros(nperm, nTrial);
        for index = 1:nperm
            randord(index, :) = randperm(nTrial);
        end
        save(fullfile(fileparts(mfilename("fullpath")), "private", "randord.mat"), "randord");
    end
    
    grangerspctrm = zeros((nCh - 1) * 2, nFreq, nTime, nperm + 1);
    grangerspctrm(:, :, :, 1) = res.grangerspctrm;
    parfor_progress(nperm);
    parfor index = 1:nperm
        % Trial randomization
        dataTemp = data;
        dataTemp.fourierspctrm(:, 1, :, :) = data.fourierspctrm(randord(index, :), 1, :, :);
        
        % GC computation
        temp = mGrangerWaveletImpl(dataTemp);
        grangerspctrm(:, :, :, 1 + index) = temp.grangerspctrm;

        parfor_progress;
    end
    parfor_progress(0);

    res.grangerspctrm = grangerspctrm;
    res.dimord = 'chancmb_freq_time_perm';
end

disp(['Nonparametric Granger causality computation from wavelet transforms of time series data done in ', num2str(toc(t0)), ' s']);
cd(currentPath);
return;
end