    %% plot single wave
    devType = unique([trialAll.devOrdr]);
t = linspace(Window(1), Window(2), diff(Window) /1000 * fs + 1)';
    for dIndex = 1 : length(devType)
        singleStim.chMean = chMean{dIndex}; singleStim.color = colors(dIndex);
        FigWave(dIndex) = plotRawWaveMulti_SPR(singleStim, Window, stimStrs(dIndex), [8, 8]);
    end
    setAxes(FigWave, 'yticklabel', '');
    setAxes(FigWave, 'xticklabel', '');
    setAxes(FigWave, 'visible', 'off');
    setLine(FigWave, "YData", [-yScale(mIndex) yScale(mIndex)], "LineStyle", "--");
    pause(1);
    set(FigWave, "outerposition", [300, 100, 800, 670]);
    scaleAxes(FigWave, "x", plotWin);
    scaleAxes(FigWave, "y", [-yScale(mIndex) yScale(mIndex)]);
    if exist("lines", "var")
        addLines2Axes(FigWave, lines);
    end
    plotLayout(FigWave, params.posIndex + 2 * (mIndex - 1), 0.3);
    for dIndex = 1 : length(devType)
        print(FigWave(dIndex), strcat(FIGPATH,  stimStrs(dIndex), "_CRI_Wave"), "-djpeg", "-r200");
    end

    % whole wave
    if plotWhole
        for dIndex = 1 : length(devType)
            singleStim.chMean = chMean{dIndex}; singleStim.color = colors(dIndex);
            FigWave_Whole(dIndex) = plotRawWaveMulti_SPR(singleStim, Window, stimStr(1), [8, 8]);
        end
        setAxes(FigWave_Whole, 'yticklabel', '');
        setAxes(FigWave_Whole, 'xticklabel', '');
        setAxes(FigWave_Whole, 'visible', 'off');
        setLine(FigWave_Whole, "YData", [-yScale(mIndex) yScale(mIndex)], "LineStyle", "--");

        pause(1);
        set(FigWave_Whole, "outerposition", [300, 100, 800, 670]);
        
        plotLayout(FigWave_Whole, params.posIndex + 2 * (mIndex - 1), 0.3);
        for dIndex = 1 : length(devType)
            print(FigWave_Whole(dIndex), strcat(FIGPATH, stimStrs(dIndex), "_CRI_Wave_Whole"), "-djpeg", "-r200");
        end
    end

    close all