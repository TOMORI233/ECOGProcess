monkeyName = ["CC", "XX"];
mIndex = 1;
%% click train 30ms
clickPath = strcat("E:\ECoG\corelDraw\ClickTrainLongTerm\Basic\Pop_Figure6_Osci_Control\R_minus_S_devide_R_plus_S\", monkeyName(mIndex));
tonePath = strcat("E:\ECoG\corelDraw\ClickTrainLongTerm\Basic\Pop_Sfigure6_Osci_Tone\R_minus_S_devide_R_plus_S\", monkeyName(mIndex));
clickRes = load(strcat(clickPath, "\cdrPlot_AC.mat"));
toneRes = load(strcat(tonePath, "\cdrPlot_AC.mat"));

clickIdx = 5;
toneIdx = 3;
FFT(1).chMean = clickRes.PMean{clickIdx};
FFT(1).color = [0,0,0];
FFT(2).chMean = toneRes.PMean{toneIdx};
FFT(2).color = [1,0,0];
%% plot
ff = toneRes.ff;
FigFFT = plotRawWaveMulti_SPR(FFT, [ff(1), ff(end)], [], [8, 8]);
scaleAxes(FigFFT, "y", [0, 100]);
scaleAxes(FigFFT, "x", [30 40]);
% lines(1).X = 1000/30;
% addLines2Axes(FigFFT, lines);

setAxes(FigFFT, 'yticklabel', '');
setAxes(FigFFT, 'xticklabel', '');
setAxes(FigFFT, 'visible', 'off');
% setLine(FigFFT, "YData", [-yScale(mIndex) yScale(mIndex)], "LineStyle", "--");
pause(1);
set(FigFFT, "outerposition", [300, 100, 800, 670]);
plotLayout(FigFFT, 1 + 2 * (mIndex - 1), 0.3);
print(FigFFT, strcat(tonePath, "\ClickTrain_Tone_FFT_Compare"), "-djpeg", "-r300");
close all;

