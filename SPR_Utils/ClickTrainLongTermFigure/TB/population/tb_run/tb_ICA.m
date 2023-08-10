 %% ICA
    % align to certain duration
    
    ICAName = strcat(FIGPATH, "comp_", AREANAME, ".mat");

    trialsECOG_MergeTemp = trialsECOG_Merge;
    trialsECOG_S1_MergeTemp = trialsECOG_S1_Merge;
    channels = 1 : size(trialsECOG_Merge{1}, 1);

    if ~exist(ICAName, "file")
        chs2doICA = channels;
        chs2doICA(ismember(chs2doICA, badCHs)) = [];
        [comp, ICs, FigTopoICA, FigWave, FigIC] = ICA_Population(trialsECOG_MergeTemp, fs, Window, chs2doICA);
                temp = validateInput(['Input bad channel number (empty for default: ', num2str(badCHs'), '): '], @(x) validateattributes(x, {'numeric'}, {'2d', 'integer', 'positive'}));
                if ~isempty(temp)
                    badCHs = unique([badCHs; reshape(temp, [numel(temp), 1])]);
                end
        compT = comp;
        compT.topo(:, ~ismember(1:size(compT.topo, 2), ICs)) = 0;
        if length(chs2doICA) < length(channels)
            icaOpt = "on";
            trialsECOG_Merge = cellfun(@(x) x(chs2doICA, :), trialsECOG_Merge, "UniformOutput", false);
            trialsECOG_Merge = reconstructData(trialsECOG_Merge, comp, ICs);
            trialsECOG_Merge = cellfun(@(x) insertRows(x, channels(ismember(channels, badCHs) & ~ismember(channels, chs2doICA))), trialsECOG_Merge, "UniformOutput", false);

            trialsECOG_S1_Merge = cellfun(@(x) x(chs2doICA, :), trialsECOG_S1_Merge, "UniformOutput", false);
            trialsECOG_S1_Merge = reconstructData(trialsECOG_S1_Merge, comp, ICs);
            trialsECOG_S1_Merge = cellfun(@(x) insertRows(x, channels(ismember(channels, badCHs) & ~ismember(channels, chs2doICA))), trialsECOG_S1_Merge, "UniformOutput", false);
       

        else
            trialsECOG_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_MergeTemp, "UniformOutput", false);
            trialsECOG_S1_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_S1_MergeTemp, "UniformOutput", false);
        end
        mPrint(FigTopoICA, fullfile(FIGPATH, "ICA_Topo.jpg"));
        mPrint(FigIC, fullfile(FIGPATH, "ICA_IC.jpg"));
        mPrint(FigWave(1), fullfile(FIGPATH, "RawWave.jpg"));
        mPrint(FigWave(2), fullfile(FIGPATH, "Restructed Wave.jpg"));
        
        close([FigTopoICA, FigIC, FigWave]);
        
        save(ICAName, "compT", "comp", "ICs", "icaOpt", "chs2doICA", "badCHs", "-mat");
    else
        
        load(ICAName);
        
        if strcmpi(icaOpt, "on")
            trialsECOG_Merge = cellfun(@(x) x(chs2doICA, :), trialsECOG_Merge, "UniformOutput", false);
            trialsECOG_Merge = reconstructData(trialsECOG_Merge, comp, ICs);
            trialsECOG_Merge = cellfun(@(x) insertRows(x, channels(ismember(channels, badCHs) & ~ismember(channels, chs2doICA))), trialsECOG_Merge, "UniformOutput", false);
            trialsECOG_S1_Merge = cellfun(@(x) x(chs2doICA, :), trialsECOG_S1_Merge, "UniformOutput", false);
            trialsECOG_S1_Merge = reconstructData(trialsECOG_S1_Merge, comp, ICs);
            trialsECOG_S1_Merge = cellfun(@(x) insertRows(x, channels(ismember(channels, badCHs) & ~ismember(channels, chs2doICA))), trialsECOG_S1_Merge, "UniformOutput", false);
        else
            trialsECOG_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_MergeTemp, "UniformOutput", false);
            trialsECOG_S1_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_S1_MergeTemp, "UniformOutput", false);
        end
    end


clear trialsECOG_MergeTemp trialsECOG_S1_MergeTemp
