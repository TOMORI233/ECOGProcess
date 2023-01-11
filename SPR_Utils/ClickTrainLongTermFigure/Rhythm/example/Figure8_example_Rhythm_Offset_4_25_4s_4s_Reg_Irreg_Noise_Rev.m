close all; clc; clear;

monkeyId = 1;  % 1：chouchou; 2：xiaoxiao

if monkeyId == 1
    MATPATH{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\TITS_4_25_noise_3s_4s_Reg_Irreg_Rev\cc20221115\cc20221115_AC.mat';
    
elseif monkeyId == 2
    MATPATH{1} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\TITS_4_25_noise_3s_4s_Reg_Irreg_Rev\xx20221115\xx20221115_AC.mat';
end



fhp = 0.1;
flp = 10;
stimStrs = ["4ms_Reg_Irreg", "4ms_Irreg_Reg", "15ms_Reg_Irreg", "15ms_Irreg_Reg", "20ms_Reg_Irreg", "20ms_Irreg_Reg", "25ms_Reg_Irreg", "25ms_Irreg_Reg", "noise_15ms_Reg"];

protStr = "TITS_4_25_noise_3s_4s_Reg_Irreg_Rev";
ROOTPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\Rhythm\";
params.posIndex = 1; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;

CRIMethod = 2;

CRIScale = [0.8, 2; -0.1 0.5];
CRITest = [1, 0];
pBase = 0.01;

colors = ["#FF0000", "#FFA500","#00FF00" , "#0000FF", "#556B2F", "#000000", "#AAAAAA"];

AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);
fs = 500;

badCh = {[], []};
yScale = [30, 40];
quantWin = [0 300];
sponWin = [-300 0];
latencyWin = [80 200];
baseICI = [4, 4, 15, 15, 20, 20, 25, 25, 15];
ICI2 = baseICI;
correspFreq = 1000./ICI2;

