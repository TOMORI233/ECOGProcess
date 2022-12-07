%% Push-Example
clear; close all; clc;
% MATPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\XX\7-10Freq Active\xx20220822\xx20220822_PFC';
MATPATH = 'D:\Education\Lab\Projects\ECOG\MAT Data\XX\7-10Freq Active\xx20220822\xx20220822_AC';
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
[trialAll, ECOGDataset] = ECOGPreprocess(MATPATH, params);
fs = ECOGDataset.fs;

%% ICA
window  = [-2000, 1000];

try
    load(strcat(fileparts(MATPATH), "\", AREANAME, "_ICA"));
catch
    comp0 = mICA(ECOGDataset, trialAll([trialAll.correct]), window, "dev onset", fs);
    t1 = [-2000, -1500, -1000, -500, 0];
    t2 = t1 + 200;
%     comp = realignIC(comp0, window, t1, t2);
    comp = realignIC(comp0, window);
    ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
    ICStd = cell2mat(cellfun(@(x) std(x, [], 1), changeCellRowNum(comp.trial), "UniformOutput", false));
    Fig1(1) = plotRawWave(ICMean, ICStd, window, "ICA");
    Fig1(2) = plotTFA(ICMean, fs, [], window, "ICA");
    Fig1(3) = plotTopo(comp, [8, 8], [8, 8]);
    scaleAxes(Fig1(1), "y", [-2, 2]);
    scaleAxes(Fig1(2), "c", [0, 0.2]);
    
    comp = reverseIC(comp, input("Input ICs to reverse: "));
    ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
    plotRawWave(ICMean, [], window, "ICA");
    plotTopo(comp, [8, 8], [8, 8]);
    save(strcat(fileparts(MATPATH), "\", AREANAME, "_ICA"), "comp");
end

%% PE
window = [-2000, 2000]; % ms
[dRatioAll, dRatio] = computeDevRatio(trialAll);
colors = generateColorGrad(length(dRatio), 'rgb');

for dIndex = 2:length(dRatio)
    trials = trialAll([trialAll.correct] == true & dRatioAll == dRatio(dIndex));
    [trialsECOG, chMean, ~] = selectEcog(ECOGDataset, trials, "push onset", window);

    % Raw Data
%     chData(dIndex - 1).chMean = chMean;

    % ICA
    temp = cellfun(@(x) comp.unmixing * x, trialsECOG, "UniformOutput", false);
    chData(dIndex - 1).chMean = cell2mat(cellfun(@mean, changeCellRowNum(temp), "UniformOutput", false));
    
    chData(dIndex - 1).color = colors{dIndex};
    chData(dIndex - 1).legend = num2str(dRatio(dIndex));
end

Fig0 = plotRawWaveMulti(chData, window);
Fig = plotRawWaveMulti(chData, window, "ICA", [3, 3], 1);
scaleAxes([Fig0, Fig], "x", [-1500, 2000]);
scaleAxes([Fig0, Fig], "y", [-1, 1]);

ICNum = 3;
t = (0:length(chData(1).chMean(ICNum, :)) - 1)' / fs * 1000 + window(1);
result = [t, ...
          chData(1).chMean(ICNum, :)', ...
          t, ...
          chData(2).chMean(ICNum, :)', ...
          t, ...
          chData(3).chMean(ICNum, :)', ...
          t, ...
          chData(4).chMean(ICNum, :)'];
FigTopo = plotTopo(comp, [8, 8], [1, 1], ICNum);
print(FigTopo, strcat(fileparts(MATPATH), "\", AREANAME, "_ICA_Push"), "-djpeg", "-r400");