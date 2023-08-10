function grangerPT = mGranger_PermutationTest(trialsECOG_AC, trialsECOG_PFC, windowData, fs, nIter, chsAC, chsPFC)
% Description: return average granger spectrum of permutation test
% Input:
%     trialsECOG_AC: trialsECOG data of AC
%     trialsECOG_PFC: trialsECOG data of PFC
%     windowData: data window, in ms
%     fs: sample rate, in Hz
%     nIter: iterations (default: 1e3)
% Output:
%     grangerPT: contains average granger spectrum of permutation test

narginchk(4, 7);

if nargin < 5
    nIter = 1e3;
end

if nargin < 6
    chsAC = 1:size(trialsECOG_AC{1}, 1);
end

if nargin < 7
    chsPFC = 1:size(trialsECOG_PFC{1}, 1);
end

ft_setPath2Top;

%% Prepare data
nChs = size(trialsECOG_AC{1}, 1) + size(trialsECOG_PFC{1}, 1);
nTrials = length(trialsECOG_AC);

time = repmat({linspace(windowData(1), windowData(2), size(trialsECOG_AC{1}, 2)) / 1000}, [1, nTrials]);
labels = mat2cell(char([rowFcn(@(x) strcat('AC-', strrep(x, ' ', '0')), string(num2str((1:size(trialsECOG_AC{1}, 1))'))); ...
                        rowFcn(@(x) strcat('PFC-', strrep(x, ' ', '0')), string(num2str((1:size(trialsECOG_PFC{1}, 1))')))]), ...
                  ones(nChs, 1));

randOrderAC  = cell2mat(rowFcn(@(x) randperm(length(trialsECOG_AC)),  (1:nIter)', "UniformOutput", false));
randOrderPFC = cell2mat(rowFcn(@(x) randperm(length(trialsECOG_PFC)), (1:nIter)', "UniformOutput", false));

res = zeros(nChs, nChs, length(0:fs / 2), nIter);

%% Permutation test
parfor index = 1:nIter
    %% Randomization
    data = [];
    data.time    = time;
    data.label   = labels;
    data.fsample = fs;
    data.trial   = cellfun(@(x, y) [x; y], trialsECOG_AC(randOrderAC(index, :)), trialsECOG_PFC(randOrderPFC(index, :)), "UniformOutput", false)';

%     %% Multivariate autoregressive model
%     cfg         = [];
%     cfg.order   = 10; % lag, default=10
%     cfg.toolbox = 'bsmart';
%     cfg.channel = data.label([chsAC, chsPFC + size(trialsECOG_AC{1}, 1)]);
%     mdata       = ft_mvaranalysis(cfg, data);
%     
%     %% Parametric computation of the spectral transfer function
%     cfg         = [];
%     cfg.method  = 'mvar';
%     cfg.channel = data.label([chsAC, chsPFC + size(trialsECOG_AC{1}, 1)]);
%     mfreq       = ft_freqanalysis(cfg, mdata);
%     
%     %% Granger
%     cfg         = [];
%     cfg.method  = 'granger';
%     cfg.channel = data.label([chsAC, chsPFC + size(trialsECOG_AC{1}, 1)]);
%     granger     = ft_connectivityanalysis(cfg, mfreq);

    % Nonparametric computation of the cross-spectral density matrix
    cfg           = [];
    cfg.method    = 'mtmfft';
    cfg.taper     = 'hanning';
    cfg.output    = 'fourier';
    cfg.tapsmofrq = 2;
    cfg.channel   = data.label(labelIdx);
    freq          = ft_freqanalysis(cfg, data);

    % Nonparametric computation of Granger causality
    cfg = [];
    cfg.method    = 'granger';
    cfg.channel   = data.label(labelIdx);
    granger       = ft_connectivityanalysis(cfg, freq);

    res(:, :, :, index) = granger.grangerspctrm;
end

grangerPT.grangerspctrm = mean(res, 4);
grangerPT.label = labels;
grangerPT.dimord = 'chan_chan_freq';
grangerPT.freq = 0:fs / 2;
return;
end