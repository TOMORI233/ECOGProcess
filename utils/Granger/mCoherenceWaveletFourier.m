function res = mCoherenceWaveletFourier(cwtres, f, coi, fs, fRange, nperm)
% Compute wavelet-based coherence using existed cwt data.
% 
% The procedure is independent for each time sample and frequency. 
% Thus, it is possible to segment cwt data for computation effeciency 
% (consider coi in this step).
% 
% [cwtres] is a nTrial*nCh*nFreq*nTime matrix.
% The first channel is 'seed' and the rest channels are 'target'.
% [f] is a descendent column vector in log scale.
% [fRange] specifies frequency limit for coherence computation. (default: [] for all)
% If [nperm] is larger than 1, perform permutation test by randomizing trial order.

narginchk(4, 6);

if nargin < 5
    fRange = [];
end

if nargin < 6
    nperm = 1;
end

%% Wavelet transform
data = prepareDataFourier(cwtres, f, coi, fs, fRange);
c = data.c;

%% Coherence computation
disp('Coherence computation starts...');
t0 = tic;
currentPath = pwd;
cd(fullfile(fileparts(which("ft_defaults")), 'connectivity', 'private'));

res = mCoherenceWaveletImpl(data);
res.dimord = 'chancmb_freq_time';
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
    parfor_progress(nperm);
    parfor index = 1:nperm
        % Trial randomization
        dataTemp = data;
        dataTemp.fourierspctrm(:, 1, :, :) = data.fourierspctrm(randord(index, :), 1, :, :);
        
        % GC computation
        temp = mCoherenceWaveletImpl(dataTemp);
        coherencespctrm(:, :, :, :, 1 + index) = temp.coherencespctrm;

        parfor_progress;
    end
    parfor_progress(0);

    res.coherencespctrm = coherencespctrm;
    res.dimord = 'chancmb_freq_time_perm';
end

disp(['Coherence computation from wavelet transforms of time series data done in ', num2str(toc(t0)), ' s']);
cd(currentPath);
return;
end