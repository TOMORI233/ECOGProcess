%% MMN
FigMMN = plotRawWaveMulti(chDataMMN, windowMMN, 'MMN');
plotLayout(FigMMN, (monkeyID - 1) * 2 + posIndex);
mPrint(FigMMN, [MONKEYPATH, AREANAME, '_PE_MMN0.jpg'], "-djpeg", "-r600");
setAxes(FigMMN, "Visible", "off");
mPrint(FigMMN, [MONKEYPATH, AREANAME, '_PE_MMN.jpg'], "-djpeg", "-r600");

%% MMN CBPT
pMMN = statMMN.stat;
maskMMN = statMMN.mask;
V0_MMN = pMMN .* maskMMN;
windowSortCh = windowMMN;
tIdx = fix((windowSortCh(1) - windowMMN(1)) / 1000 * fs) + 1:fix((windowSortCh(2) - windowMMN(1)) / 1000 * fs);
[rankVs, chIdxMMN] = sort(sum(maskMMN(:, tIdx), 2), 'descend');
rankVsTemp = sort(sum(abs(V0_MMN(:, tIdx)), 2), 'descend');
rankV = unique(rankVs);
rankV = rankV(arrayfun(@(x) length(rankVs(rankVs == x)) > 1, rankV));
for index = 1:length(rankV)
    chIdxTemp = chIdxMMN(rankVs == rankV(index));
    chIdxMMN(rankVs == rankV(index)) = chIdxTemp(obtainArgoutN(@sort, 2, rankVsTemp(rankVs == rankV(index)), 'descend'));
end
V_MMN = V0_MMN(chIdxMMN, :);

FigCBPT_MMN = figure;
maximizeFig;
mSubplot(1, 1, 1, 1, [0, 0, 0, 0], [0.03, 0.01, 0.06, 0.03]);
imagesc("XData", tMMN, "YData", channels, "CData", V_MMN);
xlim([0, windowMMN(2)]);
ylim([0.5, 64.5]);
yticks(channels);
yticklabels(num2str(channels(chIdxMMN)'));
colormap(cmSig);
title('MMN | F-value of comparison among 4 deviant frequency ratio in all channels (significant)');
ylabel('Ranked channels');
xlabel('Time (ms)');
cb = colorbar;
cb.Label.String = '\bf{{\it{F}}-value}';
cb.Label.Interpreter = 'latex';
cb.Label.FontSize = 12;
cb.Label.Position = [2.5, 0];
cb.Label.Rotation = -90;
scaleAxes("c", "symOpts", "max");
mPrint(FigCBPT_MMN, [MONKEYPATH, AREANAME, '_PE_MMN_CBPT.jpg'], "-djpeg", "-r600");