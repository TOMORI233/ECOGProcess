function res = mCoherenceWaveletRaw(trialsDataSeed, trialsDataTarget, fs, fRange, nperm)
% Compute wavelet-based coherence using raw data.
% 
% [trialsDataSeed] is nTrial*1 cell with elements of 1*nSample vector.
% [trialsDataTarget] is nTrial*1 cell with elements of nChs*nSample matrix.
% [fRange] specifies frequency limit for coherence computation. (default: [] for all)
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

%% Coherence computation
disp('Coherence computation starts...');
t0 = tic;
currentPath = pwd;
cd(fullfile(fileparts(which("ft_defaults")), 'connectivity', 'private'));

res = mCoherenceWaveletImpl(data);
res.dimord = 'chan_chan_freq_time';
res.freq = exp((res.freq - c) / 10);
res.coi = data.coi;

[nTrial, nCh, nFreq, nTime] = size(data.fourierspctrm);

if nperm > 1
    disp(['Performing permutation test (total: ', num2str(nperm), ')...']);

    % Use fixed permutation order
    try
        % Delete this file for randomized permutation order
        load(fullfile(fileparts(mfilename("fullpath")), "private", "randord.mat"), "randord");
        if size(randord, 1) ~= nperm || size(randord, 2) ~= nTrial
            ME = MException('mCoherenceWavelet:SizeNotMatch', ...
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
    
    coherencespctrm = zeros(nCh, nCh, nFreq, nTime, nperm + 1);
    coherencespctrm(:, :, :, :, 1) = res.coherencespctrm;
    for index = 1:nperm
        fprintf('Randomization %d/%d: ', index, nperm);
        t1 = tic;

        % Trial randomization: based on the random orders of the last permutation
        data.fourierspctrm(:, 1, :, :) = data.fourierspctrm(randord(index, :), 1, :, :);
        
        % GC computation
        temp = mCoherenceWaveletImpl(data);
        coherencespctrm(:, :, :, :, 1 + index) = temp.coherencespctrm;

        fprintf('done in %.4f s\n', toc(t1));
    end

    res.coherencespctrm = coherencespctrm;
    res.dimord = 'chan_chan_freq_time_perm';
end

disp(['Coherence computation from wavelet transforms of time series data done in ', num2str(toc(t0)), ' s']);
cd(currentPath);
return;
end