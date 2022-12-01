close all; clc; clear;

monkeyId = 1;  % 1：chouchou; 2：xiaoxiao

if monkeyId == 1
    MATPATH{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Add_on_Basic_ICI4\cc20221027\cc20221027_AC.mat';
    
elseif monkeyId == 2

end



fhp = 0.1;
flp = 10;
stimStrs = ["4-4.06ms Reg", "4.06-4ms Reg", "4-4.06ms Irreg", "4.06-4ms Irreg"];

protStr = "Add_on_Basic_ICI4";
ROOTPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\Basic\";
params.posIndex = 1; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;

CRIMethod = 2;

CRIScale = [0.8, 2; -0.1 0.5];
CRITest = [1, 0];
pBase = 0.01;

colors = ["#FF0000", "#FFA500", "#0000FF", "#000000"];

AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);
fs = 500;

badCh = {[], []};
yScale = [30, 40];
quantWin = [0 300];
sponWin = [-300 0];
latencyWin = [80 200];
baseICI = [4, 4.06, 4, 4.06];
ICI2 = [4.06, 4, 4.06, 4];
correspFreq = 1000./ICI2;

for mIndex = 1 : length(MATPATH)
    disp(strcat("processing ", protStr(mIndex), "..."));
    temp = string(split(MATPATH{mIndex}, '\'));
    dateStr = temp(end - 1);
    Protocol = temp(end - 2);
    Protocols(mIndex) = Protocol;
    FIGPATH = strcat(ROOTPATH, "\Figure2\", dateStr, "\", AREANAME, "\");
    
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
    for dIndex = 1 : length(devType)
        tIndex = [trialAll.devOrdr] == devType(dIndex);
        trials = trialAll(tIndex);
        trialsECOG = trialsECOG_Merge(tIndex);

        % raw wave
        chMean{mIndex, dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOG), 'UniformOutput', false));
        chStd = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOG), 'UniformOutput', false));


       

        for ch = 1 : size(chMean{mIndex, dIndex}, 1)
            cdrPlot(ch).(strcat(protStr(mIndex), "Wave"))(:, 2 * dIndex - 1) = t';
            cdrPlot(ch).(strcat(protStr(mIndex), "Wave"))(:, 2 * dIndex) = chMean{mIndex, dIndex}(ch, :)';
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






%% plot raw wave
for dIndex = 1 : length(devType)
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


        addLines2Axes([FigWave, FigWaveFilted], lines);
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


%% compare offset and change 
regIdx = [1, 2];
irregIdx = [3, 4];
devIdx = 2;
selWin = [-100 400];
[~, tIndex] = findWithinInterval(t, selWin + soundDur(regIdx(devIdx)) - S1Duration(regIdx(devIdx)));
changeOffset(1).chMean = chMean{1, regIdx(devIdx)}(:, tIndex);
changeOffset(1).color = "r";

[~, tIndex] = findWithinInterval(t, selWin + soundDur(irregIdx(devIdx)) - S1Duration(irregIdx(devIdx)));
changeOffset(2).chMean = chMean{1, irregIdx(devIdx)}(:, tIndex);
changeOffset(2).color = "k";

FigCompare = plotRawWaveMulti_SPR(changeOffset, selWin);



%%

ResName = strcat(FIGPATH, "res_", AREANAME, ".mat");
save(ResName, "cdrPlot", "PMean", "chMean", "baseICI", "ICI2", "-mat");

if ~isempty(gcp('nocreate'))
    delete(gcp('nocreate'));
end
% close all
