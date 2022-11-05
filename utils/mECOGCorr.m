function [rhoMean, chSort, rhoSort] = mECOGCorr(trialsECOG, varargin)
% Description: Calculate correlation matrix trial-by-trial and dicide
%              the most similar channel to a reference channel
% Input:
%     trialsECOG: n*1 cell array of trial data (64*m matrix)
%     range: 1*2 vector of time window of trial data, in ms
%     target: 1*2 target window used to select data to be processed
% Optional:
%     method:
%         1. pearson; 2. kendall; 3. spearman
%     refCh:
%         reference channel that you think is the most ideal one
%     ch: channel index
%
% Output:
%     rhoMean: mean of correlation matrix
%     chSort: sorted by the correlate to the reference channel
%     rhoSort: sorted version of rhoMean corresponding to chSort
% Example:
%     [rhoMean, chSort, rhoSort] = mECOGCorr(trialsECOGFilterd, Window, [0 1000], "method", "pearson", "refCh", 4);
%     [rhoMean, chSort, rhoSort] = mECOGCorr(trialsECOGFilterd, [], [], "method", "pearson", "refCh", 4);


%% Validate input
mInputParser = inputParser;
mInputParser.addRequired("trialsECOG");
mInputParser.addOptional("range", [], @(x) validateattributes(x, {'numeric'}, {'2d', 'increasing'}));
mInputParser.addOptional("target", [], @(x) validateattributes(x, {'numeric'}, {'2d', 'increasing'}));
mInputParser.addParameter("method", "pearson", @(x) any(validatestring(x, {'pearson','kendall','spearman'})));
mInputParser.addParameter("refCh", [], @(x) validateattributes(x, {'numeric'}, {'numel', 1}));
mInputParser.addParameter("ch", 1 : size(trialsECOG{1}, 2), @(x) validateattributes(x, {'numeric'}));
mInputParser.parse(trialsECOG, varargin{:});



range = mInputParser.Results.range;
target = mInputParser.Results.target;
METHOD = mInputParser.Results.method;
REFCH = mInputParser.Results.refCh;
CH = mInputParser.Results.ch;


if ~isempty(range) && ~isempty(target)
    tRange = linspace(range(1), range(2), size(trialsECOG{1}, 2));
    [~, tTarget] = findWithinInterval(tRange, target);
else
    tTarget = 1 : size(trialsECOG{1}, 2);
end

temp = cellfun(@(x) x(:, tTarget), trialsECOG, "UniformOutput", false);


%% correlation

[rho, ~] = cellfun(@(x) corr(x', "type", METHOD), temp, "UniformOutput", false);

rhoMean = cell2mat(cellfun(@mean, changeCellRowNum(rho), "UniformOutput", false));
if ~isempty(REFCH)
    [rhoSort, idx] = sortrows(rhoMean, REFCH, "descend");
    chSort = CH(idx)';
else
    rhoSort = rhoMean;
    idx = [];
    chSort = [];
end







end