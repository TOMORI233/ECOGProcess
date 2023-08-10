    %% plot compare wave ( for diff-ICI/ICI-Thr/Duration/Variance

    FigWave = plotRawWaveMulti_SPR(RegRatio, Window, titleStr, [8, 8]);
    scaleAxes(FigWave, "y", [-yScale(mIndex) yScale(mIndex)]);
    setAxes(FigWave, 'yticklabel', '');
    setAxes(FigWave, 'xticklabel', '');
    setAxes(FigWave, 'visible', 'off');
    setLine(FigWave, "YData", [-yScale(mIndex) yScale(mIndex)], "LineStyle", "--");
    scaleAxes(FigWave, "x", plotWin);
    pause(1);
    set(FigWave, "outerposition", [300, 100, 800, 670]);
    plotLayout(FigWave, params.posIndex + 2 * (mIndex - 1), 0.3);
    print(FigWave, strcat(FIGPATH, Protocol, "_CRI_Wave_Compare"), "-djpeg", "-r200");
