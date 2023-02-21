function Granger_ProcessFcn(params)
close all;
ft_setPath2Top;
parseStruct(params);

dataAC  = load(DATAPATH{1});
dataPFC = load(DATAPATH{2});

%% Load
if protocolType == 1 % PE
    windowData = dataAC.windowPE;
    dRatioAll = dataAC.dRatioAll;
    dRatio = dataAC.dRatio;
    if trialType == 1
        dRatio0 = dRatio(2:end);
        titleStr = 'PE dev - Dev onset';
    else
        dRatio0 = dRatio(1);
        titleStr = 'PE std - Dev onset';
    end
    idx = ismember(dRatioAll, dRatio0);
    trialsECOG_AC  = dataAC.trialsECOG(idx);
    trialsECOG_PFC = dataPFC.trialsECOG(idx);
elseif protocolType == 2 % DM
    windowData = dataAC.windowDM;
    if trialType == 1
        trialsECOG_AC  = dataAC.trialsECOG_correct;
        trialsECOG_PFC = dataPFC.trialsECOG_correct;
        dRatio0 = [1.02, 1.04, 1.06, 1.08];
        titleStr = 'DM correct - Dev onset';
    else
        trialsECOG_AC  = dataAC.trialsECOG_wrong;
        trialsECOG_PFC = dataPFC.trialsECOG_wrong;
        dRatio0 = [1.02, 1.04, 1.06, 1.08];
        titleStr = 'DM wrong - Dev onset';
    end
else % Prediction
    windowData = dataAC.windowP;
    dRatio0 = 1;
    trialsECOG_AC  = dataAC.trialsECOG;
    trialsECOG_PFC = dataPFC.trialsECOG;
    titleStr = 'Prediction - Trial onset';
end

fs = dataAC.fs;
params.fs = fs;
params.SAVEPATH = MONKEYPATH;
params.windowData = windowGranger;
params.labelStr = [titleStr, ' [', num2str(windowGranger(1)), ',', num2str(windowGranger(2)), ']ms (dRatio=', char(join(string(num2str(dRatio0')), ',')), ')'];
params.badCHsAC = dataAC.badCHs;
params.badCHsPFC = dataPFC.badCHs;

tIdx = fix((windowGranger(1) - windowData(1)) / 1000 * fs) + 1:fix((windowGranger(2) - windowData(1)) / 1000 * fs);
trialsECOG_AC  = cellfun(@(x) x(:, tIdx), trialsECOG_AC, "UniformOutput", false);
trialsECOG_PFC = cellfun(@(x) x(:, tIdx), trialsECOG_PFC, "UniformOutput", false);

Granger_ProcessFcnImpl(trialsECOG_AC, trialsECOG_PFC, params);
