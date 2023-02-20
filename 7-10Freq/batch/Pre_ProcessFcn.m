function Pre_ProcessFcn(params)
close all;
parseStruct(params);
window = [-2000, 1000];

mkdir(PrePATH);

%% AC
MATPATHsAC = [];
for index = 1:length(DATESTRs)
    MATPATHsAC{index, 1} = [ROOTPATH, DATESTRs{index}, '\', DATESTRs{index}, '_AC.mat'];
end

if ~exist([PrePATH, 'AC_excludeIdx.mat'], "file")
    params.posIndex = 1; % 1-AC, 2-PFC
    excludeIdx = [];

    for mIndex = 1:length(MATPATHsAC)
        [trialAll_temp, ECOGDataset] = ECOGPreprocess(MATPATHsAC{mIndex}, params);
        idx = ~cellfun(@(x) isequal(x, true), {trialAll_temp.interrupt});
        [excludeIdx{mIndex}, badChIdx{mIndex}] = excludeTrials(selectEcog(ECOGDataset, trialAll_temp(idx), "dev onset", window), ...
                                                               "userDefineOpt", userDefineOpt);
    end

    mSave([PrePATH, 'AC_excludeIdx'], "excludeIdx", "badChIdx");
else
    disp('File already exists. Skip excluding trials in AC recording.');
end

%% PFC
MATPATHsPFC = [];
for index = 1:length(DATESTRs)
    MATPATHsPFC{index, 1} = [ROOTPATH, DATESTRs{index}, '\', DATESTRs{index}, '_PFC.mat'];
end

if ~exist([PrePATH, 'PFC_excludeIdx.mat'], "file")
    params.posIndex = 2; % 1-AC, 2-PFC
    excludeIdx = [];

    for mIndex = 1:length(MATPATHsPFC)
        [trialAll_temp, ECOGDataset] = ECOGPreprocess(MATPATHsPFC{mIndex}, params);
        idx = ~cellfun(@(x) isequal(x, true), {trialAll_temp.interrupt});
        [excludeIdx{mIndex}, badChIdx{mIndex}] = excludeTrials(selectEcog(ECOGDataset, trialAll_temp(idx), "dev onset", window), ...
                                                               "userDefineOpt", userDefineOpt);
    end

    mSave([PrePATH, 'PFC_excludeIdx'], "excludeIdx", "badChIdx");
else
    disp('File already exists. Skip excluding trials in PFC recording.');
end

%% ICA
if strcmp(icaOpt, "on")
    idxAC = load([PrePATH, 'AC_excludeIdx']);
    idxPFC = load([PrePATH, 'PFC_excludeIdx']);
    excludeIdxAll = cellfun(@(x, y) [x, y], idxAC.excludeIdx, idxPFC.excludeIdx, "UniformOutput", false);

    % AC
    close all;
    if ~exist([PrePATH, 'AC_ICA.mat'], "file")
        trialsECOG = [];
        trialAll = [];
        badCHs = [];
        for mIndex = 1:length(MATPATHsAC)
            [trialAll_temp, ECOGDataset] = ECOGPreprocess(MATPATHsAC{mIndex}, params);
            idx = ~cellfun(@(x) isequal(x, true), {trialAll_temp.interrupt});
            trials = trialAll_temp(idx);
            trialsECOG_temp = selectEcog(ECOGDataset, trials, "dev onset", window);
            trials(excludeIdxAll{mIndex}) = [];
            trialsECOG_temp(excludeIdxAll{mIndex}) = [];
            trialAll = [trialAll; trials];
            trialsECOG = [trialsECOG; trialsECOG_temp];
            badCHs = [badCHs; idxAC.badChIdx{mIndex}];
        end
        badCHs = unique(badCHs);
        fs = ECOGDataset.fs;
        channels = ECOGDataset.channels;
        chs2doICA = channels;
        chs2doICA(ismember(chs2doICA, badCHs)) = [];
        [comp, ICs, FigTopoICA] = ICA_Population(trialsECOG, fs, window, chs2doICA);
        temp = validateInput(['Input bad channel number (empty for default: ', num2str(badCHs'), '): '], @(x) validateattributes(x, {'numeric'}, {'2d', 'integer', 'positive'}));
        if ~isempty(temp)
            badCHs = reshape(temp, [numel(temp), 1]);
        end
        mPrint(FigTopoICA, strcat(PrePATH, "AC_Topo_ICA"), "-djpeg", "-r400");
        mSave([PrePATH, 'AC_ICA.mat'], "comp", "ICs", "badCHs");
    else
        disp('File already exists. Skip ICA in AC recording.');
    end
    
    % PFC
    close all;
    if ~exist([PrePATH, 'PFC_ICA.mat'], "file")
        trialsECOG = [];
        trialAll = [];
        badCHs = [];
        for mIndex = 1:length(MATPATHsPFC)
            [trialAll_temp, ECOGDataset] = ECOGPreprocess(MATPATHsPFC{mIndex}, params);
            idx = ~cellfun(@(x) isequal(x, true), {trialAll_temp.interrupt});
            trials = trialAll_temp(idx);
            trialsECOG_temp = selectEcog(ECOGDataset, trials, "dev onset", window);
            trials(excludeIdxAll{mIndex}) = [];
            trialsECOG_temp(excludeIdxAll{mIndex}) = [];
            trialAll = [trialAll; trials];
            trialsECOG = [trialsECOG; trialsECOG_temp];
            badCHs = [badCHs; idxPFC.badChIdx{mIndex}];
        end
        badCHs = unique(badCHs);
        fs = ECOGDataset.fs;
        channels = ECOGDataset.channels;
        chs2doICA = channels;
        chs2doICA(ismember(chs2doICA, badCHs)) = [];
        [comp, ICs, FigTopoICA] = ICA_Population(trialsECOG, fs, window, chs2doICA);
        temp = validateInput(['Input bad channel number (empty for default: ', num2str(badCHs'), '): '], @(x) validateattributes(x, {'numeric'}, {'2d', 'integer', 'positive'}));
        if ~isempty(temp)
            badCHs = reshape(temp, [numel(temp), 1]);
        end
        mPrint(FigTopoICA, strcat(PrePATH, "PFC_Topo_ICA"), "-djpeg", "-r400");
        mSave([PrePATH, 'PFC_ICA.mat'], "comp", "ICs", "badCHs");
    else
        disp('File already exists. Skip ICA in PFC recording.');
    end

end