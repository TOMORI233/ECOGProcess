ResName = strcat(FIGPATH, "cdrPlot_", AREANAME, ".mat");
try
    save(ResName, "cdrPlot", "chMean", "chMeanS1", "PMean", "PMean_Base", "fftPValue", "correspFreq", "Protocol", "trialAll", "FIGPATH","CRI", "compare", "stimStrs", "-mat");
catch
    save(ResName,"FIGPATH","cdrPlot", "chMean", "Protocol", "stimStrs", "trialAll", "CRI", "compare", "-mat");
end