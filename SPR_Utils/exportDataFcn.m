function exportDataFcn(BLOCKPATH, SAVEPATH, params, fd, startIdx, endIdx)
narginchk(5, 6);

if nargin < 5
    startIdx = 1;
end

if nargin < 6
    endIdx = length(BLOCKPATH);
end

Dates = string(cellfun(@(y) y(end-1), cellfun(@(x) string(split(x, '\')), BLOCKPATH, "UniformOutput", false), "UniformOutput", false));

for index = startIdx:endIdx
    AREANAME = ["AC", "PFC"];
    temp = string(split(BLOCKPATH{index}, '\'));
    DateStr = temp(end - 1);
    block = temp(end);
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
    if sum(contains(Dates, DateStr)) == 1
        save(strcat(SAVEPATH, DateStr, "\", DateStr, "_", AREANAME(params.posIndex), ".mat"), "ECOGDataset", "trialAll", "-mat", "-v7.3");
    else
        save(strcat(SAVEPATH, DateStr, "\", DateStr, "-", block, "_", AREANAME(params.posIndex), ".mat"), "ECOGDataset", "trialAll", "-mat", "-v7.3");
    end
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
    if sum(contains(Dates, DateStr)) == 1
        save(strcat(SAVEPATH, DateStr, "\", DateStr, "_", AREANAME(params.posIndex), ".mat"), "ECOGDataset", "trialAll" , "fd", "-mat", "-v7.3");
    else
        save(strcat(SAVEPATH, DateStr, "\", DateStr, "-", block, "_", AREANAME(params.posIndex), ".mat"), "ECOGDataset", "trialAll", "fd", "-mat", "-v7.3");
    end
    toc
end

end