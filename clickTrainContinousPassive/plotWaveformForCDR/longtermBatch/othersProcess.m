for id = 1 : 2 % 1: chouchou; 2: xiaoxiao
    rootPath = fullfile('E:\ECoG\matData', monkeyId(id));

    for pN = 1 : length(paradigmKeyword)
        matPathTemp = getSubfoldPath(rootPath, matFile, strcat(paradigmKeyword(pN), ".*LAuC"));

        for recordCode = 1 : length(matPathTemp)

            for pos = 1 : 2 % 1: LAuC; 2: LPFC
                if dataType == "ica"
                    chs = chSelect.(monkeyId(id)).(posStr(pos));
                    compTemp = comp.(monkeyId(id)).(posStr(pos));
                end

                matPath = getSubfoldPath(rootPath, matFile, strcat(paradigmKeyword(pN), ".*", posStr(pos)));
                temp = strsplit(matPath{recordCode}, '\');
                dateStr = temp{5};
                if paradigmType == "RegIrreg"
                    savePath = fullfile(figRootPath, "RegIrreg", paradigmStr(pN), dateStr) ;
                else
                    savePath = fullfile(figRootPath, paradigmStr(pN), dateStr) ;
                end

                %% judge continue or load data to process for cdrPlot and figure
                if ~exist(savePath, 'dir') || reprocess
                    load(matPath{recordCode});
                    plotFigure = 1;
                elseif processCDR
                    load(matPath{recordCode});
                    plotFigure = 0;
                else
                    plotFigure = 0;
                    continue
                end

                for stimCode = 1 : length(filterRes)


                    % get data
                    FDZData = filterRes(stimCode).FDZData;
                    FDZData = excludeTrialsChs(FDZData, 0.1);
                    chMean = filterRes(stimCode).chMean;
                    t = filterRes(stimCode).t;
                    stimStr = filterRes(stimCode).stimStr;

                    % decide the zero hour
                    if s1OnsetOrS2Onset == 1
                        t = filterRes(stimCode).t + filterRes(stimCode).S1Duration;
                        selectWin = [0 diff(selectWin)] - 200;
                    end

                    % calculate mean waveform
                    tIndex = find(t > selectWin(1) & t < selectWin(2));
                    tIndex = tIndex(1 : floor(length(tIndex) / 10) * 10);
                    %                     chMeanSel{pN}{stimCode, pos}= chMean(:, tIndex);
                    if dataType == "raw"
                        chMeanSel{pN}{stimCode, pos}= cell2mat(cellfun(@(x) mean(x(:, tIndex)), changeCellRowNum(FDZData), "UniformOutput", false));
                    elseif dataType == "ica"
                        icaRes = cellfun(@(x) compTemp.unmixing * x(chs, :), FDZData, "UniformOutput", false);
                        chMeanSel{pN}{stimCode, pos} = zeros(size(chMean, 1), length(tIndex));
                        chMeanSel{pN}{stimCode, pos}(1 : length(compTemp.label), :) = cell2mat(cellfun(@(x) mean(x(:, tIndex)), changeCellRowNum(icaRes), "UniformOutput", false));
                    end
                    run("calCdrPlot.m");
                end
            end

            %% plot figures
            if ismember(paradigmType, ["Others", "DiffICI_ind"])
                run("othersPlot.m");
            elseif paradigmType == "RegIrreg"
                run("regIrregPlot.m");
            elseif paradigmType ==  "Species"
                run("speciesPlot.m");
            end

        end
    end
end

