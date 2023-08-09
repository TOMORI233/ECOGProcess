ResName = strcat(FIGPATH, "cdrPlot_", AREANAME, ".mat");
if contains(Protocol, ["Add_on_Annoying_BaseICI", "Add_on_Reword_BaseICI", "Add_on_Control_BaseICI"])
    save(ResName,"FIGPATH","cdrPlot", "chMean", "compare", "CRI", "ORI", "Protocol", "S1H", "stimStrs", "trialAll", "-mat");
else
    try
        save(ResName,"FIGPATH","cdrPlot", "chMean", "compare", "CRI", "ORI", "CRI_Boot", "ORI_Boot", "Protocol", "latency", "latencySingle", "S1H", "sigma", "smthBin", "stimStrs", "trialAll", "-mat");
    catch
        if exist("CRI_Boot", "var")
            save(ResName,"FIGPATH","cdrPlot", "chMean", "compare", "CRI", "ORI", "CRI_Boot", "ORI_Boot", "Protocol", "latency", "S1H", "sigma", "smthBin", "stimStrs", "trialAll", "-mat");
        else
            save(ResName,"FIGPATH","cdrPlot", "chMean", "compare", "CRI", "ORI", "Protocol", "latency", "S1H", "sigma", "smthBin", "stimStrs", "trialAll", "-mat");
        end
    end

end