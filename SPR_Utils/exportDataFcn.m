function exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, startIdx, endIdx)
    narginchk(5, 6);

    if nargin < 5
        startIdx = 1;
    end

    if nargin < 6
        endIdx = length(BLOCKPATH);
    end



    for index = startIdx:endIdx
        AREANAME = ["AC", "PFC"];
        temp = string(split(BLOCKPATH{index}, '\'));
        DateStr = temp(end - 1);
        mkdir(fullfile(SAVEPATH, DateStr));
        
        % AC
        disp("Loading AC Data...");
        params.posIndex = 1;
        tic
        if isfield(params, "patch")
            [trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH{index}, params, "patch", params.patch);
        else
            [trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH{index}, params);
        end
        ECOGDataset = ECOGResample(ECOGDataset, fd);
        disp("Saving...");
        save(strcat(SAVEPATH, DateStr, "\", DateStr, "_", AREANAME(params.posIndex), ".mat"), "ECOGDataset", "trialAll", "-mat", "-v7.3");
        toc
        
        % PFC
        disp("Loading PFC Data...");
        params.posIndex = 2;
        tic
        if isfield(params, "patch")
            [~, ECOGDataset] = ECOGPreprocess(BLOCKPATH{index}, params, "patch", params.patch);
        else
            [~, ECOGDataset] = ECOGPreprocess(BLOCKPATH{index}, params);
        end        
        ECOGDataset = ECOGResample(ECOGDataset, fd);
        disp("Saving...");
        save(strcat(SAVEPATH, DateStr, "\", DateStr, "_", AREANAME(params.posIndex), ".mat"), "ECOGDataset", "trialAll", "-mat", "-v7.3");
        toc
    end

end