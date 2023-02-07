clc; close all;
MATPATH = MATPATHS{mIndex};
if contains(MATPATH, "CC")
    monkeyId = 1;  % 1：chouchou; 2：xiaoxiao
    monkeyStr = "CC";
elseif contains(MATPATH, "XX")
    monkeyId = 2;
    monkeyStr = "XX";
end

AREANAME = ["AC", "PFC"];
params.posIndex = find(matches(AREANAME, areaSel)); % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;
AREANAME = AREANAME(params.posIndex);

%% load parameters
MSTIParams = ME_ParseMSTIParams(protocolStr);
parseStruct(MSTIParams);
% fs = 600;

%% process
temp = string(split(MATPATH, '\'));
DateStr = temp(end - 1);
Protocol = temp(end - 2);
FIGPATH = strcat(rootPathFig, "Figure_", protStr,"\", DateStr, "_", AREANAME, "\Figures\");
% if exist(FIGPATH, "dir")
%     return
% end

tic
[trialAll, trialsECOG_Merge] =  mergeMSTITrialsECOG(MATPATH, params.posIndex, MSTIParams);
toc


%% seperate groups
groupN = 0;
for gIndex = 1 : size(S1_S2, 1) % diff BG
    for sIndex = 1 : size(S1_S2, 2) %% S1 or S2
        groupN = groupN + 1;
        DevStr = S1_S2(gIndex, sIndex);   comparePool(groupN).DevStr = DevStr;
        StdStr = S1_S2(gIndex, 2-sIndex+1);  comparePool(groupN).StdStr = StdStr;
        comparePool(groupN).Odd_Dev_Index = find(cell2mat(cellfun(@(x) strcmpi(x(2), DevStr)&~strcmpi(x(1), "ManyStd"), cellfun(@(x) string(strsplit(x, "_")), stimStrs, "uni", false)', "UniformOutput", false)));
        comparePool(groupN).ManyStd_Dev_Index = find(cell2mat(cellfun(@(x) strcmpi(x(2), DevStr)&strcmpi(x(1), "ManyStd"), cellfun(@(x) string(strsplit(x, "_")), stimStrs, "uni", false)', "UniformOutput", false)));
        comparePool(groupN).Odd_Std_Index = find(cell2mat(cellfun(@(x) strcmpi(x(2), StdStr)&~strcmpi(x(1), "ManyStd"), cellfun(@(x) string(strsplit(x, "_")), stimStrs, "uni", false)', "UniformOutput", false)));
    end
end

%% ICA
% align to certain duration
ICPATH = strrep(FIGPATH, "Figures", "ICA");
mkdir(ICPATH);
ICAName = strcat(ICPATH, "comp.mat");
trialsECOG_MergeTemp = trialsECOG_Merge;

if ~exist(ICAName, "file")
    [comp, ICs, FigTopoICA, FigWave, FigIC] = ICA_Population(trialsECOG_MergeTemp, fs, Window);
    compT = comp;
    compT.topo(:, ~ismember(1:size(compT.topo, 2), ICs)) = 0;
    trialsECOG_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_MergeTemp, "UniformOutput", false);
    print(FigWave(2), strcat(ICPATH, "_IC_Rescutction_", protStr), "-djpeg", "-r200");
    print(FigTopoICA, strcat(ICPATH, "_IC_Topo_", protStr), "-djpeg", "-r200");
    print(FigIC, strcat(ICPATH, "_IC_Raw_", protStr), "-djpeg", "-r200");
    close(FigTopoICA); close(FigWave); close(FigIC);
    save(ICAName, "compT", "comp", "ICs", "-mat");
else
    load(ICAName);
    trialsECOG_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_MergeTemp, "UniformOutput", false);
end

%% filter
trialsECOG_Merge_Filtered = ECOGFilter(trialsECOG_Merge, fhp2, flp2, fs);

%% lag
tSD = round(diff(Std_Dev_Onset(:, end-1:end), 1, 2) / 1000 * fs);
trialsECOG_Merge_Lag = cellfun(@(x, y) [zeros(size(x, 1), tSD(y)), x(:, 1:end-tSD(y))], trialsECOG_Merge, num2cell(vertcat(trialAll.devOrdr)), "UniformOutput", false);

%% process across diff devTypes
devType = unique([trialAll.devOrdr]);
% initialize
t = linspace(Window(1), Window(2), size(trialsECOG_Merge{1}, 2))';
for ch = 1 : 64
    cdrPlot(ch).(strcat(monkeyStr, "info")) = strcat("Ch", num2str(ch));
    cdrPlot(ch).(strcat(monkeyStr, "Wave")) = zeros(length(t), 2 * length(devType));
end
PMean = cell(length(MATPATH), length(devType));
chMean = cell(length(MATPATH), length(devType));
chMeanLag = cell(length(MATPATH), length(devType));
chMeanFilterd = cell(length(MATPATH), length(devType));
trialsECOGFilterd = cell(length(MATPATH), length(devType));
trialsECOGLag = cell(length(MATPATH), length(devType));

% process
for dIndex = devType
    tIndex = [trialAll.devOrdr] == dIndex;
    trials = trialAll(tIndex);
    trialsECOG = trialsECOG_Merge(tIndex);
    trialsECOGFilterd = trialsECOG_Merge_Filtered(tIndex);
    trialsECOGLag = trialsECOG_Merge_Lag(tIndex);

    % raw wave
    chMean{1, dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOG), 'UniformOutput', false));
    chStd = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOG), 'UniformOutput', false));

    % filter
    chMeanFilterd{1, dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOGFilterd), 'UniformOutput', false));
    chStdFilter = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOGFilterd), 'UniformOutput', false));

    % lag
    chMeanLag{1, dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOGLag), 'UniformOutput', false));
    chStdLag = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(trialsECOGLag), 'UniformOutput', false));

    % data for corelDraw plot
    for ch = 1 : size(chMean{1, dIndex}, 1)
        cdrPlot(ch).(strcat(monkeyStr, "Wave"))(:, 2 * dIndex - 1) = t';
        cdrPlot(ch).(strcat(monkeyStr, "Wave"))(:, 2 * dIndex) = chMean{1, dIndex}(ch, :)';
        cdrPlot(ch).(strcat(monkeyStr, "WaveFilted"))(:, 2 * dIndex - 1) = t';
        cdrPlot(ch).(strcat(monkeyStr, "WaveFilted"))(:, 2 * dIndex) = chMeanFilterd{1, dIndex}(ch, :)';
        cdrPlot(ch).(strcat(monkeyStr, "WaveLag"))(:, 2 * dIndex - 1) = t';
        cdrPlot(ch).(strcat(monkeyStr, "WaveLag"))(:, 2 * dIndex) = chMeanLag{1, dIndex}(ch, :)';
    end


