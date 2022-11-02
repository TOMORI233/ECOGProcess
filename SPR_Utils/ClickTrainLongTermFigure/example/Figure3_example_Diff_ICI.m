close all; clc; clear;

monkeyId = 2;  % 1：chouchou; 2：xiaoxiao

if monkeyId == 1
    MATPATH{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Basic_ICI4\cc20220713\cc20220713_AC.mat';
    MATPATH{2} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Basic_ICI8\cc20220713\cc20220713_AC.mat';
    MATPATH{3} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Basic_ICI20\cc20220714\cc20220714_AC.mat';
    MATPATH{4} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Basic_ICI40\cc20220714\cc20220714_AC.mat';
    MATPATH{5} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Basic_ICI80\cc20220714\cc20220714_AC.mat';
elseif monkeyId == 2
    MATPATH{1} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\Basic_ICI4\xx20220711\xx20220711_AC.mat';
    MATPATH{2} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\Basic_ICI8\xx20220711\xx20220711_AC.mat';
    MATPATH{3} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\Basic_ICI20\xx20220711\xx20220711_AC.mat';
    MATPATH{4} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\Basic_ICI40\xx20220711\xx20220711_AC.mat';
    MATPATH{5} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\Basic_ICI80\xx20220711\xx20220711_AC.mat';
end

stimSelect = 1; % "RegOrd", "RegRev", "IrregOrd", "IrregRev"
selectCh = 9;
stimStrs = ["RegOrd", "RegRev", "IrregOrd", "IrregRev"];

protStr = ["ICI4", "ICI8", "ICI20", "ICI40", "ICI80"];
ROOTPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\Basic\";
params.posIndex = 1; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;

CRIMethod = 2;
CRIMethodStr = ["Resp_devided_by_Spon", "R_minus_S_devide_R_plus_S"];
CRIScale = [0.8, 2; -0.1 0.2];
CRITest = [1, 0];


flp = 400;
fhp = 0.1;
segOption = ["trial onset", "dev onset"];
s1OnsetOrS2Onset = 2; % 1, s1onset; 2, s2Onset
colors = ["#FF0000", "#FFA500", "#0000FF", "#000000", "#AAAAAA"];

AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);




badCh = {[], []};
yScale = [60, 90];
quantWin = [0 300];
sponWin = [-300 0];

