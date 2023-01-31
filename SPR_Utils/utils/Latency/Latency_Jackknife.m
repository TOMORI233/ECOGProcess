function [latency_mean, latency_se, latency_raw, smthWave] = Latency_Jackknife(trialsECOG, window, chNP, varargin)
mIp = inputParser;
mIp.addRequired("trialsECOG");
% mIp.addRequired("trialsECOG_S1");
mIp.addRequired("window", @(x) validateattributes(x, 'numeric',  {'2d', 'increasing'}));
mIp.addRequired("chNP", @(x) validateattributes(x, 'numeric', {'vector'}));
mIp.addOptional("testWin", window, @(x) validateattributes(x, 'numeric',  {'2d', 'increasing'}));
mIp.addOptional("smthBin", 1, @(x) validateattributes(x, 'numeric',  {'numel', 1, 'positive'}));
mIp.addOptional("fs", size(trialsECOG{1,1},2)/diff(window)*1000, @(x) validateattributes(x, 'numeric',  {'numel', 1, 'positive'}));
mIp.addParameter("Method", "AVL", @(x) any(validatestring(x, {'AVL', 'FAL'})));
mIp.addParameter("fraction", 0.5, @(x) validateattributes(x, 'numeric',  {'numel', 1, 'positive'}));
mIp.addParameter("thrFrac", 0.3, @(x) validateattributes(x, 'numeric',  {'numel', 1, 'positive'}));
mIp.parse(trialsECOG, window, chNP, varargin{:});

testWin = mIp.Results.testWin;
chNP = mIp.Results.chNP;
smthBin = mIp.Results.smthBin;
fs = mIp.Results.fs;
Method = mIp.Results.Method;
fraction = mIp.Results.fraction;
thrFrac = mIp.Results.thrFrac;

%% smooth and get time
t = linspace(window(1), window(2), size(trialsECOG{1, 1}, 2));
tIndex = t >= testWin(1) & t <= testWin(2);
tTest = t(tIndex)';
trialsECOG = changeCellRowNum(trialsECOG);
% trialsECOG_S1 = changeCellRowNum(trialsECOG_S1);
smthSample = ceil(smthBin * fs / 1000);
% Attention: smoothdata fcn conduct smooth by column, so transpose
%            ( 64 * n to n * 64)
smthWave = cellfun(@(x) smoothdata(x(:, tIndex)','gaussian',smthSample)', trialsECOG, "UniformOutput", false);
% smthWave_S1 = cellfun(@(x) smoothdata(x(:, tIndex)','gaussian',smthSample)', trialsECOG_S1, "UniformOutput", false);

% S1Thr = cellfun(@(x) 0.2*max(abs(x), [], 2), smthWave_S1, "UniformOutput", false);
% IsLargerThanS1Thr = cellfun(@(x,y) any(abs(x) > y, 2), smthWave, S1Thr, "UniformOutput", false);

% decide
%% compute latency according to different methods
if strcmpi(Method, "FAL")
    [latency_mean, latency_se, latency_raw] = cellfun(@(x,y) FAL_Jackknife(x, tTest, y, fraction, thrFrac), smthWave, num2cell(chNP), "UniformOutput", false);
elseif strcmpi(Method, "AVL")
    [latency_mean, latency_se, latency_raw] = cellfun(@(x,y) AVL_Jackknife(x, tTest, y), smthWave, num2cell(chNP), "UniformOutput", false);
end

% for ch = 1 : length(IsLargerThanS1Thr)
%     latency_raw{ch}(~IsLargerThanS1Thr{ch}) = 200;
%     latency_mean{ch} = mean(latency_raw{ch});
%     latency_se{ch} = std(latency_raw{ch})/sqrt(length(latency_raw{ch}));
% end
latency_mean = cell2mat(latency_mean);
latency_se = cell2mat(latency_se);

end