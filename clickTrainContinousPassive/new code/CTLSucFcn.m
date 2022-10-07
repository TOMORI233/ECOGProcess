function [FigWave, FigFFT, filterRes] = CTLSucFcn(trialAll, ECOGDataset, opts)

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
temp = cellfun(@(x, y) x + S1Duration(y)/1000, devTemp, ordTemp, "UniformOutput", false);
trialAll = addFieldToStruct(trialAll, temp, "devOnset");


ECOGFDZ = mFTHP(ECOGDataset, 0.1, 400);% filtered, dowmsampled, zoomed
FFTWin = Window;

for dIndex = 1:length(devType)
    tIndex = [trialAll.devOrdr] == devType(dIndex);
    trials{dIndex} = trialAll(tIndex);
    FDZData{dIndex} = ECOGFDZ.data(tIndex);
    [trialsECOG{dIndex}, chMean{dIndex}, chStd{dIndex}] = selectEcog(ECOGFDZ, trials{dIndex}, segOption(s1OnsetOrS2Onset), Window);
    t{dIndex} = linspace(Window(1), Window(2), size(chMean{dIndex}, 2));
    tIdx = find(t{dIndex} > FFTWin(1) & t{dIndex} < FFTWin(2));
    [ff, PMean, ~]  = trialsECOGFFT(trialsECOG{dIndex}, fs, tIdx);

    % PLOT FFT
    FigFFT(dIndex) = plotRawWave(PMean, [], [ff(1), ff(end)], [stimStr{dIndex}, 'FFT'], [8, 8]);
    setLine(FigFFT(dIndex), "Color", colors(dIndex), "LineStyle", "-");
    lines(1).X = cursor(dIndex); lines(1).color = "r";
    addLines2Axes(FigFFT(dIndex), lines);
    drawnow;

    % PLOT RAW WAVE
    chMeanSuc(1).chMean = chMean{dIndex}; chMeanSuc(1).color = chMean{dIndex}; 
    FigWave(dIndex) = plotRawWave(chMean{dIndex}, [], Window, stimStr{dIndex}, [8, 8]);
    setLine(FigWave(dIndex), "Color", colors(dIndex), "LineStyle", "-");
    drawnow;
end

% chMeanSuc1(1).chMean = chMean{1}; chMeanSuc1(1).color = "r";
% chMeanSuc1(2).chMean = chMean{2}; chMeanSuc1(2).color = "b";
% chMeanSuc1(3).chMean = chMean{3}; chMeanSuc1(3).color = "k";
% FigWave(1) = plotRawWaveMulti(chMeanSuc1, Window, titleStr(1), [8, 8]);
% drawnow;
% chMeanSuc2(1).chMean = chMean{1}; chMeanSuc2(1).color = "r";
% chMeanSuc2(2).chMean = chMean{2}; chMeanSuc2(2).color = "b";
% chMeanSuc2(3).chMean = chMean{3}; chMeanSuc2(3).color = "k";
% FigWave(2) = plotRawWaveMulti(chMeanSuc2, Window, titleStr(2), [8, 8]);
% drawnow;


% save result data
filterRes = struct('chMean', chMean, 'chStd', chStd, 'trials', trials, 't', t, 'stimStr', stimStr, 'S1Duration', num2cell(S1Duration), 'FDZData', FDZData);


end