for mIndex = 1 : length(MATPATH)
    disp(strcat("processing ", protStr(mIndex), "..."));
    temp = string(split(MATPATH{mIndex}, '\'));
    dateStr = temp(end - 1);
    Protocol = temp(end - 2);
    Protocols(mIndex) = Protocol;
    FIGPATH = strcat(ROOTPATH, "Figure8_TITS_4_25_noise_3s_4s_Reg_Irreg_Rev\", dateStr, "\", AREANAME, "\");
    mkdir(FIGPATH);
    %% process
    tic
    [trialAll, trialsECOG_Merge, trialsECOG_S1_Merge] =  mergeCTLTrialsECOG(MATPATH{mIndex}, params.posIndex);
    toc
    
    %% ICA
    % align to certain duration
    run("CTLconfig.m");
    ICAName = strcat(FIGPATH, "comp_", AREANAME, "_", protStr(mIndex), ".mat");
    trialsECOG_MergeTemp = trialsECOG_Merge;
    trialsECOG_S1_MergeTemp = trialsECOG_S1_Merge;

    if ~exist(ICAName, "file")
        [comp, ICs, FigTopoICA, FigWave, FigIC] = ICA_Population(trialsECOG_MergeTemp, fs, Window);
        compT = comp;
        compT.topo(:, ~ismember(1:size(compT.topo, 2), ICs)) = 0;
        trialsECOG_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_MergeTemp, "UniformOutput", false);
        trialsECOG_S1_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_S1_MergeTemp, "UniformOutput", false);
        print(FigWave(2), strcat(FIGPATH, "_IC_Rescutction_", protStr(mIndex)), "-djpeg", "-r200");
        print(FigTopoICA, strcat(FIGPATH, "_IC_Topo_", protStr(mIndex)), "-djpeg", "-r200");
        print(FigIC, strcat(FIGPATH, "_IC_Raw_", protStr(mIndex)), "-djpeg", "-r200");
        close(FigTopoICA);
        close(FigWave);
        close(FigIC);
        save(ICAName, "compT", "comp", "ICs", "-mat");
    else
        load(ICAName);
%         [~, ICs, FigTopoICA] = ICA_Exclude(trialsECOG_MergeTemp, comp, Window);
        trialsECOG_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_MergeTemp, "UniformOutput", false);
        trialsECOG_S1_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_S1_MergeTemp, "UniformOutput", false);
    end

    %% filter
     trialsECOG_Merge_Filtered = ECOGFilter(trialsECOG_Merge, fhp, flp, fs);
    
    %% process
    devType = unique([trialAll.devOrdr]);

    % initialize
    t = linspace(Window(1), Window(2), diff(Window) /1000 * fs + 1)';
    for ch = 1 : 64
        cdrPlot(ch).(strcat(protStr(mIndex), "info")) = strcat("Ch", num2str(ch));
        cdrPlot(ch).(strcat(protStr(mIndex), "Wave")) = zeros(length(t), 2 * length(devType));
    end

    %% diff stim type
    PMean = cell(length(MATPATH), length(devType));
    chMean = cell(length(MATPATH), length(devType));
    chMeanFilterd = cell(length(MATPATH), length(devType));
    trialsECOGFilterd = cell(length(MATPATH), length(devType));
    for dIndex = devType
        tIndex = [trialAll.devOrdr] == dIndex;
        trials = trialAll(tIndex);
        trialsECOG = trialsECOG_Merge(tIndex);
        trialsECOGFilterd = trialsECOG_Merge_Filtered(tIndex);
        % FFT during S1
        tIdx = find(t > FFTWin(1) & t < FFTWin(2));
        [ff, PMean{mIndex, dIndex}, trialsFFT]  = trialsECOGFFT(trialsECOG, fs, tIdx, [], 2);
        

        % raw wave
        chMean{mIndex, dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOG), 'UniformOutput', false));
        chStd = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOG), 'UniformOutput', false));

        % filter
        chMeanFilterd{mIndex, dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOGFilterd), 'UniformOutput', false));
        chStdFilter = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOGFilterd), 'UniformOutput', false));

       

        for ch = 1 : size(chMean{mIndex, dIndex}, 1)
            cdrPlot(ch).(strcat(protStr(mIndex), "Wave"))(:, 2 * dIndex - 1) = t';
            cdrPlot(ch).(strcat(protStr(mIndex), "Wave"))(:, 2 * dIndex) = chMean{mIndex, dIndex}(ch, :)';
            cdrPlot(ch).(strcat(protStr(mIndex), "WaveFilted"))(:, 2 * dIndex - 1) = t';
            cdrPlot(ch).(strcat(protStr(mIndex), "WaveFilted"))(:, 2 * dIndex) = chMeanFilterd{mIndex, dIndex}(ch, :)';
            cdrPlot(ch).(strcat(protStr(mIndex), "FFT"))(:, 2 * dIndex - 1) =ff;
            cdrPlot(ch).(strcat(protStr(mIndex), "FFT"))(:, 2 * dIndex) = PMean{mIndex, dIndex}(ch, :)';
        end

        % quantization amplitude
        [temp, amp, rmsSpon] = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trialsECOG, 'UniformOutput', false);
        ampNorm(dIndex).(strcat(protStr(mIndex), "_mean")) = cellfun(@mean, changeCellRowNum(temp));
        ampNorm(dIndex).(strcat(protStr(mIndex), "_se")) = cellfun(@(x) std(x)/sqrt(length(x)), changeCellRowNum(temp));
        ampNorm(dIndex).(strcat(protStr(mIndex), "_raw")) = changeCellRowNum(temp);
        ampNorm(dIndex).(strcat(protStr(mIndex), "_amp")) = amp;
        ampNorm(dIndex).(strcat(protStr(mIndex), "_rmsSpon")) = rmsSpon;

        % quantization latency
        [latency_mean, latency_se, latency_raw] = waveLatency_trough(trialsECOG, Window, latencyWin, 50, fs); %
        % thr = 0.5;
        %         [latency_mean, latency_se, latency_raw] = waveLatency_cumThreshold(trialsECOG, Window, quantWin, thr, fs, sponWin); %
        latency(dIndex).(strcat(protStr(mIndex), "_mean")) = latency_mean;
        latency(dIndex).(strcat(protStr(mIndex), "_se")) = latency_se;
        latency(dIndex).(strcat(protStr(mIndex), "_raw")) = latency_raw;


    end


    %% significance of s1 onset response
    [temp, ampS1{mIndex}, rmsSponS1{mIndex}] = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trialsECOG_S1_Merge, 'UniformOutput', false);
    ampNormS1.(strcat(protStr(mIndex), "_S1_mean")) = cellfun(@mean, changeCellRowNum(temp));
    ampNormS1.(strcat(protStr(mIndex), "_S1_se")) = cellfun(@(x) std(x)/sqrt(length(x)), changeCellRowNum(temp));
    ampNormS1.(strcat(protStr(mIndex), "_S1_raw")) = changeCellRowNum(temp);

    % compare S1Res and spon
    [S1H{mIndex}, S1P{mIndex}] = cellfun(@(x, y) ttest2(x, y), changeCellRowNum(ampS1{mIndex}), changeCellRowNum(rmsSponS1{mIndex}), "UniformOutput", false);

end



    %% plot FFT