end

if ~exist(FIGPATH, "dir")
    mkdir(FIGPATH);
end
%% comparison between devTypes
legendStr = ["Odd Dev", "Odd Std", "ManyStd Dev"];
for gIndex = 1 : length(comparePool)

    parseStruct(comparePool, gIndex);
    % Odd_Dev
    group(1).chMean = chMean{1, Odd_Dev_Index};
    group(1).color = colors(1);
    % Odd_Std
    group(2).chMean = chMeanLag{1, Odd_Std_Index};
    group(2).color = colors(2);
    % ManyStd_Dev
    group(3).chMean = chMean{1, ManyStd_Dev_Index};
    group(3).color = colors(3);

    % plot
    FigGroup(gIndex) = plotRawWaveMulti_SPR(group, Window, DevStr);
    addLegend2Fig(FigGroup(gIndex), legendStr);
end
scaleAxes(FigGroup, "x", DevPlotWin);
scaleAxes(FigGroup, "y", "on");

for gIndex = 1 : length(FigGroup)
    parseStruct(comparePool, gIndex);
    % print figure
    print(FigGroup(gIndex), strcat(FIGPATH, DevStr, "_", AREANAME), "-djpeg", "-r200");
    close(FigGroup(gIndex));
end




ResName = strcat(FIGPATH, "cdrPlot_", AREANAME, ".mat");
save(ResName, "cdrPlot", "chMean", "Protocol", "-mat");



