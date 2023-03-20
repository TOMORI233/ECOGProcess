    %% compare and plot rawWave
    devType = unique([trialAll.devOrdr]);
    for  dIndex = 1 : length(devType)
        fftPValue(dIndex).info = stimStrs(dIndex);
        [H, P, FFT_Ratio] = waveFFTPower_pValue(trialsFFT{dIndex}, trialsFFT_Base{dIndex}, [ff{dIndex}, {ff_Base}], targetIdx(dIndex), 2, "ttest");
        fftPValue(dIndex).pValue = P;
        fftPValue(dIndex).H = H;
        fftPValue(dIndex).FFT_Ratio = FFT_Ratio';
    end