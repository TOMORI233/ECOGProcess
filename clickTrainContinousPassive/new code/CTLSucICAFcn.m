function [FigWave, FigFFT, FigTFA, filterRes] = CTLSucICAFcn(trialAll, ECOGDataset, opts)

optsNames = fieldnames(opts);

for index = 1:size(optsNames, 1)
    eval([optsNames{index}, '=opts.', optsNames{index}, ';']);
end

run("CTLconfig.m");

colors = ["r", "b", "k", "r", "b", "k"];
fs = ECOGDataset.fs;
%% delete first sound
trialAll(1) = [];

devType = unique([trialAll.devOrdr]);
devTemp = {trialAll.devOnset}';
ordTemp = {trialAll.ordrSeq}';
temp = cellfun(@(x, y) x + S1Duration(y), devTemp, ordTemp, "UniformOutput", false);
trialAll = addFieldToStruct(trialAll, temp, "devOnset");


ECOGFDZ = ECOGDataset; % filtered, dowmsampled, zoomed
FFTWin = Window;

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
    [ff, PMean, ~]  = trialsECOGFFT(trialsECOG{dIndex}, fs, tIdx);

    % PLOT FFT
    FigFFT(dIndex) = plotRawWave(PMean, [], [ff(1), ff(end)], [stimStr{dIndex}, 'FFT'], [8, 8]);
    setLine(FigFFT(dIndex), "Color", colors(dIndex), "LineStyle", "-");
    lines(1).X = cursor(dIndex); lines(1).color = "r";
    addLines2Axes(FigFFT(dIndex), lines);

    % PLOT RAW WAVE
    chMeanSuc(1).chMean = chMean{dIndex}; chMeanSuc(1).color = chMean{dIndex}; 
    FigWave(dIndex) = plotRawWave(chMean{dIndex}, [], Window, stimStr{dIndex}, [8, 8]);
    setLine(FigWave(dIndex), "Color", colors(dIndex), "LineStyle", "-");

    % PLOT TFA
    FigTFA(dIndex) = plotTFA(chMean{dIndex}, fs, fs, Window, stimStr{dIndex}, [8, 8]);
end



% save result data
filterRes = struct('chMean', chMean, 'chStd', chStd, 'trials', trials, 't', t, 'stimStr', stimStr, 'S1Duration', num2cell(S1Duration));


end