for mIndex = 1 : 5

    temp = string(split(MATPATH{mIndex}, '\'));
    DateStr{mIndex} = temp(end - 1);
    Protocol = temp(end - 2);
    Protocols{mIndex} = Protocol;
    FIGPATH = strcat(ROOTPATH, "\Figure3\", DateStr{1}, "\", CRIMethodStr(CRIMethod), "\", stimStrs(stimSelect), "\");
    mkdir(FIGPATH);
    %% process
    [trialAll, ECOGDataset] = ECOGPreprocess(MATPATH{mIndex}, params);
    fs = ECOGDataset.fs;
    % align to certain duration
    run("CTLconfig.m");
    trialAll(1) = [];
    devType = unique([trialAll.devOrdr]);
    devTemp = {trialAll.devOnset}';
    [~, ordTemp] = ismember([trialAll.ordrSeq]', devType);
    temp = cellfun(@(x, y) x + S1Duration(y), devTemp, num2cell(ordTemp), "UniformOutput", false);
    trialAll = addFieldToStruct(trialAll, temp, "devOnset");

    % filter
    ECOGFDZ = mFTHP(ECOGDataset, 0.1, 400);% filtered, dowmsampled, zoomed

    % initialize
    t = linspace(Window(1), Window(2), diff(Window) /1000 * ECOGDataset.fs + 1)';
    for ch = 1 : length(ECOGFDZ.channels)
        cdrPlot(ch).(strcat(protStr(mIndex), "info")) = strcat("Ch", num2str(ch));
        cdrPlot(ch).(strcat(protStr(mIndex), "Wave")) = zeros(length(t), 2 * length(devType));
    end

    % diff stim type
    for dIndex = 1:length(devType)
        tIndex = [trialAll.devOrdr] == devType(dIndex);
        trials = trialAll(tIndex);
        trialsECOG = selectEcog(ECOGFDZ, trials, segOption(s1OnsetOrS2Onset), Window);

        % exclude trial
        trialsECOG = excludeTrialsChs(trialsECOG, 0.1);
        chMean{dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOG), 'UniformOutput', false));
        chStd = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOG), 'UniformOutput', false));
        for ch = 1 : size(chMean{dIndex}, 1)
            cdrPlot(ch).(strcat(protStr(mIndex), "Wave"))(:, 2 * dIndex - 1) = t';
            cdrPlot(ch).(strcat(protStr(mIndex), "Wave"))(:, 2 * dIndex) = chMean{dIndex}(ch, :)';
        end

        % quantization amplitude
        [temp, amp(dIndex).(protStr(mIndex)), rmsSpon(dIndex).(protStr(mIndex))] = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trialsECOG, 'UniformOutput', false);
        ampNorm(dIndex).(strcat(protStr(mIndex), "_mean")) = cellfun(@mean, changeCellRowNum(temp));
        ampNorm(dIndex).(strcat(protStr(mIndex), "_se")) = cellfun(@(x) std(x)/sqrt(length(x)), changeCellRowNum(temp));
        ampNorm(dIndex).(strcat(protStr(mIndex), "_raw")) = changeCellRowNum(temp);

        % quantization latency
        [latency_mean, latency_se, latency_raw] = waveLatency_trough(trialsECOG, Window, quantWin, 5, fs); %
        % thr = 0.5;
        %         [latency_mean, latency_se, latency_raw] = waveLatency_cumThreshold(trialsECOG, Window, quantWin, thr, fs, sponWin); %
        latency(dIndex).(strcat(protStr(mIndex), "_mean")) = latency_mean;
        latency(dIndex).(strcat(protStr(mIndex), "_se")) = latency_se;
        latency(dIndex).(strcat(protStr(mIndex), "_raw")) = latency_raw;
    end





    %% plot  CRI value topo
    topo = ampNorm(stimSelect).(strcat(protStr(mIndex), "_mean"));
    if ~isempty(badCh{monkeyId})
        topo(badCh{monkeyId}) = CRITest(CRIMethod);
    end
    FigTopo = plotTopo_Raw(topo, [8, 8]);
    colormap(FigTopo, "jet");
    scaleAxes(FigTopo, "c", CRIScale(CRIMethod, :));
    set(FigTopo, "outerposition", [300, 100, 800, 670]);
    print(FigTopo, strcat(FIGPATH, Protocol, "_CRI_Topo_", protStr(mIndex), "_", stimStrs(stimSelect)), "-djpeg", "-r200");
    close(FigTopo);


    % for raw wave
    DiffICI(mIndex).chMean = chMean{stimSelect};
    DiffICI(mIndex).color = colors(mIndex);
end

%% plot raw wave
FigWave = plotRawWaveMulti_SPR(DiffICI, Window, titleStr, [8, 8]);
scaleAxes(FigWave, "y", [-yScale(monkeyId) yScale(monkeyId)]);
scaleAxes(FigWave, "x", [-10 600]);
setAxes(FigWave, 'yticklabel', '');
setAxes(FigWave, 'xticklabel', '');
setAxes(FigWave, 'visible', 'off');
setLine(FigWave, "YData", [-yScale(monkeyId) yScale(monkeyId)], "LineStyle", "--");
set(FigWave, "outerposition", [300, 100, 800, 670]);
plotLayout(FigWave, params.posIndex + 2 * (monkeyId - 1), 0.3);
print(FigWave, strcat(FIGPATH, Protocol, "_Wave_", stimStrs(stimSelect)), "-djpeg", "-r200");
close(FigWave);

%% p-value of different base ICI
toPlot_Wave = zeros(length(t), 2 * length(MATPATH));

for mIndex = 1 : length(MATPATH)
    toPlot_Wave(:, [2 * mIndex - 1, 2 * mIndex]) = cdrPlot(selectCh).(strcat(protStr(mIndex), "Wave"))(:, [2 * stimSelect - 1, 2 * stimSelect]);
    % compare change resp and spon resp
    %     [sponH{mIndex}, sponP{mIndex}] = cellfun(@(x, y) ttest(x, y), changeCellRowNum(amp(1).(protStr(mIndex))), changeCellRowNum(rmsSpon(1).(protStr(mIndex))), "UniformOutput", false);
    % compare ampNorm and 1
    temp = ampNorm(stimSelect).(strcat(protStr(mIndex), "_raw"));
    OneArray = repmat({ones(length(temp{1}), 1) * CRITest(CRIMethod)}, length(temp), 1);
    [sponH{mIndex}, sponP{mIndex}] = cellfun(@(x, y) ttest2(x, y), temp, OneArray, "UniformOutput", false);

    % plot p-value topo
    topo = logg(0.05, cell2mat(sponP{mIndex}) / 0.05);
    topo(isinf(topo)) = 5;
    topo(topo > 5) = 5;
    FigTopo= plotTopo_Raw(topo, [8, 8]);
    colormap(FigTopo, "jet");
    scaleAxes(FigTopo, "c", [-5 5]);
    set(FigTopo(mIndex), "outerposition", [300, 100, 800, 670]);
    print(FigTopo(mIndex), strcat(FIGPATH, Protocols{mIndex}, "_pValue_Topo_", protStr(mIndex), "_", stimStrs(stimSelect)), "-djpeg", "-r200");
