clear; clc;
monkeyId = ["chouchou", "xiaoxiao"];
posStr = ["LAuC", "LPFC"];
matFile = "filterResHP0o1Hz.mat";
paradigmStr = "LongTerm4[^0]";
matSavePath = "E:\ECoG\matData\longTermContinuous\cdrPlot0.1Hz";
stimCode = 1;
for id = 1 : 2 % 1: chouchou; 2: xiaoxiao
    rootPath = fullfile('E:\ECoG\matData', monkeyId(id));
    matPathTemp = getSubfoldPath(rootPath, matFile, strcat(paradigmStr, ".*LAuC"));

    for pos = 1 : 2 % 1: LAuC; 2: LPFC
        for recordCode = 1 : length(matPathTemp)
            matPath = getSubfoldPath(rootPath, matFile, strcat(paradigmStr, ".*", posStr(pos)));
            temp = strsplit(matPath{recordCode}, '\');
            dateStr = temp{5};

            load(matPath{recordCode});
            window = filterRes(stimCode).t([1 end]);
            testWin = [-4000 0];
            FDZData = filterRes(stimCode).FDZData;
            [FDZDataTemp, chIdx] = excludeTrialsChs(FDZData, 0.1, window, testWin);
            FDZDataTemp = cellfun(@(x) valueRowCol(x, 0, ~chIdx, 1), FDZDataTemp, "UniformOutput", false);
            S1Duration = filterRes(stimCode).S1Duration;

            fs = filterRes(stimCode).fs; 
            t = filterRes(stimCode).t; 
            mergeTemp.(monkeyId(id)).(posStr(pos)){recordCode, 1} = FDZDataTemp;
            mergeDate(recordCode, 1) = string(dateStr);
        end
        [mergeRes, chIdx] = FDZDailyExtract(mergeTemp.(monkeyId(id)).(posStr(pos)), 10);

        nonBadChRes = cellfun(@(x) valueRowCol(x, [], ~chIdx, 1), mergeRes, "UniformOutput", false);
        
        opts.fs = fs; 
        opts.chs = find(chIdx);
        opts.t = t;
        opts.S1Duration = S1Duration;
        mergeData.(monkeyId(id)).(posStr(pos)) = mergeRes;
        comp.(monkeyId(id)).(posStr(pos)) = mCleanICA(nonBadChRes, opts);
        chSelect.(monkeyId(id)).(posStr(pos)) = chIdx;
    end

end

save(fullfile(matSavePath, "mergeComp.mat"), "mergeData", "comp", "chSelect", "-mat");




