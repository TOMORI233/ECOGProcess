clc; clear


filepath = "E:\ECoG\corelDraw\ClickTrainLongTerm\Basic\Pop_Figure2_RegIrreg\R_minus_S_devide_R_plus_S\XX\cdrPlot_AC.mat";
load(filepath);
run("CTLconfig.m");

%% peak latency
selectCh = 33;
sigma = 5;
smthBin = 10;
latencyRange = [20, 250];
sponWin = [-500, 0];


if contains(filepath, "CC")
    NP = 1;
    latencyRange1 = [44, 250];
    latencyRange2 = [20, 250];
elseif contains(filepath, "XX")
    NP = 1;
    latencyRange1 = [42, 250];
    latencyRange2 = [20, 250];
end


    latencys.CR = Latency_Resample(chMean(1), [cdrPlot(1).Wave(1, 1), cdrPlot(1).Wave(end, 1)], NP*ones(size(chMean{1}, 1), 1), latencyRange1, sponWin, sigma, smthBin, "Method","AVL_Single");
    latencys.OR = Latency_Resample(chMean(1), [cdrPlot(1).Wave(1, 1), cdrPlot(1).Wave(end, 1)] + S1Duration(1), NP*ones(size(chMean{1}, 1), 1), latencyRange2, sponWin, sigma, smthBin, "Method","AVL_Single");

figure
maximizeFig;
for aIndex = 1 : 64
CR_Plot_CR = cdrPlot(aIndex).Wave; % change response
CR_Plot_OR = cdrPlot(aIndex).Wave; % change response

smth_CR = cell2mat(rowFcn(@(x) mGaussionFilter(x, sigma, smthBin), CR_Plot_CR(:,2:2:end)', "UniformOutput", false));
smth_OR = cell2mat(rowFcn(@(x) mGaussionFilter(x, sigma, smthBin), CR_Plot_OR(:,2:2:end)', "UniformOutput", false));
timeCR = CR_Plot_CR(:,1:2:end)';
timeOR = CR_Plot_OR(:,1:2:end)' + S1Duration(1);


mSubplot(8, 8, aIndex);

plot(timeCR(1, :), smth_CR(1, :), "r-"); hold on
plot([latencys.CR(aIndex), latencys.CR(aIndex)], [-30, 30], "Color", "r", "LineStyle", "--"); hold on
plot(timeOR(1, :), smth_OR(1, :), "b-"); hold on
plot([latencys.OR(aIndex), latencys.OR(aIndex)], [-30, 30], "Color", "b", "LineStyle", "--"); hold on
xlim([0, 500]);
title(['CR =', num2str(latencys.CR(aIndex)), 'ms, OR =', num2str(latencys.OR(aIndex))]);
end

scaleAxes("y", [-30, 30])