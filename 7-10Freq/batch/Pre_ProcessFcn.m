function Pre_ProcessFcn(params)
close all;
parseStruct(params);
window = [-2000, 1000];

mkdir(PrePATH);

%% AC
if ~exist([PrePATH, 'AC_excludeIdx.mat'], "file")
    params.posIndex = 1; % 1-AC, 2-PFC
    excludeIdx = [];
    MATPATHs = [];

    for index = 1:length(DATESTRs)
        MATPATHs{index, 1} = [ROOTPATH, DATESTRs{index}, '\', DATESTRs{index}, '_AC.mat'];
    end

    for mIndex = 1:length(MATPATHs)
        [trialAll_temp, ECOGDataset] = ECOGPreprocess(MATPATHs{mIndex}, params);
        idx = ~cellfun(@(x) isequal(x, true), {trialAll_temp.interrupt});
        [excludeIdx{mIndex}, badChIdx{mIndex}] = excludeTrials(selectEcog(ECOGDataset, trialAll_temp(idx), "dev onset", window), ...
                                                               "userDefineOpt", "off");
    end

    mSave([PrePATH, 'AC_excludeIdx'], "excludeIdx", "badChIdx");
else
    disp('File already exists. Skip excluding trials in AC recording.');
end

%% PFC
if ~exist([PrePATH, 'PFC_excludeIdx.mat'], "file")
    params.posIndex = 2; % 1-AC, 2-PFC
    excludeIdx = [];
    MATPATHs = [];

    for index = 1:length(DATESTRs)
        MATPATHs{index, 1} = [ROOTPATH, DATESTRs{index}, '\', DATESTRs{index}, '_PFC.mat'];
    end

    for mIndex = 1:length(MATPATHs)
        [trialAll_temp, ECOGDataset] = ECOGPreprocess(MATPATHs{mIndex}, params);
        idx = ~cellfun(@(x) isequal(x, true), {trialAll_temp.interrupt});
        [excludeIdx{mIndex}, badChIdx{mIndex}] = excludeTrials(selectEcog(ECOGDataset, trialAll_temp(idx), "dev onset", window), ...
                                                               "userDefineOpt", "off");
    end

    mSave([PrePATH, 'PFC_excludeIdx'], "excludeIdx", "badChIdx");
else
    disp('File already exists. Skip excluding trials in PFC recording.');
end