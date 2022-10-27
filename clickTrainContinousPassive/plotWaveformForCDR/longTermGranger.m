clear all; clc
monkeyId = ["chouchou", "xiaoxiao"];
posStr = ["LAuC", "LPFC"];
plotFigure = 1;
reprocess = 1;
idIdx = 1:2;
s1OnsetOrS2Onset = 2; % 1: start, 2: trans
paradigmKeyword = "LongTerm4[^0]";
paradigmStr = strrep(paradigmKeyword, '[^0]', '');

for id = idIdx
    rootPath = fullfile('E:\ECoG\matData', monkeyId(id));
    FDZDataACAll.(monkeyId(id)) = cell(4, 1);
    FDZDataPFCAll.(monkeyId(id)) = cell(4, 1);
    for pN = 1 : length(paradigmKeyword)
        matPath = getSubfoldPath(rootPath,'filterResHP0o1Hz.mat', strcat(paradigmKeyword(pN), ".*", posStr(1)));
        for recordCode = 1 : length(matPath)
            matPathAC = getSubfoldPath(rootPath,'filterResHP0o1Hz.mat', strcat(paradigmKeyword(pN), ".*", posStr(1)));
            matPathPFC = getSubfoldPath(rootPath,'filterResHP0o1Hz.mat', strcat(paradigmKeyword(pN), ".*", posStr(2)));
            temp = strsplit(matPath{recordCode}, '\');
            dateStr = temp{5};
            savePath = fullfile("E:\ECoG\corelDraw\jpgHP0o1Hz", "freq band response comparison", dateStr, "4.06-4") ;
            if ~exist(savePath, 'dir') || reprocess 
                load(matPathAC{recordCode});
                LAuC_FilterRes = filterRes;
                load(matPathPFC{recordCode});
                LPFC_FilterRes = filterRes;
            else
                plotFigure = 0;
                continue
            end



            %
            clearvars -except  LAuC_FilterRes LPFC_FilterRes FDZDataACAll FDZDataPFCAll   id monkeyId recordCode matPath matPathAC matPathPFC   posStr  paradigmKeyword paradigmStr pN filterRes rootPath   plotFigure dateStr    

            % FDZData organise
            FDZTempAC = {LAuC_FilterRes.FDZData}';
            FDZTempPFC = {LPFC_FilterRes.FDZData}';
            for stimCode = 1 : length(LAuC_FilterRes)
                FDZDataACAll.(monkeyId(id)){stimCode, 1} = [FDZDataACAll.(monkeyId(id)){stimCode, 1}; FDZTempAC{stimCode, 1}];
                FDZDataPFCAll.(monkeyId(id)){stimCode, 1} = [FDZDataPFCAll.(monkeyId(id)){stimCode, 1}; FDZTempPFC{stimCode, 1}];
            end
        end
    end
end
FDZData.AC = struct("FDZDataChouChou", FDZDataACAll.chouchou, "FDZDataXiaoXiao", FDZDataACAll.xiaoxiao, "t", {LAuC_FilterRes.t}', "stimStr", {LAuC_FilterRes.stimStr}', "S1Duration", {LAuC_FilterRes.S1Duration}', "fs", {LAuC_FilterRes.fs}');
    FDZData.PFC = struct("FDZDataChouChou", FDZDataPFCAll.chouchou, "FDZDataXiaoXiao", FDZDataPFCAll.xiaoxiao, "t", {LPFC_FilterRes.t}', "stimStr", {LPFC_FilterRes.stimStr}', "S1Duration", {LPFC_FilterRes.S1Duration}', "fs", {LPFC_FilterRes.fs}');

    