    %% compare and plot rawWave
    devType = unique([trialAll.devOrdr]);
    for  dIndex = 3 : length(devType)
        Successive(1).chMean = PMean{dIndex}; Successive(1).color = "r";
        Successive(2).chMean = PMean_Base{dIndex}; Successive(2).color = "k";
        % plot raw wave
        FigWave = plotRawWaveMulti_SPR(Successive, [0 fs/2], strcat(stimStrs(dIndex), " Oscillation"), [8, 8]);
        FigWave = deleteLine(FigWave, "LineStyle", "--");
        
        scaleAxes(FigWave, "x", [0.9, 1.1] * correspFreq(dIndex));
        try
            scaleAxes(FigWave, "y", "on");
        end
        %     setAxes(FigWave, "Xscale", "log");
        lines(1).X = correspFreq(dIndex); lines(1).color = "k";
        addLines2Axes(FigWave, lines);
        orderLine(FigWave, "LineStyle", "--", "bottom");
        setAxes(FigWave, 'yticklabel', '');
        setAxes(FigWave, 'xticklabel', '');
        setAxes(FigWave, 'visible', 'off');
%         setLine(FigWave, "YData", [-fftScale(FFTMethod, mIndex) fftScale(FFTMethod, mIndex)], "LineStyle", "--");
        pause(1);
        set(FigWave, "outerposition", [300, 100, 800, 670]);
        plotLayout(FigWave, params.posIndex + 2 * (mIndex - 1), 0.3);
        print(FigWave, strcat(FIGPATH, Protocol, "_FFT_", stimStrs(dIndex)), "-djpeg", "-r200");
        close(FigWave);
    end
