function [granger, coh] = mGranger(trialsECOG_AC, trialsECOG_PFC, windowData, fs, varargin)
% Description: return Granger spectrum, and coherence of parametric computation 
%              of the spectral transfer function and of non-parametric computation 
%              of the cross-spectral density matrix
% Input:
%     trialsECOG_AC: trialsECOG data of AC
%     trialsECOG_PFC: trialsECOG data of PFC
%     windowData: data window, in ms
%     fs: sample rate, in Hz
%     chsAC: channel number of AC to perform Granger analysis on (double row vector)
%     chsPFC: channel number of PFC to perform Granger analysis on (double row vector)
%     parametricOpt: 'P' or 'NP'
% Output:
%     1. Parametric
%     granger (P): parametric Granger spectrum containing fields:
%              - grangerspctrm: nChs*nChs*length(0:fs/2)
%              - freq: vector 0:fs/2
%     coh (P): coherence of parametric computation of the spectral transfer function
%     2. Nonparametric
%     granger (NP): nonparametric Granger spectrum
%     coh (NP): coherence of non-parametric computation of the cross-spectral density matrix

mIp = inputParser;
mIp.addRequired("trialsECOG_AC", @iscell);
mIp.addRequired("trialsECOG_PFC", @iscell);
mIp.addRequired("windowData", @(x) validateattributes(x, {'numeric'}, {'numel', 2, 'increasing'}));
mIp.addRequired("fs", @(x) validateattributes(x, {'numeric'}, {'positive', 'scalar'}));
mIp.addOptional("chsAC", 1:size(trialsECOG_AC{1}, 1), @(x) validateattributes(x, {'numeric'}, {'nrows', 1, 'positive', 'integer', '<=', size(trialsECOG_AC{1}, 1)}));
mIp.addOptional("chsPFC", 1:size(trialsECOG_PFC{1}, 1), @(x) validateattributes(x, {'numeric'}, {'nrows', 1, 'positive', 'integer', '<=', size(trialsECOG_PFC{1}, 1)}));
mIp.addParameter("parametricOpt", "P", @(x) any(validatestring(x, {'P', 'NP'})));
mIp.parse(trialsECOG_AC, trialsECOG_PFC, windowData, fs, varargin{:});

chsAC = mIp.Results.chsAC;
chsPFC = mIp.Results.chsPFC;
parametricOpt = mIp.Results.parametricOpt;

ft_setPath2Top;

%% Prepare data
data.trial = cellfun(@(x, y) [x; y], trialsECOG_AC, trialsECOG_PFC, "UniformOutput", false)';
data.time = repmat({linspace(windowData(1), windowData(2), size(trialsECOG_AC{1}, 2)) / 1000}, [1, length(data.trial)]); % normalize
data.fsample = fs;
data.label = mat2cell(char([rowFcn(@(x) strcat('AC-', strrep(x, ' ', '0')), string(num2str((1:size(trialsECOG_AC{1}, 1))'))); ...
                            rowFcn(@(x) strcat('PFC-', strrep(x, ' ', '0')), string(num2str((1:size(trialsECOG_PFC{1}, 1))')))]), ...
                      ones(size(data.trial{1}, 1), 1));
labelIdx = [chsAC, chsPFC + size(trialsECOG_AC{1}, 1)];

if strcmpi(parametricOpt, "P")
    % Multivariate autoregressive model
    cfg         = [];
    % cfg.order   = 5; % lag, default=10
    cfg.method  = 'bsmart';
    cfg.channel = data.label(labelIdx);
    mdata       = ft_mvaranalysis(cfg, data);
    
    % Parametric computation of the spectral transfer function
    cfg         = [];
    cfg.method  = 'mvar';
    cfg.channel = data.label(labelIdx);
    mfreq       = ft_freqanalysis(cfg, mdata);
    
    % Parametric computation of Granger causality
    cfg         = [];
    cfg.method  = 'granger';
    cfg.channel = data.label(labelIdx);
    granger     = ft_connectivityanalysis(cfg, mfreq);

    if nargout == 2
        % Parametric computation of coherence
        cfg         = [];
        cfg.method  = 'coh';
        cfg.channel = data.label(labelIdx);
        coh         = ft_connectivityanalysis(cfg, mfreq);
    end
else
    % Nonparametric computation of the cross-spectral density matrix using fft
    cfg           = [];
    cfg.method    = 'mtmfft';
    cfg.taper     = 'dpss';
    cfg.tapsmofrq = 2;
    cfg.output    = 'fourier';
    cfg.channel   = data.label(labelIdx);
    freq          = ft_freqanalysis(cfg, data);

    % Nonparametric computation of the cross-spectral density matrix using wavelet
%     fcn = ['cwtMultiAll', num2str(size(trialsECOG_AC{1}, 2)), 'x', num2str(length(data.label)), '_mex'];
%     if ~isempty(which(fcn))
%         fcn = eval(['@', fcn]);
%     else
%         fcn = @cwtMultiAll;
%     end
%     temp = cellfun(@(x) x', data.trial, "UniformOutput", false)';
%     [cwtres, f, ~] = cellfun(@(x) fcn(x, fs), temp, "UniformOutput", false);
%     cwtres = cellfun(@gather, cwtres, "UniformOutput", false);
%     
%     temp = arrayfun(@(x) cellfun(@(y) y(:, :, x), cwtres, "UniformOutput", false), (1:length(data.label))', "UniformOutput", false);
%     cwtres = cellfun(@(x) cell2mat(cellfun(@(y) mean(y, 1), changeCellRowNum(x), "UniformOutput", false)), temp, "UniformOutput", false);
%     cwtres = cell2mat(cellfun(@(x) permute(flip(x, 1), [3, 1, 2]), cwtres, "UniformOutput", false));
% 
%     freq.label     = data.label;
%     freq.freq      = flip(gather(f{1})');
%     freq.time      = data.time{1};
%     freq.powspctrm = cwtres;
%     freq.dimord    = 'chan_freq_time';
    
    % fourier
%     cfg = [];
%     cfg.method     = 'wavelet';
%     cfg.output     = 'fourier';
%     cfg.taper      = 'hanning';
%     cfg.toi        = 'all';
%     cfg.foilim     = [0, fs / 2];
%     freq           = ft_freqanalysis(cfg, data);
%     freq.dimord    = 'rpt_chan_freq_time';
%     freq.fourierspctrm(isnan(freq.fourierspctrm)) = 0 + 1i * 0;

    % Nonparametric computation of Granger causality
    cfg = [];
    cfg.method    = 'granger';
    cfg.channel   = data.label(labelIdx);
    granger       = ft_connectivityanalysis(cfg, freq);

    if nargout == 2
        % Nonparametric computation of coherence
        cfg           = [];
        cfg.method    = 'coh';
        cfg.channel   = data.label(labelIdx);
        coh           = ft_connectivityanalysis(cfg, freq);
    end
end

return;
end