function export256DataFcn(BLOCKPATH, RHDPATH, SAVEPATH, params, fd, startIdx, endIdx)
narginchk(6, 7);

if nargin < 6
    startIdx = 1;
end

if nargin < 7
    endIdx = length(BLOCKPATH);
end

Dates = string(cellfun(@(y) y(end-1), cellfun(@(x) string(split(x, '\')), BLOCKPATH, "UniformOutput", false), "UniformOutput", false));

for index = startIdx:endIdx
    temp = string(split(BLOCKPATH{index}, '\'));
    DateStr = temp(end - 1);
    block = temp(end);
    mkdir(fullfile(SAVEPATH, DateStr));

    % AC
    disp("Loading AC Data...");
    params.posIndex = 1;
    tic
    if isfield(params, "patch")
        [trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH{index}, params, "RHDPATH", RHDPATH{index}, "patch", params.patch);
    else
        [trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH{index}, params, "RHDPATH", RHDPATH{index});
    end
    ECOGDataset = ECOGResample(ECOGDataset, fd);
    disp("Saving...");
    if sum(contains(Dates, DateStr)) == 1
        save(strcat(SAVEPATH, DateStr, "\", DateStr, ".mat"), "ECOGDataset", "trialAll", "-mat", "-v7.3");
    else
        save(strcat(SAVEPATH, DateStr, "\", DateStr, ".mat", block), "ECOGDataset", "trialAll", "-mat", "-v7.3");
    end
    toc
    toc
end

end