% %% Multiple comparison
% channels = 1 : size(trialsECOG_Merge{1}, 1);
% t = linspace(Window(1), Window(2), size(trialsECOG_Merge{1}, 2))';
% compareStr = repmat(["Odd-Dev vs Odd-Std"; "Odd-Dev vs Manystd-Dev"], length(comparePool), 1);
% pools = cell2mat(cellfun(@(x,y,z) [x, y; x z], {comparePool.Odd_Dev_Index}', {comparePool.Odd_Std_Index}', {comparePool.ManyStd_Dev_Index}', "UniformOutput", false));
% ResName = strcat(FIGPATH, "CBPT_", AREANAME, ".mat");
% if exist(ResName, "file")
%     load(ResName);
% end
%
% for gIndex = 1 : size(pools, 1)
%     data = [];
%     pool = pools(gIndex, :);
%     if ~exist(ResName, "file")
%         for dIndex = 1:length(pool)
%             if contains(compareStr(dIndex), "Odd-Std", "IgnoreCase", true)
%                 temp = trialsECOG_Merge_Lag([trialAll.devOrdr] == devType(pool(dIndex)));
%             else
%                 temp = trialsECOG_Merge([trialAll.devOrdr] == devType(pool(dIndex)));
%             end
%             % time 1*nSample
%             data(dIndex).time = t' / 1000;
%             % label nCh*1 cell
%             data(dIndex).label = cellfun(@(x) num2str(x), num2cell(channels)', 'UniformOutput', false);
%             % trial nTrial*nCh*nSample
%             data(dIndex).trial = cell2mat(cellfun(@(x) permute(x, [3, 1, 2]), temp, "UniformOutput", false));
%             % trialinfo nTrial*1
%             data(dIndex).trialinfo = repmat(dIndex, [length(temp), 1]);
%         end
%         config.alpha = 0.04;
%         stat = CBPT(data);
%         CBPTRez(gIndex).Info = strcat(comparePool(ceil(gIndex/2)).DevStr, " | | ", compareStr(gIndex));
%         CBPTRez(gIndex).stat = stat;
%     else
%         stat = CBPTRez(gIndex).stat;
%     end
%
%
%     p = stat.stat;
%     mask = stat.mask;
%     V0 = p .* mask;
%     %     V0 = p;
%     windowSortCh = [0, 200];
%     tIdx = fix((windowSortCh(1) - Window(1)) / 1000 * fs) + 1:fix((windowSortCh(2) - Window(1)) / 1000 * fs);
%     [~, chIdx] = sort(sum(V0(:, tIdx), 2), 'descend');
%     V = V0(chIdx, :);
%
%     figure;
%     maximizeFig(gcf);
%     mSubplot(gcf, 1, 1, 1, 1, [0, 0, 0, 0], [0.03, 0.01, 0.06, 0.03]);
%     imagesc("XData", t, "YData", channels, "CData", V);
%     xlim(DevPlotWin);
%     ylim([0.5, 64.5]);
%     yticks(channels);
%     yticklabels(num2str(channels(chIdx)'));
%     cm = colormap('jet');
%     cm(127:129, :) = repmat([1 1 1], [3, 1]);
%     colormap(cm);
%     title(strcat("t-value of ", CBPTRez(gIndex).Info));
%     ylabel('Ranked channels');
%     xlabel('Time (ms)');
%     cb = colorbar;
%     cb.Label.String = '\bf{{\it{T}}-value}';
%     cb.Label.Interpreter = 'latex';
%     cb.Label.FontSize = 12;
%     cb.Label.Position = [2.5, 0];
%     cb.Label.Rotation = -90;
%     cRange = scaleAxes("c", [], [], "max");
%     if any(unique(mask(:, t > DevPlotWin(1) & t < DevPlotWin(2))))
%         print(gcf, strcat(FIGPATH, comparePool(ceil(gIndex/2)).DevStr, "_", compareStr(gIndex), "_CBPT_", AREANAME), "-djpeg", "-r200");
%     end
%     drawnow;
% end
% save(ResName, "CBPTRez", "-mat");
