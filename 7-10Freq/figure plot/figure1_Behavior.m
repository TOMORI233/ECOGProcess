%% Behavior-Population
clear; close all; clc;
MATPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\XX\7-10Freq Active\xx20220822\xx20220822_PFC';
% MATPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\XX\7-10Freq Active\xx20220822\xx20220822_AC';
% MATPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\CC\7-10Freq Active\cc20220520\cc20220520_PFC';
% MATPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\CC\7-10Freq Active\cc20220520\cc20220520_AC';

%% Parameter settings
[ROOTPATH, fileName] = fileparts(MATPATH);
temp = string(split(fileName, "_"));
AREANAME = temp{2};
temp = string(split(MATPATH, '\'));
DateStr = temp(end - 1);

AREANAMEs = ["AC", "PFC"];
params.posIndex = find(AREANAMEs == AREANAME); % 1-AC, 2-PFC
params.choiceWin = [100, 600];
params.processFcn = @ActiveProcess_7_10Freq;

%% Preprocess
[trialAll, ~] = ECOGPreprocess(MATPATH, params, 1);

%% Behavior
trials = trialAll(~[trialAll.interrupt]);
diffLevel = roundn(cellfun(@(x) x(end) / x(1), {trials.freqSeq}), -2);
diffLevelUnique = unique(diffLevel);
nPush = [];
nTotal = [];

for dIndex = 1:length(diffLevelUnique)
    temp = trials(diffLevel == diffLevelUnique(dIndex) & [trials.interrupt] == false);
    nTotal = [nTotal, length(temp)];
    nPush = [nPush, length([temp.firstPush])];
end

ratio = (nPush ./ nTotal)';
[xData, yData] = prepareCurveData(1:5, ratio);
ft = fittype('erf(c*x-b/(sqrt(2)*a))', 'independent', 'x', 'dependent', 'y');
[fitresult, gof] = fit(xData, yData, ft);
x = linspace(1, 5, 1000)';
a = fitresult.a;
b = fitresult.b;
c = fitresult.c;
y = erf(c*x-b/(sqrt(2)*a));

result = [x, y];

figure;
plot(x, y);