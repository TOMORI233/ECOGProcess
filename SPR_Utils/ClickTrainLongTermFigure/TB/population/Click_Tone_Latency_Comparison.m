clc; clear
%% peak latency
selectCh = 33;
sigma = 5;
smthBin = 10;
latencyRange = [30, 250];
sponWin = [-500, 0];

filepath = "E:\ECoG\corelDraw\ClickTrainLongTerm\Basic\Pop_Figure2_RegIrreg\R_minus_S_devide_R_plus_S\XX\cdrPlot_AC.mat";
clickData = load(filepath);
filepath = "E:\ECoG\corelDraw\ClickTrainLongTerm\Basic\Pop_Sfigure2_Tone\R_minus_S_devide_R_plus_S\XX\cdrPlot_AC.mat";
toneData = load(filepath);

if contains(filepath, "CC")
    NP = 1;
    latencyRange1 = [44, 250];
    latencyRange2 = [30, 250];
elseif contains(filepath, "XX")
    NP = 1;
    latencyRange1 = [42, 250];
    latencyRange2 = [30, 250];
end


    latencys.Click = Latency_Resample(clickData.chMean(1), [clickData.cdrPlot(1).Wave(1, 1), clickData.cdrPlot(1).Wave(end, 1)], NP*ones(size(clickData.chMean{1}, 1), 1), latencyRange1, sponWin, sigma, smthBin, "Method","AVL_Single");
    latencys.Tone = Latency_Resample(toneData.chMean(3), [toneData.cdrPlot(1).Wave(1, 1), toneData.cdrPlot(1).Wave(end, 1)], NP*ones(size(toneData.chMean{1}, 1), 1), latencyRange2, sponWin, sigma, smthBin, "Method","AVL_Single");

figure
maximizeFig;
for aIndex = 1 : 64
CR_Plot_Click = clickData.cdrPlot(aIndex).Wave; % change response
CR_Plot_Tone = toneData.cdrPlot(aIndex).Wave; % change response

smth_CR_Click = cell2mat(rowFcn(@(x) mGaussionFilter(x, sigma, smthBin), CR_Plot_Click(:,2:2:end)', "UniformOutput", false));
smth_CR_Tone = cell2mat(rowFcn(@(x) mGaussionFilter(x, sigma, smthBin), CR_Plot_Tone(:,2:2:end)', "UniformOutput", false));
timeCR_Click = CR_Plot_Click(:,1:2:end)';
timeCR_Tone = CR_Plot_Tone(:,1:2:end)';


mSubplot(8, 8, aIndex);

plot(timeCR_Click(1, :), smth_CR_Click(1, :), "r-"); hold on
plot([latencys.Click(aIndex), latencys.Click(aIndex)], [-30, 30], "Color", "r", "LineStyle", "--"); hold on
% plot(timeCR(2, :), smth_CR(2, :), "b-"); hold on
plot(timeCR_Tone(1, :), smth_CR_Tone(1, :), "b-"); hold on
plot([latencys.Tone(aIndex), latencys.Tone(aIndex)], [-30, 30], "Color", "b", "LineStyle", "--"); hold on
% plot(timeOR(4, :), smth_OR(4, :), "b-"); hold on
xlim([0, 500]);
title(['Click=', num2str(latencys.Click(aIndex)), 'ms, Tone=', num2str(latencys.Tone(aIndex))]);
end

scaleAxes("y", [-30, 30])