function [rhoMean, chSort, rhoSort] = mECOGCorr(trialsECOG, range, target, varargin)
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


%% Validate input
mInputParser = inputParser;
mInputParser.addRequired("trialsECOG");
mInputParser.addOptional("range", @(x) validateattributes(x, {'numeric'}, {'2d', 'increasing'}));
mInputParser.addOptional("n", @(x) validateattributes(x, {'numeric'}, {'2d', 'increasing'}));
mInputParser.parse(trialsECOG, range, target);


if ~isempty(range) && ~isempty(target)
    tRange = linspace(range(1), range(2), size(trialsECOG{1}, 2));
    [~, tTarget] = findWithinInterval(tRange, target);
else
    tTarget = 1 : size(trialsECOG{1}, 2);
end

temp = cellfun(@(x) x(:, tTarget), trialsECOG, "UniformOutput", false);

%% config parameters
METHOD = "pearson";
REFCH = [];
CH = 1 : size(trialsECOG{1}, 1);

        V = varargin;

    for n = 1:2:size(V,2)
        switch upper(V{n})
            case 'METHOD'
                METHOD = V{n+1};
            case 'REFCH'
                REFCH = V{n+1};
            case 'CH'
                CH = V{n+1};
            otherwise
                error('Error.')
        end
    end


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