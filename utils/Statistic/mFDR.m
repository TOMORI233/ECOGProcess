function stat = mFDR(data, cfg)
% Description: FDR correction for 2 or more than 2 groups of data
% NOTICE: If you run into error messages like "too many args input for nearest",
%         then solution to function name duplication is to add fieldtrip path to
%         the beginning of pathdef.m (or via path settings).
% Input:
%     data: n*1 struct with fields:
%           - time: [1, nSample]
%           - label: channel label, [nCh, 1] char cell array
%           - trial: trial data, [nTrial, nCh, nSample]
%           - trialinfo: trial type label (>=1 and begins with 1), [nTrial, 1]
%     cfg: configurations (you can alter settings marked * for better performance)
%          - method: method to calculate significance probability (default: 'analytic')
%        * - statistic: 'indepsamplesT'(for 2 groups), 'indepsamplesF'(for more than 2 groups)
%          - correctm: 'no', 'max', 'cluster', 'bonferoni', 'holms', or 'fdr'(default).
%        * - alpha: alpha level of FDR (default = 0.05)
%          - latency: time interval over which the experimental conditions must be compared (in seconds)
%          - channel: cell-array with selected channel labels (default = 'all')
%          - design: design matrix of trialinfo (DO NOT SPECIFY IN YOUR cfg)
%          - ivar: number or list with indices indicating the independent variable(s)
%                  (default = 1, DO NOT SPECIFY IN YOUR cfg)
% Output:
%     stat: result of fieldtrip
%           - mask: significant sample position, [nCh, nSample] logical
%           - stat: the effect at the sample level (t-value or f-value by cfg.statistic), [nCh, nSample]

ft_setPath2Top
narginchk(1, 2);

if nargin < 2
    cfg = [];
end

cfg_default.method   = 'analytic';
cfg_default.correctm = 'fdr';                       % FDR correction
cfg_default.alpha    = 0.05;                        % alpha level of the permutation test

if numel(data) == 2
    cfg_default.statistic   = 'indepsamplesT';      % statistic method to evaluate the effect at the sample level
    cfg_default.tail        = 0;                    % -1, 1 or 0 (default = 0); one-sided or two-sided test
    cfg_default.clustertail = 0;                    % identical to tail option
else
    cfg_default.statistic   = 'indepsamplesF';      % statistic method to evaluate the effect at the sample level
    cfg_default.tail        = 1;                    % -1, 1 or 0 (default = 0); one-sided or two-sided test
    cfg_default.clustertail = 1;                    % identical to tail option
end

cfg = getOrFull(cfg, cfg_default);

cfg.channel = data(1).label;                % cell-array with selected channel labels
cfg.design  = vertcat(data.trialinfo)';     % design matrix
cfg.ivar    = 1;                            % number or list with indices indicating the independent variable(s)

temp = mat2cell(reshape(data, [numel(data), 1]), ones(numel(data), 1));
stat = ft_timelockstatistics(cfg, temp{:});
end