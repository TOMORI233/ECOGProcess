 clc; clear;

monkeyId = 1;  % 1：chouchou; 2：xiaoxiao

if monkeyId == 1
    MATPATH{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\TB\Successive_0o3_0o5\';
    MATPATH{2} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\TB\Successive_0o1_0o2\';
    MATPATH{3} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\TB\Successive_0o025_0o05\';
elseif monkeyId == 2
    MATPATH{1} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\TB\Successive_0o3_0o5\';
    MATPATH{2} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\TB\Successive_0o1_0o2\';
    MATPATH{3} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\TB\Successive_0o025_0o05\';
end

stimSelect = 4; % changed reg", "frozen irreg", "rand irreg", "changed reg", "frozen irreg", "rand irreg"
selectCh = 9;
stimStrs = ["changed reg", "frozen irreg", "rand irreg", "changed reg", "frozen irreg", "rand irreg"];
%  stimStrs = string(['changed reg_', changeTimeStr{mIndex, 1}], ["frozen irreg", changeTimeStr{mIndex, 1}], ["rand irreg", changeTimeStr{mIndex, 1}],...
%         ['changed reg_', changeTimeStr{mIndex, 2}], ["frozen irreg", changeTimeStr{mIndex, 2}], ["rand irreg", changeTimeStr{mIndex, 2}]);
correspFreq = [repmat([1000/300; 1000/100; 1000/25], 1, 3), repmat([1000/500; 1000/200; 1000/50], 1, 3)];
protStr = [repmat(["C300"; "C100"; "C25"], 1, 3), repmat(["C500"; "C200"; "C50"], 1, 3)];

ROOTPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\Basic\";
params.posIndex = 1; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;

% Synchronize response index
SRIMethod = 2;
SRIMethodStr = ["Resp_devided_by_Spon", "R_minus_S_devide_R_plus_S"];
SRIScale = [0.8, 2; 0 0.2];
SRITest = [1, 0];

% FFT method
FFTMethod = 1; %1: power(dB); 2: magnitude
fftScale = [60, 60; 10, 10];

colors = ["#FF0000", "#FFA500", "#0000FF", "#000000", "#AAAAAA"];

AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);
fs = 500;

badCh = {[], []};
yScale = [60, 60];
quantWin = [0 300];
sponWin = [-3000 0];

