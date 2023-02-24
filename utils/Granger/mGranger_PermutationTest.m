function grangerPT = mGranger_PermutationTest(trialsECOG_AC, trialsECOG_PFC, windowData, fs, nIter)
% Description: return average granger spectrum of permutation test
% Input:
%     trialsECOG_AC: trialsECOG data of AC
%     trialsECOG_PFC: trialsECOG data of PFC
%     windowData: data window, in ms
%     fs: sample rate, in Hz
%     nIter: iterations (default: 1e3)
% Output:
%     grangerPT: contains average granger spectrum of permutation test

narginchk(4, 5);

if nargin < 5
    nIter = 1e3;
end

ft_setPath2Top;

%% Prepare data
trialsECOG = cellfun(@(x, y) [x; y], trialsECOG_AC, trialsECOG_PFC, "UniformOutput", false)';
time = repmat({linspace(windowData(1), windowData(2), size(trialsECOG{1}, 2)) / 1000}, [1, length(trialsECOG)]); % normalize
labels = mat2cell(char([rowFcn(@(x) strcat('AC-', strrep(x, ' ', '0')), string(num2str((1:size(trialsECOG_AC{1}, 1))'))); ...
                       rowFcn(@(x) strcat('PFC-', strrep(x, ' ', '0')), string(num2str((1:size(trialsECOG_PFC{1}, 1))')))]), ...
                       ones(size(trialsECOG{1}, 1), 1));
nChs = size(trialsECOG{1}, 1);

res = zeros(nChs, nChs, length(0:fs / 2), nIter);

%% Permutation test
parfor index = 1:nIter
    %% Randomization
    orders = randperm(nChs);
    data = [];
    data.time    = time;
    data.label   = labels;
    data.fsample = fs;
    data.trial   = cellfun(@(x) x(orders, :), trialsECOG, "UniformOutput", false);

    %% Multivariate autoregressive model
    cfg         = [];
    cfg.order   = 5;
    cfg.toolbox = 'bsmart';
    mdata       = ft_mvaranalysis(cfg, data);
    
    %% Parametric computation of the spectral transfer function
    cfg        = [];
    cfg.method = 'mvar';
    mfreq      = ft_freqanalysis(cfg, mdata);
    
    %% Granger
    cfg           = [];
    cfg.method    = 'granger';
    granger       = ft_connectivityanalysis(cfg, mfreq);

    res(:, :, :, index) = granger.grangerspctrm;
end

grangerPT.grangerspctrm = mean(res, 4);
grangerPT.label = mat2cell(num2str((1:length(labels))'), ones(length(labels), 1));
grangerPT.dimord = 'chan_chan_freq';
grangerPT.freq = 0:fs / 2;
return;
end