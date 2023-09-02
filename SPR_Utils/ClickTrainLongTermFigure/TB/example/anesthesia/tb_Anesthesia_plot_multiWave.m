%% plot compare wave ( for diff-ICI/ICI-Thr/Duration/Variance

FigWave = plotRawWaveMulti_SPR(RegRatio, Window, titleStr, [8, 8]);
scaleAxes(FigWave, "y", [-yScale(mIndex) yScale(mIndex)]);
setAxes(FigWave, 'yticklabel', '');
setAxes(FigWave, 'xticklabel', '');
setAxes(FigWave, 'visible', 'off');
setLine(FigWave, "YData", [-yScale(mIndex) yScale(mIndex)], "LineStyle", "--");
scaleAxes(FigWave, "x", plotWin);
pause(1);
% set(FigWave, "outerposition", [300, 100, 800, 670]);
plotLayout(FigWave, params.posIndex + 2 * (mIndex - 1), 0.3);
if filtFlag
    print(FigWave, strcat(FIGPATH, "Filter_BaseICI_CRI_Wave_Compare"), "-djpeg", "-r200");
elseif boostrapFlag
    print(FigWave, strcat(FIGPATH, "Boostrap_BaseICI_CRI_Wave_Compare"), "-djpeg", "-r200");
else
    print(FigWave, strcat(FIGPATH, "BaseICI_CRI_Wave_Compare"), "-djpeg", "-r200");
end
close all
% %% ratio
% FigWave = plotRawWaveMulti_SPR(RegRatio([1, 3]), Window, titleStr, [8, 8]);
% scaleAxes(FigWave, "y", [-yScale(mIndex) yScale(mIndex)]);
% setAxes(FigWave, 'yticklabel', '');
% setAxes(FigWave, 'xticklabel', '');
% setAxes(FigWave, 'visible', 'off');
% setLine(FigWave, "YData", [-yScale(mIndex) yScale(mIndex)], "LineStyle", "--");
% scaleAxes(FigWave, "x", plotWin);
% pause(1);
% % set(FigWave, "outerposition", [300, 100, 800, 670]);
% plotLayout(FigWave, params.posIndex + 2 * (mIndex - 1), 0.3);
% 
% if filtFlag
%     print(FigWave, strcat(FIGPATH, dataSelect, "_Filter_Ratio_CRI_Wave_Compare"), "-djpeg", "-r200");
% else
%     print(FigWave, strcat(FIGPATH, dataSelect, "_Ratio_CRI_Wave_Compare"), "-djpeg", "-r200");
% end

% %% Tone
% FigWave = plotRawWaveMulti_SPR(RegRatio([1, 3, 4]), Window, titleStr, [8, 8]);
% scaleAxes(FigWave, "y", [-yScale(mIndex) yScale(mIndex)]);
% setAxes(FigWave, 'yticklabel', '');
% setAxes(FigWave, 'xticklabel', '');
% setAxes(FigWave, 'visible', 'off');
% setLine(FigWave, "YData", [-yScale(mIndex) yScale(mIndex)], "LineStyle", "--");
% scaleAxes(FigWave, "x", plotWin);
% pause(1);
% % set(FigWave, "outerposition", [300, 100, 800, 670]);
% plotLayout(FigWave, params.posIndex + 2 * (mIndex - 1), 0.3);
% if filtFlag
%     print(FigWave, strcat(FIGPATH, dataSelect, "_Filter_Tone_CRI_Wave_Compare"), "-djpeg", "-r200");
% else
%     print(FigWave, strcat(FIGPATH, dataSelect, "_Tone_CRI_Wave_Compare"), "-djpeg", "-r200");
% end
close all