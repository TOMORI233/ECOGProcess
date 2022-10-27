for id = 1 : 2
    rootPath = fullfile('E:\ECoG\matData', monkeyId(id));
    matPath = getSubfoldPath(rootPath, matFile, strcat(paradigmKeyword(5), ".*", posStr(1)));

    for recordCode = 1 : length(matPath)
        temp = strsplit(matPath{recordCode}, '\');
        dateStr = temp{5};
        savePath = fullfile(figRootPath, "diffICIBase", dateStr);

        for pN = 1 : length(paradigmKeyword)
            for pos = 1 : 2
                if dataType == "ica"
                    chs = chSelect.(monkeyId(id)).(posStr(pos));
                    compTemp = comp.(monkeyId(id)).(posStr(pos));
                end

                matPath = getSubfoldPath(rootPath,matFile, strcat(paradigmKeyword(pN), ".*", posStr(pos)));

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


                    if s1OnsetOrS2Onset == 1
                        t = filterRes(stimCode).t + filterRes(stimCode).S1Duration;
                        selectWin = [0 diff(selectWin)] - 200;
                    end

                    % decide the zero hour
                    tIndex = find(t > selectWin(1) & t < selectWin(2));
                    tIndex = tIndex(1 : floor(length(tIndex) / 10) * 10);
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
        end
        %% plot figures
        run("DiffICI_mergePlot.m");
    end
end


