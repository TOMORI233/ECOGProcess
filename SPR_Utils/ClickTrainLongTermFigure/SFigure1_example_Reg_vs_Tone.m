close all; clc; clear;

MATPATH{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Basic_ICI4\cc20220713\cc20220713_AC.mat';
MATPATH{2} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\Basic_ICI4\xx20220725\xx20220725_AC.mat';
monkeyStr = ["CC", "XX"];
ROOTPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\";
params.posIndex = 1; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;

flp = 400;
fhp = 0.1;
segOption = ["trial onset", "dev onset"];
s1OnsetOrS2Onset = 2; % 1, s1onset; 2, s2Onset
colors = ["#FF0000", "#FFA500", "#0000FF", "#000000"];

AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);

FIGPATH = strcat(ROOTPATH, "\Figure1\");
mkdir(FIGPATH);

selectCh = [13 37];
badCh = {[], [57, 62]};
yScale = [50, 90];
quantWin = [0 300];
sponWin = [-300 0];
for mIndex = 1 : 2

temp = string(split(MATPATH{mIndex}, '\'));
DateStr = temp(end - 1);
Protocol = temp(end - 2);

%% process 
[trialAll, ECOGDataset] = ECOGPreprocess(MATPATH{mIndex}, params);

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
    cdrPlot(ch).(strcat(monkeyStr(mIndex), "info")) = strcat("Ch", num2str(ch));
    cdrPlot(ch).(strcat(monkeyStr(mIndex), "Wave")) = zeros(length(t), 2 * length(devType));
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
    for ch = 1 : size(chMean, 1)
        cdrPlot(ch).(strcat(monkeyStr(mIndex), "Wave"))(:, 2 * dIndex - 1) = t';
        cdrPlot(ch).(strcat(monkeyStr(mIndex), "Wave"))(:, 2 * dIndex) = chMean{dIndex}(ch, :)';
    end

    % quantization   
    temp = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, 1, sponWin), trialsECOG, 'UniformOutput', false);
    ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_mean")) = cellfun(@mean, changeCellRowNum(temp));
    ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_std")) = cellfun(@std, changeCellRowNum(temp));
    ampNorm(dIndex).(strcat(monkeyStr(mIndex), "_raw")) = changeCellRowNum(temp);
end

%% plot  figure
ICIDiff(1).chMean = chMean{1}; ICIDiff(1).color = "r";
ICIDiff(2).chMean = chMean{3}; ICIDiff(2).color = "k";
FigWave(mIndex) = plotRawWaveMulti_SPR(ICIDiff, Window, titleStr, [8, 8]);

topo = ampNorm(1).(strcat(monkeyStr(mIndex), "_mean"));
if ~isempty(badCh{mIndex})
    topo(badCh{mIndex}) = 1;
end
FigTopo(mIndex) = plotTopo_Raw(topo, [8, 8]);
colormap(FigTopo(mIndex), "jet");

%% change figure scale
scaleAxes(FigTopo(mIndex), "c", [0.8 2]);
scaleAxes(FigWave(mIndex), "y", [-yScale(mIndex) yScale(mIndex)]);
scaleAxes(FigWave(mIndex), "x", [-10 600]);
setAxes(FigWave(mIndex), 'yticklabel', '');
setAxes(FigWave(mIndex), 'xticklabel', '');
setAxes(FigWave(mIndex), 'visible', 'off');
setLine(FigWave(mIndex), "YData", [-yScale(mIndex) yScale(mIndex)], "LineStyle", "--");
set([FigTopo(mIndex), FigWave(mIndex)], "outerposition", [300, 100, 800, 670]);
if contains(DateStr, "cc")
    plotLayout(FigWave(mIndex), params.posIndex, 0.3);
elseif contains(DateStr, "xx")
    plotLayout(FigWave(mIndex), params.posIndex + 2, 0.3);
end

print(FigWave(mIndex), strcat(FIGPATH, DateStr, "_", Protocol, "_Wave"), "-djpeg", "-r200");
print(FigTopo(mIndex), strcat(FIGPATH, DateStr, "_", Protocol, "_Topo"), "-djpeg", "-r200");

end

close all