for mIndex = 1 : length(MATPATH)
    for dIndex = devType

    FigFFT = plotRawWave(PMean{mIndex, dIndex}, [], [ff(1), ff(end)], strcat("FFT ", stimStrs(dIndex)));
    deleteLine(FigFFT, "LineStyle", "--");
    lines(1).X = correspFreq(mIndex, dIndex); lines(1).color = "k";
    addLines2Axes(FigFFT, lines);
    orderLine(FigFFT, "LineStyle", "--", "bottom");

    % rescale FFT Plot
    scaleAxes(FigFFT, "y", [0 400]);
    scaleAxes(FigFFT, "x", [0 150]);
    setAxes(FigFFT, 'yticklabel', '');
    setAxes(FigFFT, 'xticklabel', '');
    setAxes(FigFFT, 'visible', 'off');
    setLine(FigFFT, "YData", [0 400], "LineStyle", "--");
    pause(1);
    set(FigFFT, "outerposition", [300, 100, 800, 670]);
    plotLayout(FigFFT, params.posIndex + 2 * (monkeyId - 1), 0.3);
    print(FigFFT, strrep(strcat(FIGPATH, Protocols(mIndex), "_", stimStrs(dIndex),  "_FFT_", num2str(baseICI(dIndex)), "_", num2str(ICI2(dIndex))), ".", "o"), "-djpeg", "-r200");
    close(FigFFT);
    end
end


%% plot raw wave
for dIndex = devType
    diff = [];
    diffFilter = [];
    for mIndex = 1 : length(MATPATH)
        % for raw wave
        diff(1).chMean = chMean{mIndex, dIndex};
        diffFilter(1).chMean = chMeanFilterd{mIndex, dIndex};
        diff(1).color = "r";
        diffFilter(1).color = "r";
        FigWave = plotRawWaveMulti_SPR(diff, Window, titleStr, [8, 8]);
        FigWaveFilted = plotRawWaveMulti_SPR(diffFilter, Window, titleStr, [8, 8]);
        scaleAxes([FigWave, FigWaveFilted], "y", [-yScale(monkeyId) yScale(monkeyId)]);
        scaleAxes([FigWave, FigWaveFilted], "x", [-500 1000]);
        setLine([FigWave, FigWaveFilted], "YData", [-yScale(monkeyId) yScale(monkeyId)], "LineStyle", "--");

        setAxes([FigWave, FigWaveFilted], 'yticklabel', '');
        setAxes([FigWave, FigWaveFilted], 'xticklabel', '');
        setAxes([FigWave, FigWaveFilted], 'visible', 'off');
        
        pause(1);
        set([FigWave, FigWaveFilted], "outerposition", [300, 100, 800, 670]);
        plotLayout(FigWave, params.posIndex + 2 * (monkeyId - 1), 0.3);
        plotLayout(FigWaveFilted, params.posIndex + 2 * (monkeyId - 1), 0.3);
        print(FigWave, strrep(strcat(FIGPATH, Protocols(mIndex), "_", stimStrs(dIndex),  "_Wave_", num2str(baseICI(dIndex)), "_", num2str(ICI2(dIndex))), ".", "o"), "-djpeg", "-r200");
        print(FigWaveFilted, strrep(strcat(FIGPATH, Protocols(mIndex), "_", stimStrs(dIndex),  "_Wave_Filtered_", num2str(fhp), "_", num2str(flp), "Hz_", num2str(baseICI(dIndex)), "_", num2str(ICI2(dIndex))), ".", "o"), "-djpeg", "-r200");
        close(FigWave);
        close(FigWaveFilted);
    end
end


%% select certain channels to reduce noise via corr matrix
FigRho = mECOGCorr(trialsECOG_Merge, Window, [0 400], "method", "pearson", "refCh", 2, "selNum", 10);

%  plot trialMean result
trialMean = cell(length(MATPATH), length(devType));
trialStd = cell(length(MATPATH), length(devType));
trialsECOGMean = cell(length(MATPATH), length(devType));
for mIndex = 1 : length(MATPATH)
    for dIndex = devType
        tIndex = [trialAll.devOrdr] == dIndex;
        trialsECOGMean{dIndex, mIndex} = trialsECOG_Merge_Mean(tIndex);
        
        % Mean wave
        trialMean{dIndex, mIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOGMean{dIndex, mIndex}), 'UniformOutput', false));
        trialStd{dIndex, mIndex} = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOGMean{dIndex, mIndex}), 'UniformOutput', false));
    end

    meanTemp = cell2mat(trialMean(:, mIndex));
    stdTemp = cell2mat(trialStd(:, mIndex));

    Fig = plotRawWave(meanTemp, [], Window, "TITS_Rev", autoPlotSize(length(devType)));
    titles = strrep(stimStrs, "_", " ");
    setTitle(Fig, titles(devType));
    Axes = findobj(Fig, "Type", "axes");

    % add cursors of  S2 clicks
    for dIndex = devType
        idx = find(devType == dIndex);
        for lIndex = 1 : 5
            lines(lIndex).X = lIndex * ICI2(idx);
            lines(lIndex).Y = [-10, 10];
            lines(lIndex).color = "b";
        end
        addLines2Axes(Axes(end - idx + 1), lines);

        waves(1).X = t;
        waves(1).Y = cell2mat(trialsECOGMean{dIndex, mIndex});
        waves(1).color = "#AAAAAA";
        waves(1).width = 0.5;
        waves(1).style = "-";
        addLines2Axes(Axes(end - idx + 1), waves);
        
    end
    orderLine(Fig, "Color", [2/3, 2/3, 2/3], "bottom");
    scaleAxes(Fig, "x", [-100 600]);
    scaleAxes(Fig, "y", [-70 70]);
