function [granger, varargout] = mGranger(trialsECOG_AC, trialsECOG_PFC, windowData, fs, chsAC, chsPFC)
% Description: return granger spectrum, and coherence of parametric computation 
%              of the spectral transfer function and of non-parametric computation 
%              of the cross-spectral density matrix
% Input:
%     trialsECOG_AC: trialsECOG data of AC
%     trialsECOG_PFC: trialsECOG data of PFC
%     windowData: data window, in ms
%     fs: sample rate, in Hz
%     chsAC: channel number of AC to perform Granger analysis on (double row vector)
%     chsPFC: channel number of PFC to perform Granger analysis on (double row vector)
% Output:
%     granger: granger spectrum containing fields:
%              - grangerspctrm: nChs*nChs*length(0:fs/2)
%              - freq: vector 0:fs/2
%     coh: coherence of non-parametric computation of the cross-spectral density matrix
%     cohm: coherence of parametric computation of the spectral transfer function

narginchk(4, 6);

if nargin < 5
    chsAC = 1:size(trialsECOG_AC);
end

if nargin < 6
    chsPFC = 1:size(trialsECOG_PFC);
end

ft_setPath2Top;

%% Prepare data
data.trial = cellfun(@(x, y) [x; y], trialsECOG_AC, trialsECOG_PFC, "UniformOutput", false)';
data.time = repmat({linspace(windowData(1), windowData(2), size(trialsECOG_AC{1}, 2)) / 1000}, [1, length(data.trial)]); % normalize
data.fsample = fs;
data.label = mat2cell(char([rowFcn(@(x) strcat('AC-', strrep(x, ' ', '0')), string(num2str((1:size(trialsECOG_AC{1}, 1))'))); ...
                            rowFcn(@(x) strcat('PFC-', strrep(x, ' ', '0')), string(num2str((1:size(trialsECOG_PFC{1}, 1))')))]), ...
                      ones(size(data.trial{1}, 1), 1));

%% Multivariate autoregressive model
cfg         = [];
% cfg.order   = 5; % lag, default=10
cfg.method  = 'bsmart';
cfg.channel = data.label([chsAC, chsPFC + size(trialsECOG_AC{1}, 1)]);
mdata       = ft_mvaranalysis(cfg, data);

%% Parametric computation of the spectral transfer function
cfg         = [];
cfg.method  = 'mvar';
cfg.channel = data.label([chsAC, chsPFC + size(trialsECOG_AC{1}, 1)]);
mfreq       = ft_freqanalysis(cfg, mdata);

%% Granger
cfg         = [];
cfg.method  = 'granger';
cfg.channel = data.label([chsAC, chsPFC + size(trialsECOG_AC{1}, 1)]);
granger     = ft_connectivityanalysis(cfg, mfreq);

%% Non-parametric computation of the cross-spectral density matrix
if nargout > 1
    cfg           = [];
    cfg.method    = 'mtmfft';
    cfg.taper     = 'dpss';
    cfg.output    = 'fourier';
    cfg.tapsmofrq = 2;
    cfg.channel   = data.label([chsAC, chsPFC + size(trialsECOG_AC{1}, 1)]);
    freq          = ft_freqanalysis(cfg, data);
end

%% Coherence
cfg           = [];
cfg.method    = 'coh';
cfg.channel   = data.label([chsAC, chsPFC + size(trialsECOG_AC{1}, 1)]);
if nargout == 2
    coh           = ft_connectivityanalysis(cfg, freq);
    varargout{1}  = coh;
elseif nargout == 3
    cohm          = ft_connectivityanalysis(cfg, mfreq);
    varargout{2}  = cohm;
end
