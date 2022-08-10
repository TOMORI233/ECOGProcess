clear all; clc
monkeyId = ["chouchou", "xiaoxiao"];
posStr = ["LAuC", "LPFC"];

paradigmKeyword = ["LongTerm4[^0]", "LongTerm8[^0]", "LongTerm20", "LongTerm40", "LongTerm80", "Insert", "RegInIrreg4o32", "LowHigh43444546" ,"ICIThr401234", "Var3", "offset", "Tone"];
% paradigmKeyword = "ICIThr401234"; %Insert, RegInIrreg4o32, LowHigh43444546, ICIThr401234, Var3, offset, Tone
paradigmStr = strrep(paradigmKeyword, '[^0]', '');
%     for pN = 1
for idIdx = 1 : 2
    rootPath = fullfile("E:\ECoG\matData", monkeyId(idIdx));
    for pN = 1 : length(paradigmStr)
        for pos = 1:2
            clearvars -except monkeyId posStr idIdx posIndex rootPath paradigmKeyword paradigmStr pN pos
            fs = 300; % Hz
            mergeData.channels = 1 : 64;
            mergeData.fs = fs;
            mergeData.name = posStr(pos);
            trialMerge = [];
            tMerge = 0;
            nMerge = 0;
            rootPath = fullfile("E:\ECoG\matData", monkeyId(idIdx));
            mergeSavePath = fullfile(rootPath, "mergeRaw", paradigmStr(pN));
            if ~exist(mergeSavePath,"dir")
                mkdir(mergeSavePath);
            end
            matPath = getSubfoldPath(rootPath,'rawData.mat', [paradigmKeyword(pN), posStr(pos)]);
            for recordCode = 1:length(matPath)
                temp = strsplit(matPath{recordCode}, '\');
                dateStr = temp{5};
                mergeInfoMat = fullfile(mergeSavePath, "mergeInfo.mat");
                mergeRawMat = fullfile(mergeSavePath, "mergeRawData.mat");
                if exist(mergeInfoMat, 'file')
                    load(mergeInfoMat);
                    if any(contains({mergeInfo.date}, dateStr))
                        continue;
                    else
                        load(mergeRawMat);
                    end
                else
                    load(matPath{recordCode});
                end
                chData = resampleData(ECOGDataset.data, ECOGDataset.fs, fs, 2);
                if recordCode == 1
                    mergeData.data = chData;
                else
                    mergeData.data = [mergeData.data chData];
                end


                trialAllTemp = trialAll;
                for tIndex = 1 : length(trialAll)
                    trialAllTemp(tIndex).soundOnsetSeq =  trialAllTemp(tIndex).soundOnsetSeq + tMerge;
                    trialAllTemp(tIndex).devOnset =  trialAllTemp(tIndex).devOnset + tMerge;
                    trialAllTemp(tIndex).trialNum =  trialAllTemp(tIndex).trialNum + nMerge;
                end

                mergeInfo(recordCode).date = dateStr;
                mergeInfo(recordCode).trialNum = [trialAllTemp.trialNum]';
                tMerge = tMerge + size(ECOGDataset.data, 2) / ECOGDataset.fs;
                nMerge = nMerge + length(trialAll);
                trialMerge = [trialMerge; trialAllTemp];
            end
            save(mergeInfoMat, 'mergeInfo');
            save(mergeRawMat, 'trialMerge', 'mergeData')
        end
    end
end



