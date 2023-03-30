clc;
% load mat file
% [filename, filepath] = uigetfile(".mat", "select processed MAT FILE", "E:\ECoG\corelDraw\ClickTrainLongTerm\Basic");
% load(fullfile(filepath, filename));
run("CTLconfig.m");

%% peak latency
NP = 1;
selectCh = 33;
sigma = 5;
smthBin = 30;
latencyRange = [50, 250];
sponWin = [-500, 0];
% if contains(filepath, "Tone")
%     selectStim = 3;
% else
    selectStim = 4;
% end

% if contains(filepath, "CC")
%     CR_Plot = cdrPlot(selectCh).CCWave; % change response
% else
%     CR_Plot = cdrPlot(selectCh).XXWave; % change response
% end
CR_Plot = cdrPlot(selectCh).Wave; % change response
OR_Plot = CR_Plot;
OR_Plot(:, 1:2:end) = CR_Plot(:, 1:2:end)+S1Duration;

smth_CR = cell2mat(rowFcn(@(x) mGaussionFilter(x, sigma, smthBin), CR_Plot(:,2:2:end)', "UniformOutput", false));
smth_OR = cell2mat(rowFcn(@(x) mGaussionFilter(x, sigma, smthBin), OR_Plot(:,2:2:end)', "UniformOutput", false));
timeCR = CR_Plot(:,1:2:end)';
timeOR = OR_Plot(:,1:2:end)';
% if contains(filepath, "CC")
    latencys.CR = Latency_Resample(chMean(selectStim), [CR_Plot(1, 1), CR_Plot(end, 1)], NP*ones(size(chMean{1}, 1), 1), latencyRange, sponWin, sigma, smthBin, "Method","AVL_Single");
    latencys.OR = Latency_Resample(chMean(selectStim), [OR_Plot(1, 1), OR_Plot(end, 1)], NP*ones(size(chMean{1}, 1), 1), latencyRange, sponWin, sigma, smthBin, "Method","AVL_Single");
% else
%     latency.CR = Latency_Jackknife(chMean(selectStim), [CR_Plot(1, 1), CR_Plot(end, 1)], NP*ones(size(chMean{1}, 1), 1), latencyRange, sponWin, sigma, smthBin, "Method","ByTrials");
%     latency.OR = Latency_Jackknife(chMean(selectStim), [OR_Plot(1, 1), OR_Plot(end, 1)], NP*ones(size(chMean{1}, 1), 1), latencyRange, sponWin, sigma, smthBin, "Method","ByTrials");
% end
figure
plot(timeCR(1, :), smth_CR(1, :), "r-"); hold on
plot(timeCR(1, :), smth_CR(2, :), "b-"); hold on
% plot(timeOR(1, :), smth_OR(3, :), "r-"); hold on
% plot(timeOR(1, :), smth_OR(4, :), "b-"); hold on
xlim([0, 500]);