end


%% compare change 
changeOffset = [];

dev1 = 9;
dev2 = 4;

selWin = [-500 500];
[~, tIndex] = findWithinInterval(t, selWin);

changeOffset(1).chMean = chMean{1, dev1}(:, tIndex);
changeOffset(1).color = "r";
changeOffset(2).chMean = chMean{1, dev2}(:, tIndex);
changeOffset(2).color = "k";

FigCompare = plotRawWaveMulti_SPR(changeOffset, selWin);

orderLine(FigCompare, "Color", [1, 0, 0], "bottom");
scaleAxes(FigCompare, "y", [-30, 30]);


%% TFA Compare
dev1 = 3;
dev2 = 4;

selWin = [-3000 4000];
[~, tIndex] = findWithinInterval(t, selWin);
% [~, tIndex] = findWithinInterval(t, selWin -S1Duration(dev1) + changeTime(dev1));

% TFA MEAN
trialsECOG_Merge_Sel = cellfun(@(x) x(:, tIndex), trialsECOG_Merge, "UniformOutput", false);
trialsECOG = trialsECOG_Merge_Sel([trialAll.devOrdr] == dev1);
tic
FigTFAMean(1) = plotTFA_Mean(trialsECOG, fs, selWin, [0 10]);
toc


% [~, tIndex] = findWithinInterval(t, selWin -S1Duration(dev2) + changeTime(dev2));
trialsECOG = trialsECOG_Merge_Sel([trialAll.devOrdr] == dev2);
tic
FigTFAMean(2) = plotTFA_Mean(trialsECOG, fs, selWin, [0 10]);
toc
scaleAxes(FigTFAMean, "y", [0, 10]);
scaleAxes(FigTFAMean, "c", [1, 10]);
setAxes(FigTFAMean, "ColorScale", "linear");


% mean TFA

FigTFA(1) = plotTFA(chMean{1, dev1}(:, tIndex), fs, fs, selWin);
FigTFA(2) = plotTFA(chMean{1, dev2}(:, tIndex), fs, fs, selWin);
scaleAxes(FigTFA, "y", [0, 20]);
scaleAxes(FigTFA, "c", [0, 6]);
setAxes(FigTFA, "ColorScale", "linear");



%% check TFA
FigTFA = plotTFA(trialsECOG{1}, fs, fs, Window);
FigTFAMean = plotTFA_Mean(trialsECOG(1), fs, Window);
scaleAxes([FigTFAMean, FigTFA], "y", [0, 10]);
scaleAxes([FigTFAMean,FigTFA] , "c", [0, 10]);
scaleAxes([FigTFAMean,FigTFA], "x", selWin);
%% check click train
soundPath = "E:\ratNeuroPixel\monkeySounds\2022-11-14_Offset_Rep_By_Duration\offset";
soundParse = clickTrainCheckFcn(soundPath);
temp = soundParse(1);
soundT = (1 : length(temp.y1)) / temp.fs * 1000;
soundY = temp.y1;

resmpY = resample(soundY, length(t), length(soundT));
resmpT = resample(gpuArray(soundT), length(t), length(soundT)) - S1Duration(1);
resmpYSmth = smoothdata(resmpY, "gaussian", 100);
% plot(resmpT, resmpYSmth);

%% add click distribution to Fig
deleteLine(FigCompare, "Color", [0, 0.7, 0.7]);
CT(1).X = resmpT;
CT(1).Y = resmpYSmth * 2000 - 30;
CT(1).color = [0, 0.7, 0.7];
CT(1).style = "-";
CT(1).width = 1.5;
addLines2Axes(FigCompare, CT);



%%

ResName = strcat(FIGPATH, "cdrPlot_", AREANAME, ".mat");
save(ResName, "cdrPlot", "PMean", "chMean", "baseICI", "ICI2", "-mat");

if ~isempty(gcp('nocreate'))
    delete(gcp('nocreate'));
end
% close all
