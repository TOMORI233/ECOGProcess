    ResName = strcat(FIGPATH, "cdrPlot_", AREANAME, ".mat");
    save(ResName, "cdrPlot", "chMean", "chMeanS1", "PMean", "PMean_Base", "fftPValue", "correspFreq", "Protocol", "trialAll", "FIGPATH", "stimStrs", "-mat");
