%% Plot raw wave
FigDM0 = plotRawWaveMulti(chData0, windowDM, ['C', num2str(length(resultC)), 'W', num2str(length(resultW))]);
scaleAxes(FigDM0, "x", [0, windowDM(2)]);
% setAxes(FigDM0, "visible", "off");
plotLayout(FigDM0, (monkeyID - 1) * 2 + posIndex, 0.4);
mPrint(FigDM0, [MONKEYPATH, AREANAME, '_DM_RawWave.jpg'], "-djpeg", "-r600");

%% Plot z-scored wave
FigDM = plotRawWaveMulti(chData, windowDM, ['C', num2str(length(resultC)), 'W', num2str(length(resultW))]);
scaleAxes(FigDM, "y", "symOpts", "max");
scaleAxes(FigDM, "x", [0, windowDM(2)]);
setAxes(FigDM, "visible", "off");
plotLayout(FigDM, (monkeyID - 1) * 2 + posIndex, 0.4);
mPrint(FigDM, [MONKEYPATH, AREANAME, '_DM_ZscoreWave.jpg'], "-djpeg", "-r600");

%% Plot CBPT res
p = stat.stat;
mask = stat.mask;
V0 = p .* mask;
windowSortCh = [0, 400];
tIdx = fix((windowSortCh(1) - windowDM(1)) / 1000 * fs) + 1:fix((windowSortCh(2) - windowDM(1)) / 1000 * fs);
[rankVs, chIdx] = sort(sum(mask(:, tIdx), 2), 'descend');
rankVsTemp = sort(sum(abs(V0(:, tIdx)), 2), 'descend');
rankV = unique(rankVs);
rankV = rankV(arrayfun(@(x) length(rankVs(rankVs == x)) > 1, rankV));
for index = 1:length(rankV)
    chIdxTemp = chIdx(rankVs == rankV(index));
    chIdx(rankVs == rankV(index)) = chIdxTemp(obtainArgoutN(@sort, 2, rankVsTemp(rankVs == rankV(index)), 'descend'));
end
V = V0(chIdx, :);

FigCBPT = figure;
maximizeFig(gcf);
mSubplot(gcf, 1, 1, 1, 1, [0, 0, 0, 0], [0.03, 0.01, 0.06, 0.03]);
imagesc("XData", t, "YData", channels, "CData", V);
xlim([0, windowDM(2)]);
ylim([0.5, 64.5]);
yticks(channels);
yticklabels(num2str(channels(chIdx)'));
cm = colormap('jet');
cm(127:129, :) = repmat([1 1 1], [3, 1]);
colormap(cm);
title('t-value of comparison between correct and wrong trials in all channels (significant)');
ylabel('Ranked channels');
xlabel('Time (ms)');
cb = colorbar;
cb.Label.String = '\bf{{\it{t}}-value}';
cb.Label.Interpreter = 'latex';
cb.Label.FontSize = 12;
cb.Label.Position = [2.5, 0];
cb.Label.Rotation = -90;
scaleAxes("c", "symOpts", "max");
mPrint(FigCBPT, [MONKEYPATH, AREANAME, '_DM_CBPT.jpg'], "-djpeg", "-r600");