for mIndex = 1 : length(MATPATH)

    temp = string(split(MATPATH{mIndex}, '\'));
    Protocol = temp(end - 1);
    Protocols{mIndex} = Protocol;


    FIGPATH = strcat(ROOTPATH, "\Pop_Figure6\", SRIMethodStr(SRIMethod), "\", stimStrs(stimSelect), "\");
    mkdir(FIGPATH);


    %% process
    [trialsECOG_Merge, trialsECOG_S1_Merge , ~, ~, trialAll] = mergeECOGPreprocess(MATPATH{mIndex}, AREANAME);
    
    % align to certain duration
    run("CTLconfig.m");
   
    devType = unique([trialAll.devOrdr]);
    
    % cdrPlot initialize
    t = linspace(Window(1), Window(2), diff(Window) /1000 * fs + 1)';

    % diff stim type
    for dIndex = 1:length(devType)
        powNorm(dIndex).info = strcat(stimStrs(dIndex), "_", protStr(mIndex, dIndex));
        fftPValue(dIndex).info = strcat(stimStrs(dIndex), "_", protStr(mIndex, dIndex));
        for ch = 1 : 64
            cdrPlot(ch).(strcat(protStr(mIndex, dIndex), "info")) = strcat("Ch", num2str(ch));
            cdrPlot(ch).(strcat(protStr(mIndex, dIndex), "Wave")) = zeros(length(t), 2 * length(devType));
        end
        tIndex = [trialAll.devOrdr] == devType(dIndex);
        trials = trialAll(tIndex);
         trialsECOG = trialsECOG_Merge(tIndex);

        chMean{dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOG), 'UniformOutput', false));
        chStd = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOG), 'UniformOutput', false));

        % FFT during successive sound
        tIdx = find(t > FFTWin(1) & t < FFTWin(2));
        [ff, PMean{dIndex}, trialsFFT]  = trialsECOGFFT(trialsECOG, fs, tIdx, [], FFTMethod);
        % FFT during data after successive sound
        tIdx = find(t > sponWin(1) & t < sponWin(2));
        [ff_Spon_Temp, PMean_Spon_Temp, trialsFFT_Spon_Temp]  = trialsECOGFFT(trialsECOG, fs, tIdx, [], FFTMethod);

        for cIndex = 1 : length(trialsFFT_Spon_Temp)
            trialsFFT_Spon{cIndex, 1} = cellfun(@(x) interp1(ff_Spon_Temp, x, ff), trialsFFT_Spon_Temp{cIndex}, "uni", false);
        end
        PMean_Spon{dIndex} = interp1(ff_Spon_Temp', PMean_Spon_Temp', ff')';
        ff_Spon = ff;

        for ch = 1 : size(chMean{dIndex}, 1)
            cdrPlot(ch).(strcat(protStr(mIndex, dIndex), "Wave"))(:, 2 * dIndex - 1) = t';
            cdrPlot(ch).(strcat(protStr(mIndex, dIndex), "Wave"))(:, 2 * dIndex) = chMean{dIndex}(ch, :)';
            cdrPlot(ch).(strcat(protStr(mIndex, dIndex), "FFT"))(:, 2 * dIndex - 1) = ff;
            cdrPlot(ch).(strcat(protStr(mIndex, dIndex), "FFT"))(:, 2 * dIndex) = PMean{dIndex}(ch, :)';
            cdrPlot(ch).(strcat(protStr(mIndex, dIndex), "FFT_Base"))(:, 2 * dIndex - 1) = ff_Spon;
            cdrPlot(ch).(strcat(protStr(mIndex, dIndex), "FFT_Base"))(:, 2 * dIndex) = PMean_Spon{dIndex}(ch, :)';
        end

        [tarMean, idx] = findWithinWindow(PMean{dIndex}, ff, [0.9, 1.1] * correspFreq(mIndex, dIndex));
        [~, targetIndex] = max(tarMean, [], 2);
        targetIndex = mode(targetIndex) + idx(1) - 1;

         % quantization power
        [temp, pow(dIndex).(protStr(mIndex, dIndex)), powSpon(dIndex).(protStr(mIndex, dIndex))] = ...
            waveFFTPower_Norm(trialsFFT, trialsFFT_Spon, SRIMethod, [{ff}, {ff_Spon}], targetIndex);

        powNorm(dIndex).(strcat(protStr(mIndex, dIndex), "_mean")) = cellfun(@mean, temp);
        powNorm(dIndex).(strcat(protStr(mIndex, dIndex), "_se")) = cellfun(@(x) std(x)/sqrt(length(x)), temp);
        powNorm(dIndex).(strcat(protStr(mIndex, dIndex), "_raw")) = temp;

        [H, P] = waveFFTPower_pValue(trialsFFT, trialsFFT_Spon, [{ff}, {ff_Spon}], targetIndex, 2);
        fftPValue(dIndex).(strcat(protStr(mIndex, dIndex), "_pValue")) = P;
        fftPValue(dIndex).(strcat(protStr(mIndex, dIndex), "_H")) = H;

    end


    % for raw wave
    Successive(1).chMean = PMean{stimSelect}; Successive(1).color = "r";
    Successive(2).chMean = PMean_Spon{stimSelect}; Successive(2).color = "k";

    %% plot raw wave
    FigWave = plotRawWaveMulti_SPR(Successive, [0 fs/2], strcat(protStr(mIndex, stimSelect), "ms Oscillation"), [8, 8]);
    FigWave = deleteLine(FigWave, "LineStyle", "--");
    scaleAxes(FigWave, "y", [0 fftScale(FFTMethod, monkeyId)]);
    scaleAxes(FigWave, "x", [0 50]);
    %     setAxes(FigWave, "Xscale", "log");
    lines(1).X = correspFreq(mIndex, stimSelect); lines(1).color = "k";
    addLines2Axes(FigWave, lines);
    orderLine(FigWave, "LineStyle", "--", "bottom");
    setAxes(FigWave, 'yticklabel', '');
    setAxes(FigWave, 'xticklabel', '');
    setAxes(FigWave, 'visible', 'off');
    setLine(FigWave, "YData", [-fftScale(FFTMethod, monkeyId) fftScale(FFTMethod, monkeyId)], "LineStyle", "--");
    set(FigWave, "outerposition", [300, 100, 800, 670]);
    plotLayout(FigWave, params.posIndex + 2 * (monkeyId - 1), 0.3);
    print(FigWave, strcat(FIGPATH, Protocol, "_Wave_", protStr(mIndex, stimSelect), "_", stimStrs(stimSelect)), "-djpeg", "-r200");
    close(FigWave);


    %% plot  SRI value topo
    topo = powNorm(stimSelect).(strcat(protStr(mIndex, stimSelect), "_mean"));
    if ~isempty(badCh{monkeyId})
        topo(badCh{monkeyId}) = SRITest(SRIMethod);
    end
    FigTopo = plotTopo_Raw(topo, [8, 8]);
    colormap(FigTopo, "jet");
    scaleAxes(FigTopo, "c", SRIScale(SRIMethod, :));
    set(FigTopo, "outerposition", [300, 100, 800, 670]);
    print(FigTopo, strcat(FIGPATH, Protocol, "_SRI_Topo_", protStr(mIndex, stimSelect), "_", stimStrs(stimSelect)), "-djpeg", "-r200");
    close(FigTopo);
end

%% p-value distribution
for sIndex = [1, 4]
for mIndex = 1 : length(MATPATH)
    % plot p-value topo
    temp = fftPValue(sIndex).(strcat(protStr(mIndex, sIndex), "_pValue"));
    topo = logg(0.05, temp / 0.05);
        topo(isinf(topo)) = 5;
        topo(topo > 5) = 5;
        FigTopo(mIndex) = plotTopo_Raw(topo, [8, 8]);
        colormap(FigTopo(mIndex), "jet");
        scaleAxes(FigTopo(mIndex), "c", [-5 5]);
    set(FigTopo(mIndex), "outerposition", [300, 100, 800, 670]);
    print(FigTopo(mIndex), strcat(FIGPATH, Protocols{mIndex}, "_pValue_Topo_", protStr(mIndex, sIndex), "_", stimStrs(stimSelect)), "-djpeg", "-r200");
end
end

% %% p-value of different base ICI
% toPlot_Wave = zeros(length(t), 2 * length(MATPATH));
% 
% for mIndex = 1 : length(MATPATH)
%     toPlot_Wave(:, [2 * mIndex - 1, 2 * mIndex]) = cdrPlot(selectCh).(strcat(protStr(mIndex, dIndex), "Wave"))(:, [2 * stimSelect - 1, 2 * stimSelect]);
%     % compare change resp and spon resp
%     %     [sponH{mIndex}, sponP{mIndex}] = cellfun(@(x, y) ttest(x, y), changeCellRowNum(amp(1).(protStr(mIndex))), changeCellRowNum(rmsSpon(1).(protStr(mIndex))), "UniformOutput", false);
%     % compare powNorm and 1
%     temp = powNorm(stimSelect).(strcat(protStr(mIndex, stimSelect), "_raw"));
%     OneArray = repmat({ones(length(temp{1}), 1) * SRITest(SRIMethod)}, length(temp), 1);
%     [sponH{mIndex}, sponP{mIndex}] = cellfun(@(x, y) ttest2(x, y), temp, OneArray, "UniformOutput", false);
% 
%     % plot p-value topo
%     topo = logg(2, logg(0.05, cell2mat(sponP{mIndex})));
%     FigTopo(mIndex) = plotTopo_Raw(topo, [8, 8]);
%     colormap(FigTopo(mIndex), "jet");
%     scaleAxes(FigTopo(mIndex), "c", [0 3]);
%     set(FigTopo(mIndex), "outerposition", [300, 100, 800, 670]);
%     print(FigTopo(mIndex), strcat(FIGPATH, Protocols{mIndex}, "_pValue_Topo_", protStr(mIndex, stimSelect), "_", stimStrs(stimSelect)), "-djpeg", "-r200");
% end




% %% Diff ICI amplitude comparison
% if stimSelect <= 2
%     sigCh = find(cell2mat(sponH{1}) == 1);
% else
%     sigCh = 1 : 64;
% end
% temp = reshape([powNorm(stimSelect).(strcat(protStr(stimSelect, 1), "_mean"))(sigCh)'; powNorm(stimSelect).(strcat(protStr(stimSelect, 2), "_mean"))(sigCh)';...
%     powNorm(stimSelect).(strcat(protStr(stimSelect, 3), "_mean"))(sigCh)'; powNorm(stimSelect).(strcat(protStr(stimSelect, 1), "_se"))(sigCh)';...
%     powNorm(stimSelect).(strcat(protStr(stimSelect, 2), "_se"))(sigCh)'; powNorm(stimSelect).(strcat(protStr(stimSelect, 3), "_se"))(sigCh)'], 3, []) ;
% 
% compare.amp_mean_se = [[1; 2; 3], temp];

close all
