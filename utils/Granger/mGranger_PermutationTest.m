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
    nIter = 500;
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
dataByChAC   = changeCellRowNum(trialsECOG_AC);
dataByChPFC  = changeCellRowNum(trialsECOG_PFC);

temp = mGranger(trialsECOG_AC{1}(1, :), trialsECOG_PFC{1}(1, :), windowData, fs, "parametricOpt", "P");
f = temp.freq;
res = zeros(nIter, nChs, nChs, length(f));

%% Permutation test
parfor index = 1:nIter
    %% Randomization
    data = [];
    data.time    = time;
    data.label   = labels;
    data.fsample = fs;
    temp1 = changeCellRowNum(cellfun(@(x) x(randOrderAC(index, :), :), dataByChAC, "UniformOutput", false));
    temp2 = changeCellRowNum(cellfun(@(x) x(randOrderPFC(index, :), :), dataByChPFC, "UniformOutput", false));
    data.trial   = cellfun(@(x, y) [x; y], temp1, temp2, "UniformOutput", false)';

    % Multivariate autoregressive model
    cfg         = [];
    % cfg.order   = 5; % lag, default=10
    cfg.method  = 'bsmart';
    cfg.channel = data.label;
    mdata       = ft_mvaranalysis(cfg, data);
    
    % Parametric computation of the spectral transfer function
    cfg         = [];
    cfg.method  = 'mvar';
    cfg.channel = data.label;
    mfreq       = ft_freqanalysis(cfg, mdata);
    
    % Parametric computation of Granger causality
    cfg         = [];
    cfg.method  = 'granger';
    cfg.channel = data.label;
    granger     = ft_connectivityanalysis(cfg, mfreq);

    res(index, :, :, :) = granger.grangerspctrm;
end

grangerPT.grangerspctrm = res;
grangerPT.label = labels;
grangerPT.dimord = 'nrpt_chan_chan_freq';
grangerPT.freq = f;
return;
end