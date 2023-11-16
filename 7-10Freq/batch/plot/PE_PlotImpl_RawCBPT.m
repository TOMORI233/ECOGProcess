%% Raw wave
t = linspace(windowPE(1), windowPE(2), size(trialsECOG{1}, 2))';
FigPE = plotRawWaveMulti(chData(2:end), windowPE);
scaleAxes(FigPE, "x", [0, windowPE(2)]);
scaleAxes(FigPE, "y", "on", "uiOpt", "show");
setAxes(FigPE, "visible", "off");
plotLayout(FigPE, (monkeyID - 1) * 2 + posIndex, 0.4);
drawnow;
mPrint(FigPE, [MONKEYPATH, AREANAME, '_PE_RawWave.jpg'], "-djpeg", "-r600");

%% Raw wave CBPT
p = stat.stat;
mask = stat.mask;
V0 = p .* mask;
windowSortCh = [0, 500];
tIdx = fix((windowSortCh(1) - windowPE(1)) / 1000 * fs) + 1:fix((windowSortCh(2) - windowPE(1)) / 1000 * fs);
[rankVs, chIdx] = sort(sum(mask(:, tIdx), 2), 'descend');
rankVsTemp = sort(sum(abs(V0(:, tIdx)), 2), 'descend');
rankV = unique(rankVs);
rankV = rankV(arrayfun(@(x) length(rankVs(rankVs == x)) > 1, rankV));
for index = 1:length(rankV)
    chIdxTemp = chIdx(rankVs == rankV(index));
    chIdx(rankVs == rankV(index)) = chIdxTemp(obtainArgoutN(@sort, 2, rankVsTemp(rankVs == rankV(index)), 'descend'));
end
V = V0(chIdx, :);

FigMCP = figure;
maximizeFig;
mSubplot(1, 1, 1, 1, [0, 0, 0, 0], [0.03, 0.01, 0.06, 0.03]);
imagesc("XData", t, "YData", channels, "CData", V);
xlim([0, windowPE(2)]);
ylim([0.5, 64.5]);
yticks(channels);
yticklabels(num2str(channels(chIdx)'));
cmSig = colormap('jet');
cmSig(1:129, :) = repmat([1 1 1], [129, 1]);
colormap(cmSig);
title('Raw | F-value of comparison among 4 deviant frequency ratio in all channels (significant)');
ylabel('Ranked channels');
xlabel('Time (ms)');
cb = colorbar;
cb.Label.String = '\bf{{\it{F}}-value}';
cb.Label.Interpreter = 'latex';
cb.Label.FontSize = 12;
cb.Label.Position = [2.5, 0];
cb.Label.Rotation = -90;
scaleAxes("c", "symOpts", "max");
mPrint(FigMCP, [MONKEYPATH, AREANAME, '_PE_CBPT.jpg'], "-djpeg", "-r600");
% mPrint(FigMCP, [MONKEYPATH, AREANAME, '_PE_FDR.jpg'], "-djpeg", "-r600");