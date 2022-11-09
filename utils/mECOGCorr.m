function Fig = mECOGCorr(trialsECOG, Window, varargin)
% Description: Calculate correlation matrix trial-by-trial and dicide
%              the most similar channel to a reference channel
% Input:
%     trialsECOG: n*1 cell array of trial data (64*m matrix)
%     Window: 1*2 vector of time window of trial data, in ms
%     selWin: 1*2 selWin window used to select data to be processed
% Optional:
%     method:
%         1. pearson; 2. kendall; 3. spearman
%     refCh:
%         reference channel that you think is the most ideal one
%     ch: 
%         channel index
%     selNum:
%         number of selected channels to be averaged
%     
%
% Output:
%     rhoMean: mean of correlation matrix
%     chSort: sorted by the correlate to the reference channel
%     rhoSort: sorted version of rhoMean corresponding to chSort
%     trialsMeanECOG: the average of selected channels
% Example:
%     stimStrs = ["24_60_0o1", "24_60_0o2", "24_60_0o4", "24_60_0o7", "24_60_1", "60_24_0o1", "60_24_0o2", "60_24_0o4", "60_24_0o7", "60_24_1"];
%     params.stimDlg = string(cellfun(@(x, y) strrep(strcat(string(x), ". ", y), "_", "-"), num2cell(1:length(stimStrs)), stimStrs, "uni", false));
%     params.trialAll = trialAll; % contain field "devOrdr"
%     params.ICI2 = ICI2;
%     FigRho = mECOGCorr(trialsECOG_Merge, Window, [0 400], "method", "pearson", "refCh", 2, "selNum", 10, "params", params);


%% Validate input
mInputParser = inputParser;
mInputParser.addRequired("trialsECOG");
mInputParser.addRequired("Window", @(x) validateattributes(x, {'numeric'}, {'2d', 'increasing'}));
mInputParser.addOptional("selWin", Window, @(x) validateattributes(x, {'numeric'}, {'2d', 'increasing'}));
mInputParser.addOptional("Fig", []);
mInputParser.addParameter("method", "pearson", @(x) any(validatestring(x, {'pearson','kendall','spearman'})));
mInputParser.addParameter("refCh", 0, @(x) validateattributes(x, {'numeric'}, {'numel', 1}));
mInputParser.addParameter("ch", 1 : size(trialsECOG{1}, 2), @(x) validateattributes(x, {'numeric'}));
mInputParser.addParameter("selNum", 0.7, @(x) validateattributes(x, {'numeric'}, {'numel', 1}));
mInputParser.addParameter("params", []);

mInputParser.parse(trialsECOG, Window, varargin{:});

Fig = mInputParser.Results.Fig; 
selWin = mInputParser.Results.selWin;
METHOD = mInputParser.Results.method;
REFCH = mInputParser.Results.refCh;
CH = mInputParser.Results.ch;
selNum = mInputParser.Results.selNum;
params = mInputParser.Results.params;

tRange = linspace(Window(1), Window(2), size(trialsECOG{1}, 2));
if ~isempty(Window) && ~isempty(selWin)
    [~, tTarget] = findWithinInterval(tRange, selWin);
else
    tTarget = 1 : size(trialsECOG{1}, 2);
end


%% select devType
devSel = 0;
try
    trialAll = params.trialAll;
    if isfield(trialAll, "devOrdr")
        trialType = [trialAll.devOrdr];
    end
    if isfield(params, "stimDlg")
        stimStr = strjoin(params.stimDlg, ", ");
    else
        stimStr = strjoin(string(trialType), ", ");
    end
catch
    trialType = zeros(length(trialsECOG), 1);
    stimStr = "trial info is not supplied, only 0(all trials) works";
    disp("trial info is not supplied, changed to display all input trials");
end

if ~isempty(Fig)
    UserData = get(Fig, "UserData");
    devSel = getOr(UserData, "devSel", 0);
else
    Fig = figure;
    maximizeFig(Fig);
    UserData = get(Fig, "UserData");
    UserData.trialsECOG = trialsECOG;
    UserData.Window = Window;
    UserData.selWin = selWin;
    UserData.devSel = devSel;
    UserData.REFCH = REFCH;
    UserData.selNum = selNum;
    UserData.params = params;
    UserData.trialType = trialType;
    UserData.stimStr = stimStr;
    UserData.XLim = Window;
    UserData.YLim = [-40 40];
    Fig.UserData = UserData;
end


if ~isequal(devSel, 0)
    tIndex = find(ismember(trialType, devSel))';
    if any(~ismember(devSel, trialType))
        tIndex = 1 : length(trialsECOG);
        errorIdx = devSel(~ismember(devSel, trialType));
        message(strcat("current trials do not contain type", strjoin(string(errorIdx), ", "), "use 0 (all)"));
    end
else
    tIndex = 1 : length(trialsECOG);
end

trialsECOGSel = trialsECOG(tIndex);

temp = cellfun(@(x) x(:, tTarget), trialsECOGSel, "UniformOutput", false);




%% correlation
[rho, ~] = cellfun(@(x) corr(x', "type", METHOD), temp, "UniformOutput", false);

rhoMean = cell2mat(cellfun(@mean, changeCellRowNum(rho), "UniformOutput", false));

% refCh method
if isempty(REFCH) || REFCH < 1
    selectMethod = "auto";
else
    selectMethod = "refCh";
end

% selNum method
if selNum == 0
    numMethod = "threshold";
else
    numMethod = "selNum";
end

% sort
if strcmpi(selectMethod, "auto")
    [~, idx] = max(mean(rhoMean));
    REFCH = CH(idx);
end
[rhoSort, idx] = sortrows(rhoMean, REFCH, "descend");
rhoSort = rhoSort(:, idx);
chSort = CH(idx)';


if strcmpi(numMethod, "threshold")
    selNum = sum(rhoSort(1, :) > selNum);
end
temp = cellfun(@(x) x(idx(1 : selNum), :), trialsECOGSel, "UniformOutput", false);
trialsMeanECOG = cellfun(@mean, temp, "UniformOutput", false);
Fig = plotRho(rhoSort, chSort, Fig);

%% set userdata
UserData = get(Fig, "UserData");
UserData.trialsMeanECOG = trialsMeanECOG;
UserData.chSort = chSort;
UserData.rhoMean = rhoMean;
UserData.rhoSort = rhoSort;
UserData.method = METHOD;
UserData.trialsECOGSel = trialsECOGSel;
Fig.UserData = UserData;

end