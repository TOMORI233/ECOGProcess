function [latency_mean, latency_se, latency_raw] = Latency_Resample(trialsECOG, window, chNP, varargin)
mIp = inputParser;
mIp.addRequired("trialsECOG");
% mIp.addRequired("trialsECOG_S1");
mIp.addRequired("window", @(x) validateattributes(x, 'numeric',  {'2d', 'increasing'}));
mIp.addRequired("chNP", @(x) validateattributes(x, 'numeric', {'vector'}));
mIp.addOptional("testWin", window, @(x) validateattributes(x, 'numeric',  {'2d', 'increasing'}));
mIp.addOptional("sponWin", window, @(x) validateattributes(x, 'numeric',  {'2d', 'increasing'}));
mIp.addOptional("sigma", 0, @(x) validateattributes(x, 'numeric',  {'numel', 1, 'positive'}));
mIp.addOptional("smthBin", 1, @(x) validateattributes(x, 'numeric',  {'numel', 1, 'positive'}));
mIp.addOptional("fs", size(trialsECOG{1,1},2)/diff(window)*1000, @(x) validateattributes(x, 'numeric',  {'numel', 1, 'positive'}));
mIp.addParameter("Method", "AVL_Single", @(x) any(validatestring(x, {'AVL_Jcakknife', 'FAL_Jcakknife', 'AVL_Single', 'AVL_Boostrap'})));
mIp.addParameter("stdFrac", [], @(x) validateattributes(x, 'numeric',  {'numel', 1, 'positive'}));
mIp.addParameter("fraction", 0.5, @(x) validateattributes(x, 'numeric',  {'numel', 1, 'positive'}));
mIp.addParameter("thrFrac", 0.3, @(x) validateattributes(x, 'numeric',  {'numel', 1, 'positive'}));
mIp.parse(trialsECOG, window, chNP, varargin{:});

testWin = mIp.Results.testWin;
sponWin = mIp.Results.sponWin;
chNP = mIp.Results.chNP;
sigma = mIp.Results.sigma;
smthBin = mIp.Results.smthBin;
fs = mIp.Results.fs;
stdFrac = mIp.Results.stdFrac;
Method = mIp.Results.Method;
fraction = mIp.Results.fraction;
thrFrac = mIp.Results.thrFrac;

%% smooth and get time
t = linspace(window(1), window(2), size(trialsECOG{1, 1}, 2));
trialsECOG = changeCellRowNum(trialsECOG);

%% compute latency according to different methods

if strcmpi(Method, "FAL)Jackknife")
    [latency_mean, latency_se, latency_raw] = cellfun(@(x,y) FAL_Jackknife(x, tTest, y, fraction, thrFrac), smthWave, num2cell(chNP), "UniformOutput", false);
elseif strcmpi(Method, "AVL_Jackknife")
    [latency_mean, latency_se, latency_raw] = cellfun(@(x,y) AVL_Jackknife(x, t, testWin, sponWin, y, stdFrac, sigma, smthBin), trialsECOG, num2cell(chNP), "UniformOutput", false);
elseif strcmpi(Method, "AVL_Boostrap")
    [latency_mean, latency_se, latency_raw] = cellfun(@(x,y) AVL_Boostrap(x, t, testWin, sponWin, y, stdFrac, sigma, smthBin), trialsECOG, num2cell(chNP), "UniformOutput", false);
elseif strcmpi(Method, "AVL_Single")
%     [latency_mean, latency_se, latency_raw] = cellfun(@(x,y) AVL_ByTrials(x, t, testWin, sponWin, y, stdFrac, sigma, smthBin), trialsECOG, num2cell(chNP), "UniformOutput", false);
    [latency_mean, latency_se, latency_raw] = cellfun(@(x,y) AVL_ByTrials2(x, t, testWin, sponWin, y, stdFrac, sigma, smthBin), trialsECOG, num2cell(chNP), "UniformOutput", false);
end

latency_mean = cell2mat(latency_mean);
latency_se = cell2mat(latency_se);

end