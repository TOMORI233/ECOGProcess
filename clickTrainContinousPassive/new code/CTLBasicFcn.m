function [FigWave, FigFFT, filterRes] = CTLBasicFcn(trialAll, ECOGDataset, opts)

optsNames = fieldnames(opts);

for index = 1:size(optsNames, 1)
    eval([optsNames{index}, '=opts.', optsNames{index}, ';']);
end

run("CTLconfig.m");


if Protocol == "Basic_ICIThr"
    colors = ["#000000", "#FFA500", "#0000FF", "#FF0000"];
elseif Protocol == "Basic_IrregVar"
    colors = ["#000000", "#0000FF", "#FFA500", "#FF0000"];
else
    colors = ["#FF0000", "#FFA500", "#0000FF", "#000000"];
end
fs = ECOGDataset.fs;
%% delete first sound
trialAll(1) = [];

devType = unique([trialAll.devOrdr]);
devTemp = {trialAll.devOnset}';
[~, ordTemp] = ismember([trialAll.ordrSeq]', devType);
temp = cellfun(@(x, y) x + S1Duration(y), devTemp, num2cell(ordTemp), "UniformOutput", false);
trialAll = addFieldToStruct(trialAll, temp, "devOnset");


ECOGFDZ = mFTHP(ECOGDataset, 0.1, 400);% filtered, dowmsampled, zoomed
FFTWin = [-4000 0];

for dIndex = 1:length(devType)
    tIndex = [trialAll.devOrdr] == devType(dIndex);
    trials{dIndex} = trialAll(tIndex);
    
    trialsECOG{dIndex} = selectEcog(ECOGFDZ, trials{dIndex}, segOption(s1OnsetOrS2Onset), Window);
    % exclude trial
    trialsECOG{dIndex} = excludeTrialsChs(trialsECOG{dIndex}, 0.1);
    chMean{dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOG{dIndex}), 'UniformOutput', false));
    chStd{dIndex} = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOG{dIndex}), 'UniformOutput', false));
    t{dIndex} = linspace(Window(1), Window(2), size(chMean{dIndex}, 2));

    tIdx = find(t{dIndex} > FFTWin(1) & t{dIndex} < FFTWin(2));
    [ff, PMean(dIndex).chMean, ~]  = trialsECOGFFT(trialsECOG{dIndex}, fs, tIdx);
    PMean(dIndex).color = colors(dIndex);
    chMeanSuc1(dIndex).color = colors(dIndex);
    chMeanSuc1(dIndex).chMean = chMean{dIndex};
end

% PLOT 
FigFFT = plotRawWaveMulti(PMean, [ff(1), ff(end)], [titleStr, 'FFT'], [8, 8]);
FigWave = plotRawWaveMulti(chMeanSuc1, Window, titleStr, [8, 8]);

% save result data
filterRes = struct('chMean', chMean, 'chStd', chStd, 'trials', trials, 't', t, 'stimStr', stimStr, 'S1Duration', num2cell(S1Duration));


end