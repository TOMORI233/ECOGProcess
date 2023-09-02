% close all force;
clc; clear
FIGPATH = "D:\spr\Anesthesia";
BLOCKPATH = "D:\ECOG\xiaoxiao\xx20230614\Block-4";
colors = flip(["#FF0000", "#0000FF", "#000000", "#AAAAAA"]);
params.posIndex = 1; % 1-AC, 2-PFC
processFcn = "@PassiveProcess_clickTrainContinuous;";
% processFcn = "@PassiveProcess_Noise;";
params.processFcn = eval(processFcn);
window = [-1000, 1000];
[trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH, params);
trialAll(1) = [];
trialsECOG = selectEcog(ECOGDataset, trialAll, "trial onset", window);
idx = excludeTrials(trialsECOG, 0.1, 0.1);
trialsECOGCopy = trialsECOG;
trialsECOG(idx) = [];
trialAll(idx) = [];
trialsECOG = ECOGFilter(trialsECOG, 1, 200, ECOGDataset.fs);
trialAll(1) = [];
devType = unique([trialAll.devOrdr]);
temp = strsplit(BLOCKPATH, "\");
Date = temp(end-1);
blockNum = temp(end);
%% check click train onset
if contains(string(processFcn), "clickTrain")
    try
        for dIndex = 1 : 4
            tIndex = [trialAll.devOrdr] == devType(dIndex);
            chData(dIndex).chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(trialsECOG(tIndex)), "UniformOutput", false));
            chData(dIndex).color = colors(dIndex);
        end
    end
    Fig = plotRawWaveMulti_SPR(chData, [-300, 500]);
    scaleAxes(Fig, "y", [-50, 50]);
    %     scaleAxes(Fig, "x", [-300, 1000]);
        deleteLine(Fig, "Color", [0,0 255]/255);
end
%% check noise onset
clear chData
segN = 1;
if contains(processFcn, "Noise")
    loopN = fix(length(trialAll) / segN);
    n=0;
    p=0;
    try
        for dIndex = 1 : segN
            n=n+1;
            trials = trialsECOG((dIndex - 1) * loopN + 1 : dIndex * loopN);
            chData(n).chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(trials), "UniformOutput", false));
            chData(n).color = colors(n);
            chData(n).width = 1.5;
            if mod(n, 4) == 0
                p = p+1;
                Fig(p) = plotRawWaveMulti_SPR(chData, window);
                scaleAxes(Fig(p), "y", [-30, 30]);
                scaleAxes(Fig(p), "x", [-300, 500]);
                n=0;
            end
        end
    end
    %     Fig = plotRawWaveMulti_SPR(chData, window);
    %     deleteLine(Fig, "Color", [0,0,255]/255);
    %     deleteLine(Fig, "Color", [255,0,0]/255);
    for pIndex = 1 : p
        mkdir(fullfile(FIGPATH, Date, blockNum));
        mPrint(Fig(pIndex), fullfile(FIGPATH, Date, blockNum, strcat("Seg", num2str(pIndex), ".jpg")), "-djpeg", "-r300");
    end

end
