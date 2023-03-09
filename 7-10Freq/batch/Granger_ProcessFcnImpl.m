function Granger_ProcessFcnImpl(trialsECOG_AC, trialsECOG_PFC, params)
% Input:
%     trialsECOG_AC/_PFC: nTrial*1 cell, each with a nCh*nSample double matrix
%     params:
%         - monkeyID: 1-CC, 2-XX
%         - fs: sample freq, in Hz, default=500
%         - windowData: data window, in ms, default=[0,500]
%         - nSmooth: smooth with a nSmooth*nSmooth mask (no overlapping), default=2 (nSmooth=1 means no smoothing)
%         - topoSize: [nx, ny], default: [8, 8]
%         - borderPercentage: for scaling granger spectrum, default=0.95
%         - fRange: sum granger spectrum within this freq range, default=[0,250]
%         - SAVEPATH: root save path
%         - labelStr: title and file name

narginchk(2, 3);

if nargin < 3
    params = [];
end

paramsDefault = struct("fs", 500, ...
                       "window", [0, 500], ...
                       "nSmooth", 2, ...
                       "topoSize", [8, 8], ...
                       "borderPercentage", 0.95, ...
                       "fRange", [0, 250], ...
                       "SAVEPATH", [pwd, '\'], ...
                       "labelStr", '');
params = getOrFull(params, paramsDefault);
parseStruct(params);

shiftFromCenter = 0.5; % For diff plot and topo plot

mkdir(SAVEPATH);

%% Parameter settings
channels = 1:size(trialsECOG_AC{1}, 1);
chMap = mat2cell(reshape(channels, topoSize), nSmooth * ones(topoSize(1) / nSmooth, 1), nSmooth * ones(topoSize(1) / nSmooth, 1));
chMap = reshape(chMap, [numel(chMap), 1]);
chMap = cellfun(@(x) reshape(x, [1, numel(x)]), chMap, "UniformOutput", false);
chMapAC = cellfun(@(x) x(~ismember(x, badCHsAC)), chMap, "UniformOutput", false);
chMapPFC = cellfun(@(x) x(~ismember(x, badCHsPFC)), chMap, "UniformOutput", false);

%% Perform Granger
try
    load([SAVEPATH, 'GrangerData_', labelStr, '.mat']);
catch
    trialsECOG_AC  = cellfun(@(x) cell2mat(cellfun(@(y) mean(x(y, :), 1), chMapAC, "UniformOutput", false)), trialsECOG_AC, "UniformOutput", false);
    trialsECOG_PFC = cellfun(@(x) cell2mat(cellfun(@(y) mean(x(y, :), 1), chMapPFC, "UniformOutput", false)), trialsECOG_PFC, "UniformOutput", false);
    chsAC = channels(~cellfun(@isempty, chMapAC));
    chsPFC = channels(~cellfun(@isempty, chMapPFC));
    [granger, grangerNP] = mGranger(trialsECOG_AC, trialsECOG_PFC, windowData, fs, chsAC, chsPFC);
    mSave([SAVEPATH, 'GrangerData_', labelStr, '.mat'], "granger");
end

%% Granger indexation
% sum
grangerIndex = sum(granger.grangerspctrm(:, :, granger.freq >= fRange(1) & granger.freq <= fRange(2)), 3);

% max
% grangerIndex = max(granger.grangerspctrm(:, :, granger.freq >= fRange(1) & granger.freq <= fRange(2)), [], 3);

areaAC = 1:sum(~cellfun(@isempty, chMapAC));
areaPFC = 1:sum(~cellfun(@isempty, chMapPFC));

AC2AC   = grangerIndex(areaAC, areaAC);
AC2PFC  = grangerIndex(areaAC, areaPFC + length(areaAC));
PFC2AC  = grangerIndex(areaPFC + length(areaAC), areaAC);
PFC2PFC = grangerIndex(areaPFC + length(areaAC), areaPFC + length(areaAC));

% insert bad channels with 0
idxAC   = find(cellfun(@isempty, chMapAC));
idxPFC  = find(cellfun(@isempty, chMapPFC));
AC2AC   = insertRows(insertRows(AC2AC, idxAC)', idxAC)';
AC2PFC  = insertRows(insertRows(AC2PFC, idxAC)', idxPFC)';
PFC2AC  = insertRows(insertRows(PFC2AC, idxPFC)', idxAC)';
PFC2PFC = insertRows(insertRows(PFC2PFC, idxPFC)', idxPFC)';

areaAC = channels;
areaPFC = channels;

%% ft plot
if nSmooth > 1
    cfg           = [];
    cfg.parameter = 'grangerspctrm';
    cfg.zlim      = [0 0.1];
    ftcpFig = figure;
    maximizeFig;
    ft_connectivityplot(cfg, granger);
    mPrint(ftcpFig, [SAVEPATH, labelStr, '_ftconnectivityplot.jpg'], "-djpeg", "-r600");
end

%% Hist plot
run("Granger_PlotImpl_Hist.m");

%% Grangerspectrm topo
run("Granger_PlotImpl_Topo.m");

%% Diff plot
run("Granger_PlotImpl_Diff.m");

%% Diff plot topo
run("Granger_PlotImpl_Diff_Topo.m")