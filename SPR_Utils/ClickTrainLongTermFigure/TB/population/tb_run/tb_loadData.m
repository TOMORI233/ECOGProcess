    %% load data
    disp("loading data...");
    tic
    if ~exist(strcat(FIGPATH, "PopulationData.mat"), "file")
        [trialsECOG_Merge, trialsECOG_S1_Merge , ~, ~, trialAll, badCHs] = mergeECOGPreprocess(MATPATH{mIndex}, AREANAME);
        save(strcat(FIGPATH, "PopulationData.mat"), "trialsECOG_S1_Merge", "trialsECOG_Merge", "trialAll", "badCHs");
    else
        load(strcat(FIGPATH, "PopulationData.mat"));
    end


    if exist(strcat(FIGPATH, "cdrPlot_AC.mat"), "file")
        load(strcat(FIGPATH, "cdrPlot_AC.mat"));
    end
    badCHs = [];
    toc
