    ResName = strcat(FIGPATH, "cdrPlot_", AREANAME, ".mat");
    try
    save(ResName,"FIGPATH","cdrPlot", "chMean", "compare", "CRI", "ORI", "CRI_Boot", "ORI_Boot", "Protocol", "latency", "latencySingle", "S1H", "sigma", "smthBin", "stimStrs", "trialAll", "-mat");
    catch
        save(ResName,"FIGPATH","cdrPlot", "chMean", "compare", "CRI", "ORI", "CRI_Boot", "ORI_Boot", "Protocol", "latency", "S1H", "sigma", "smthBin", "stimStrs", "trialAll", "-mat");
    end