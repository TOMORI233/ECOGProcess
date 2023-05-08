run("trialSelect.m");
trialsToICA = trialTypes.All;
ICAName = strcat(ICAPATH, "comp_", DateStr, "_", AREANAME, ".mat");

if ~exist(ICAName, "file")
    for mIndex = 1 : length(trialsToICA)
        FIGPATH =  strcat(ROOTPATH, DateStr, "\ICA\", trialsToICA(mIndex), "\");
        eval("[~, compTemp, FigICAWave, FigTopo] = toDoICA(ECOGDataset, ", trialsToICA(mIndex), ", 500);");
        print(FigICAWave, strcat(FIGPATH, AREANAME, "_ICA_Wave_", DateStr), "-djpeg", "-r200");
        print(FigTopo, strcat(FIGPATH, AREANAME, "_ICA_Topo_",  DateStr), "-djpeg", "-r200");
        comp.(trialsToICA(mIndex)) = compTemp;
    end
        save(ICAName, "comp", "-mat");
else
    load(ICAName);
end

clear(trialsToICA);

