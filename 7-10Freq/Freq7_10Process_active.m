clear; clc;
%% Parameter settings
params.posIndex = 2; % 1-AC, 2-PFC
params.choiceWin = [100, 600];
params.processFcn = @ActiveProcess_7_10Freq;

fs = 500; % Hz, for downsampling

%% Processing

MATPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\CC\7-10Freq Active\cc20220520\cc20220520_AC.mat';
ROOTPATH = "D:\Education\Lab\Projects\ECOG\Figures\7-10Freq\";
temp = string(split(MATPATH, '\'));
DateStr = temp(end - 1);
[trialAll, ECOGDataset] = ECOGPreprocess(MATPATH, params);
fs0 = ECOGDataset.fs;

devFreqAll = [trialAll.devFreq];
stdFreqAll = cellfun(@(x) x(1), {trialAll.freqSeq});
dRatioAll = roundn(devFreqAll ./ stdFreqAll, -2);
dRatio = unique(dRatioAll);
dRatio(dRatio == 0) = [];

%% Behavior
FigBehavior = plotBehaviorOnly(trialAll, "r", "7-10 Freq");
drawnow;

%% ICA
% window  = [-2000, 2000];
% comp = mICA(ECOGDataset, trialAll(10:40), window, "dev onset", fs);
% 
% t1 = [-2000, -1500, -1000, -500, 0];
% t2 = t1 + 200;
% comp = realignIC(comp, window, t1, t2);
% ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
% plotRawWave(ICMean, [], window, "ICA", [4, 5]);
% plotTFA(ICMean, fs, [], window, "ICA", [4, 5]);
% plotTopo(comp, [8, 8], [4, 5]);
% 
% comp = reverseIC(comp, input("IC to reverse: "));
% ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
% plotRawWave(ICMean, [], window, "ICA", [4, 5]);
% plotTFA(ICMean, fs, [], window, "ICA", [4, 5]);
% plotTopo(comp, [8, 8], [4, 5]);

%% MMN - PE
window = [-2000, 2000];
colors = generateColorGrad(4, "rgb");

for dIndex = 2:length(dRatio)
    trialsC = trialAll([trialAll.correct] == true & dRatioAll == dRatio(dIndex));
    [resultDEVC, ~, ~] = selectEcog(ECOGDataset, trialsC, "dev onset", window);
    [resultSTDC, ~, ~] = selectEcog(ECOGDataset, trialsC, "last std", window);
    
    chDataC(dIndex - 1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(resultDEVC - resultSTDC), "UniformOutput", false));
    chDataC(dIndex - 1).color = colors{dIndex - 1};
    chDataC(dIndex - 1).legend = ['dRatio=', num2str(dRatio(dIndex))];
end

Fig1 = plotRawWaveMulti(chDataC, window, 'MMN(C)');

scaleAxes(Fig1, "x", [0, 500]);
scaleAxes(Fig1, "y", [-50, 50]);

%% Prediction
[~, chMean, ~, window] = joinSTD(trialAll([trialAll.correct] == true), ECOGDataset);
FigP(1) = plotRawWave(chMean, [], window);
drawnow;
FigP(2) = plotTFA(chMean, fs0, fs, window);
drawnow;

%% Prediction error
window = [-2000, 2000]; % ms

for dIndex = 1:length(dRatio)
    trials = trialAll([trialAll.correct] == true & dRatioAll == dRatio(dIndex));

    if isempty([trials.firstPush])
        continue;
    end

    [~, chMean, chStd] = selectEcog(ECOGDataset, trials, "push onset", window);
    FigPE1(dIndex) = plotRawWave(chMean, chStd, window, ['dRatio=', num2str(dRatio(dIndex)), '(N=', num2str(length(trials)), ')']);
    drawnow;
    FigPE2(dIndex) = plotTFA(chMean, fs0, fs, window, ['dRatio=', num2str(dRatio(dIndex)), '(N=', num2str(length(trials)), ')']);
    drawnow;
end

% Scale
scaleAxes([FigPE1, FigPE2], "x", [-1500, 2000]);
scaleAxes([FigP(1), FigPE1], "y", [-80, 80]);
scaleAxes([FigP(2), FigPE2], "c", [], [0, 15]);

%% Decision making
window = [-2000, 2000];
resultC = [];
resultW = [];

for dIndex = 2:length(dRatio)
    trials = trialAll(dRatioAll == dRatio(dIndex));
    [result, ~, ~] = selectEcog(ECOGDataset, trials, "dev onset", window);
    result = changeCellRowNum(cellfun(@zscore, changeCellRowNum(result), "UniformOutput", false));
    resultC = [resultC; result([trials.correct] == true)];
    resultW = [resultW; result([trials.correct] == false & [trials.interrupt] == false)];
end

chMeanC = cell2mat(cellfun(@mean, changeCellRowNum(resultC), "UniformOutput", false));
chMeanW = cell2mat(cellfun(@mean, changeCellRowNum(resultW), "UniformOutput", false));
FigDM1 = plotRawWave(chMeanC - chMeanW, [], window, ['C', num2str(length(resultC)), 'W', num2str(length(resultW))]);
drawnow;
FigDM2 = plotTFACompare(chMeanC, chMeanW, fs0, fs, window, ['C', num2str(length(resultC)), 'W', num2str(length(resultW))]);
drawnow;

% Scale
scaleAxes([FigDM1, FigDM2], "x", [-1000, 1000]);
scaleAxes(FigDM1, "y");
cRange = scaleAxes(FigDM2, "c", [], [-0.1, 0.1], "max");

%% Motion response
% window = [-3000, 2000];
% [~, chMean, chStd] = selectEcog(ECOGDataset, trialAll([trialAll.correct] == true & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV"), "push onset", window);
% FigTemp(1) = plotRawWave(chMean, chStd, window, "push onset");
% FigTemp(2) = plotTFA(chMean, fs0, fs, window, "push onset");
% scaleAxes(FigTemp, "x", [-1000, 2000]);
% scaleAxes(FigTemp(1), "y", [], [-80, 80]);
% scaleAxes(FigTemp(2), "c", [], [0, 20]);

%% RSA
window = [0, 500];
RSAPATH = strcat(ROOTPATH, DateStr, "\RSA\");
mkdir(RSAPATH);

trials = trialAll(dRatioAll == dRatio(end) & [trialAll.correct]);
[~, chMean, ~] = selectEcog(ECOGDataset, trials, "last std", window);
[t, f, TFR1, coi] = computeTFA(chMean, fs0, fs);
t = t + window(1) / 1000;

trials = trialAll(dRatioAll == dRatio(end) & [trialAll.correct]);
[~, chMean, ~] = selectEcog(ECOGDataset, trials, "dev onset", window);
[~, ~, TFR2, ~] = computeTFA(chMean, fs0, fs);

rho = zeros(size(TFR1, 2), size(TFR1, 2), size(TFR1, 3));
for eIndex = 1:size(TFR1, 3)
    rho(:, :, eIndex) = corr(TFR1(:, :, eIndex), TFR2(:, :, eIndex), "type", "Pearson");
end

Fig = figure;
maximizeFig(Fig);
margins = [0.05, 0.05, 0.1, 0.1];
paddings = [0.01, 0.03, 0.01, 0.01];
for eIndex = 1:size(rho, 3)
    mSubplot(Fig, 8, 8, eIndex, 1, margins, paddings);
    imagesc('XData', t, 'YData', t, 'CData', rho(:, :, eIndex));
    hold on;
    plot([min(t) max(t)], [0, 0], "w--", "LineWidth", 1.5);
    plot([0, 0], [min(t) max(t)], "w--", "LineWidth", 1.5);
    xlim([min(t) max(t)]);
    ylim([min(t) max(t)]);

    if ~mod((eIndex - 1), 8) == 0
        yticklabels('');
    end

    if eIndex < (8 - 1) * 8 + 1
        xticklabels('');
    end

    title(['CH ', num2str(eIndex)]);
end
print(gcf, strcat(RSAPATH, DateStr), "-djpeg", "-r200");

%% Layout
plotLayout([FigP(1), FigPE1, FigDM1], 3);

%% Save
AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);
BPATH = strcat(ROOTPATH, DateStr, "\Behavior\");
PEPATH = strcat(ROOTPATH, DateStr, "\Prediction error\");
PPATH = strcat(ROOTPATH, DateStr, "\Prediction\");
DMPATH = strcat(ROOTPATH, DateStr, "\Decision making\");
mkdir(BPATH);
mkdir(PEPATH);
mkdir(PPATH);
mkdir(DMPATH);

print(FigBehavior, strcat(BPATH, "Behavior_", DateStr), "-djpeg", "-r200");
print(FigP(1), strcat(PPATH, AREANAME, "_Prediction_Raw_", DateStr), "-djpeg", "-r200");
print(FigP(2), strcat(PPATH, AREANAME, "_Prediction_TFA_", DateStr), "-djpeg", "-r200");

print(FigDM1, strcat(DMPATH, AREANAME, "_DM_Raw_", DateStr), "-djpeg", "-r200");
print(FigDM2, strcat(DMPATH, AREANAME, "_DM_TFA_", DateStr), "-djpeg", "-r200");

for dIndex = 1:length(FigPE1)
    print(FigPE1(dIndex), strcat(PEPATH, AREANAME, "_PE_Raw_", num2str(dIndex), "_", DateStr), "-djpeg", "-r200");
    print(FigPE2(dIndex), strcat(PEPATH, AREANAME, "_PE_TFA_", num2str(dIndex), "_", DateStr), "-djpeg", "-r200");
end