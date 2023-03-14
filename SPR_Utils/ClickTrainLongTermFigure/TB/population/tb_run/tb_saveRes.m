    ResName = strcat(FIGPATH, "cdrPlot_", AREANAME, ".mat");
    save(ResName, "cdrPlot", "compare", "chMean", "latency", "latencySingle", "CRI", "ORI", "badCHs", "Protocol", "sigma", "smthBin", "trialAll", "FIGPATH", "stimStrs", "S1H", "-mat");