end




%% Diff ICI amplitude comparison
if stimSelect <= 2
    sigCh = find(cell2mat(sponH{1}) == 1);
else
    sigCh = 1 : 64;
end
temp = reshape([ampNorm(stimSelect).(strcat(protStr(1), "_mean"))(sigCh)'; ampNorm(stimSelect).(strcat(protStr(2), "_mean"))(sigCh)';...
    ampNorm(stimSelect).(strcat(protStr(3), "_mean"))(sigCh)'; ampNorm(stimSelect).(strcat(protStr(4), "_mean"))(sigCh)';...
    ampNorm(stimSelect).(strcat(protStr(5), "_mean"))(sigCh)'; ampNorm(stimSelect).(strcat(protStr(1), "_se"))(sigCh)';...
    ampNorm(stimSelect).(strcat(protStr(2), "_se"))(sigCh)'; ampNorm(stimSelect).(strcat(protStr(3), "_se"))(sigCh)';...
    ampNorm(stimSelect).(strcat(protStr(4), "_se"))(sigCh)'; ampNorm(stimSelect).(strcat(protStr(5), "_se"))(sigCh)'], 5, []) ;

compare.amp_mean_se = [[1; 2; 3; 4; 5], temp];


%% Diff ICI latency comparison
if stimSelect <= 2
    %     sigCh = find(cell2mat(sponH{1}) == 1 & cell2mat(sponH{2}) == 1 );
    sigCh = find(cell2mat(sponH{1}) == 1);
else
    sigCh = 1 : 64;
end
temp = reshape([latency(stimSelect).(strcat(protStr(1), "_mean"))(sigCh)'; latency(stimSelect).(strcat(protStr(2), "_mean"))(sigCh)';...
    latency(stimSelect).(strcat(protStr(3), "_mean"))(sigCh)'; latency(stimSelect).(strcat(protStr(4), "_mean"))(sigCh)';...
    latency(stimSelect).(strcat(protStr(5), "_mean"))(sigCh)'; latency(stimSelect).(strcat(protStr(1), "_se"))(sigCh)';...
    latency(stimSelect).(strcat(protStr(2), "_se"))(sigCh)'; latency(stimSelect).(strcat(protStr(3), "_se"))(sigCh)';...
    latency(stimSelect).(strcat(protStr(4), "_se"))(sigCh)'; latency(stimSelect).(strcat(protStr(5), "_se"))(sigCh)'], 5, []) ;
compare.latency_mean_se = [[1; 2; 3; 4; 5], temp];



%% plot latency value topo
for mIndex = 1 : length(MATPATH)
    sigCh = cell2mat(sponH{mIndex}) == 1;
    %         latency(stimSelect).(strcat(protStr(mIndex), "_mean"))(~ismember(1 : 64, sigCh)) = quantWin(2);
    %         latency(stimSelect).(strcat(protStr(mIndex), "_se"))(~ismember(1 : 64, sigCh)) = 0;
    topo = latency(stimSelect).(strcat(protStr(mIndex), "_mean"));
    if ~isempty(badCh{monkeyId})
        topo(badCh{monkeyId}) = quantWin(2);
    end
    topo(~sigCh) = quantWin(2);
    topo = ((quantWin(2) - topo)/quantWin(2)).^2;
    FigTopo = plotTopo_Raw(topo, [8, 8]);
    colormap(FigTopo, "jet");
    scaleAxes(FigTopo, "c", [0 0.5]);
    set(FigTopo, "outerposition", [300, 100, 800, 670]);
    print(FigTopo, strcat(FIGPATH, Protocol, "_latency_Topo_", protStr(mIndex), "_", stimStrs(stimSelect)), "-djpeg", "-r200");
    close(FigTopo);
end


% clearvars -except toPlot_Wave compare sigch cdrPlot ampNorm latency temp
close all
