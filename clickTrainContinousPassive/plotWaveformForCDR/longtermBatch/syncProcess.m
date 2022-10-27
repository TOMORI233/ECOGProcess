selectWin = [500 5000]; %
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
                    FDZDataTemp = excludeTrialsChs(FDZData, 0.1);
                    chMean = filterRes(stimCode).chMean;
                    t = filterRes(stimCode).t;
                    fs = filterRes(stimCode).fs;
                    stimStr = filterRes(stimCode).stimStr;
                    if dataType == "ica"
                        FDZDataTemp = cellfun(@(x) compTemp.unmixing * x(chs, :), FDZDataTemp, "UniformOutput", false);
                    end
                    FDZData = changeCellRowNum(FDZDataTemp);

                    % calculate mean waveform
                    smoothBin = 1;
                    P = cell(size(chMean, 1), 1);
                    if dataType == "raw"
                        CH = 1 : size(chMean, 1);
                    elseif dataType == "ica"
                        CH = 1 : length(compTemp.label);
                    end
                    for ch = CH
                        FDZDataTemp = array2VectorCell(FDZData{ch});
                        if s1OnsetOrS2Onset == 1
                            [f, ~, P{ch, 1}] = cellfun(@(x) mFFT(x(t > -4000 & t < 0), fs), FDZDataTemp, 'UniformOutput', false);
                        else
                            [f, ~, P{ch, 1}] = cellfun(@(x) mFFT(x(t > 1000 & t < 5000), fs), FDZDataTemp, 'UniformOutput', false);
                        end
                        ff = f{1};

                        PP{pN}{stimCode, pos}(ch, :) = smoothdata(mean(cell2mat(P{ch, 1})),'gaussian',smoothBin);
                    end
                    FFTRaw.(paradigmStr(pN)).(posStr(pos)).(dateStr){stimCode, 1} = cellfun(@(x) cell2mat(x), P, "UniformOutput", false);
                    run("calCdrPlot.m");

                end


                %                 for stimCode = 1 : length(filterRes)
                %                     for ch = 1 : size(chMean, 1)
                %                         if processType == "DiffICI_ind"
                %                             % order
                %                             [hPFC, pPFC] = cellfun(@(x, y) ttest2(x, y), changeCellRowNum(PRaw{pN}{1, pos}(ch)), changeCellRowNum(PRaw{pN}{3, pos}(ch)), "UniformOutput", false);
                %                             % reverse
                %
                %
                %                         end
                %                     end
                %                 end
            end

            %% plot figures


        end
    end
end

matName = strcat("FFTRaw_", paradigmType);
eval(strcat(matName, "= FFTRaw;"));
save(fullfile(matSavePath, strcat(matName, ".mat")), matName);

