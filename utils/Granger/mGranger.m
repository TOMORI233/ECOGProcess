function [granger, coh, cohm] = mGranger(trialsECOG_AC, trialsECOG_PFC, window, fs)
% Description: return granger spectrum, and coherence of parametric computation 
%              of the spectral transfer function and of non-parametric computation 
%              of the cross-spectral density matrix
% Input:
%     trialsECOG_AC: trialsECOG data of AC
%     trialsECOG_PFC: trialsECOG data of PFC
%     window: data window, in ms
%     fs: sample rate, in Hz
% Output:
%     granger: granger spectrum containing fields:
%              - grangerspctrm: nChs*nChs*length(0:fs/2)
%              - freq: vector 0:fs/2
%     coh: coherence of non-parametric computation of the cross-spectral density matrix
%     cohm: coherence of parametric computation of the spectral transfer function

ft_setPath2Top;

%% Prepare data
data.trial = cellfun(@(x, y) [x; y], trialsECOG_AC, trialsECOG_PFC, "UniformOutput", false)';
data.time = repmat({linspace(window(1), window(2), size(trialsECOG_AC{1}, 2)) / 1000}, [1, length(data.trial)]);
data.fsample = fs;
data.label = mat2cell(char([rowFcn(@(x) strcat('AC-', strrep(x, ' ', '0')), string(num2str((1:size(trialsECOG_AC{1}, 1))'))); ...
                            rowFcn(@(x) strcat('PFC-', strrep(x, ' ', '0')), string(num2str((1:size(trialsECOG_PFC{1}, 1))')))]), ...
                      ones(size(data.trial{1}, 1), 1));

%% Multivariate autoregressive model
cfg         = [];
cfg.order   = 5;
cfg.toolbox = 'bsmart';
mdata       = ft_mvaranalysis(cfg, data);

%% Parametric computation of the spectral transfer function
cfg        = [];
cfg.method = 'mvar';
mfreq      = ft_freqanalysis(cfg, mdata);

%% Non-parametric computation of the cross-spectral density matrix
cfg           = [];
cfg.method    = 'mtmfft';
cfg.taper     = 'dpss';
cfg.output    = 'fourier';
cfg.tapsmofrq = 2;
freq          = ft_freqanalysis(cfg, data);

%% Coherence
cfg           = [];
cfg.method    = 'coh';
coh           = ft_connectivityanalysis(cfg, freq);
cohm          = ft_connectivityanalysis(cfg, mfreq);

%% Granger
cfg           = [];
cfg.method    = 'granger';
granger       = ft_connectivityanalysis(cfg, mfreq);
