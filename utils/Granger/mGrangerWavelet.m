function res = mGrangerWavelet(trialsDataSeed, trialsDataTarget, fs, nperm)
% [trialsDataSeed] is nTrial*1 cell with elements of 1*nSample vector
% [trialsDataTarget] is nTrial*1 cell with elements of nChs*nSample matrix
% If [nperm] is larger than 1, perform permutation test by randomizing trial order.

narginchk(3, 4);

if nargin < 4
    nperm = 1;
end

%% Wavelet transform
disp('Performing cwt on data...');
tic;
trialsData = cellfun(@(x, y) [x; y], trialsDataSeed, trialsDataTarget, "UniformOutput", false);
[nChs, nTime] = size(trialsData{1});
if exist(['cwtMultiAll', num2str(nTime), 'x', num2str(nChs), '_mex.mexw64'], 'file')
    disp('Using GPU...');
    cwtFcn = eval(['@cwtMultiAll', num2str(nTime), 'x', num2str(nChs), '_mex']);
    [cwtres, f, coi] = cellfun(@(x) cwtFcn(x', fs), trialsData, "UniformOutput", false);
    cwtres = cellfun(@gather, cwtres, "UniformOutput", false);
    f = gather(f{1});
    coi = gather(coi{1});
else
    disp('Using CPU...');
    cwtFcn = @cwtMultiAll;
    [cwtres, f, coi] = cellfun(@(x) cwtFcn(x', fs), trialsData, "UniformOutput", false);
    f = f{1};
    coi = coi{1};
end
toc;

% trans log-scaled [f] to linear-spaced and pad with zero
f = 10 * log(f);
c = 0 - f(end);
f = f + c;

t = (0:size(trialsData{1}, 2) - 1) / fs;

cwtres = cellfun(@(x) permute(x, [4, 3, 1, 2]), cwtres, "UniformOutput", false);
cwtres = cell2mat(cwtres); % rpt_chan_freq_time

data = [];
data.freq = f;
data.time = t;
data.label = [{'seed'}; cellstr(num2str((1:size(trialsDataTarget{1}, 1))'))];
data.dimord = 'rpt_chan_freq_time';
data.cumtapcnt = ones(length(t), length(f));
data.fourierspctrm = cwtres;

%% granger causality computation
currentPath = pwd;
cd(fullfile(fileparts(which("ft_defaults")), 'connectivity', 'private'));

res = mGrangerWaveletImpl(data);
res.dimord = 'chancmb_freq_time';
res.freq = exp((res.freq - c) / 10);
res.coi = coi;
res.chancmbtype = {'from', 'to'};

if nperm > 1
    disp("Performing permutation test...");
    
    grangerspctrm = zeros(length(data.label(2:end)) * 2, length(f), length(t), nperm + 1);
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
return;
end