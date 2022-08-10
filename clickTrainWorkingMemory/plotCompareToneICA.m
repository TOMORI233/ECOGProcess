clear all; clc
monkeyId = ["cc", "xx"];
posStr = ["LAuC", "LPFC"];
plotFigure = 0;
reprocess = 0;
plotMultiFigure = 0;
selectWin = [-100 500];
plotSize = [8, 8];
chs = (1 : 64)';
% idIdx = input('Monkey ID: 1-chouchou, 2-xiaoxiao \n');
% posIndex = input('recording area : 1-AC, 2-PFC \n');
paradigmKeyword = "ClickTrainOddCompareTone";
paradigmStr = strrep(paradigmKeyword, '[^0]', '');
resData = ["MMNData.mat", "predictData.mat"]; % 
badRecording = [""];
pairStrRep = num2cell(["Reg4o16C", "Reg4o16D", "Reg5C", "Reg5D", "Irreg4o16C", "Irreg4o16D", "Irreg5C", "Irreg5D", "Tone250Hz", "Tone240Hz", "Tone250Hz", "Tone200Hz"]);

for resN = 1 : length(resData) %% result type
    for id = 1:2 % monkey id
        rootPath = "E:\ECoG\matData\behavior";
        for pN = 1 : length(paradigmKeyword) % protocol number
            for pos = 1:2 % LAuC or LPFC
                matPath = getSubfoldPath(rootPath, resData(resN) , strcat(paradigmKeyword(pN), ".*", monkeyId(id), ".*" , posStr(pos)));
                recordN = 1;
                for recordCode = 1 : length(matPath) % recording order
                    temp = strsplit(matPath{recordCode}, '\');
                    activeOrPassive = string(temp{6});
                    dateStr = string(temp{7});
                    savePath = fullfile("E:\ECoG\corelDraw\jpg\ICA", paradigmStr(pN), dateStr, activeOrPassive);
                    processMark = fullfile(savePath, "process.mat");
                    if ~exist(processMark, "file") || reprocess
                        clear MMNData clear predictData
                        load(matPath{recordCode});
                    else
                        continue
                    end

                    clear devCompare_TFA devCompare_Wave  MMN_Wave MMN_TFA devStd_wave prediction_TFA prediction_wave
                    disp(strjoin(["processing", paradigmStr(pN), monkeyId(id), posStr(pos), "...(", num2str(recordCode), '/', num2str(length(matPath)), ')'], ' '));
                    


                    pairStr = {'4-4.16RC','4-4.16RD','4-5RC','4-5RD','4-4.16IC','4-4.16ID','4-5IC','4-5ID','250-250Hz','250-240Hz','250-250Hz','250-200Hz'};
                    typeStr = {'4-4o16Regular','4-5Regular','4-4o06Irregular','4-5Irregular','250-240HzTone','250-200HzTone'};
                    %% plot behavior result   
                    if resData(resN) == "MMNData.mat" && activeOrPassive == "Active"
                        trialAll = cell2mat([{MMNData.trialsC}'; {MMNData.trialsW}']);
                        trials = trialAll([trialAll.interrupt] == false);
                        [FigBehavior, mAxe] = plotClickTrainWMBehaviorOnly(trials, "k", {'control', 'dev'}, pairStr);
                        behavPath = fullfile(savePath, "behavior");
                        mkdir(behavPath)
                        print(FigBehavior, fullfile(behavPath,  "behaviorResult"), "-djpeg", "-r300");
                        close(FigBehavior);
                    end


                    %% plot ICA topo
                    clear comp
                    load(strrep(matPath{recordCode}, resData(resN), 'icaComp.mat'));
                    FigTopo = plotTopo(comp, [8, 8], [8, 8], "on");
                    topoPath = fullfile(savePath, "icaTopo");
                    mkdir(topoPath)
                    print(FigTopo, fullfile(topoPath, strcat(posStr(pos), "icaTopo")), "-djpeg", "-r300");
                    close(FigTopo);

                    switch resData(resN)
                        case "MMNData.mat"
                            MMNData = addFieldToStruct(MMNData, pairStrRep', "pairStr");
                            for dIndex = 1 : length(MMNData)
                                devStd_wave(dIndex) = plotRawWave(MMNData(dIndex).chMeanDEVICA, [], MMNData(dIndex).window, strcat( MMNData(dIndex).pairStr,posStr(pos), " dev vs last std"), plotSize, chs, "off");
                                devStd_wave(dIndex) = plotRawWave2(devStd_wave(dIndex), MMNData(dIndex).chMeanLastSTDICA, [], MMNData(dIndex).window, 'blue');
                                if mod(dIndex, 2) == 1
                                    MMN_Wave(ceil(dIndex / 2)) = plotRawWave(MMNData(dIndex).chMeanDEVICA - MMNData(dIndex).chMeanLastSTDICA, [], MMNData(dIndex).window, strcat( MMNData(dIndex + 1).pairStr, posStr(pos), " MM"), plotSize, chs, "off");
                                    devCompare_Wave(ceil(dIndex / 2)) = plotRawWave(MMNData(dIndex).chMeanDEVICA, [], MMNData(dIndex).window, strcat( MMNData(dIndex).pairStr, posStr(pos), " dev reg vs irreg"), plotSize, chs, "off");
                                    setLine([MMN_Wave(ceil(dIndex / 2)) devCompare_Wave(ceil(dIndex / 2))], "Color", "blue", "LineStyle", "-");
                                else
                                    MMN_Wave(ceil(dIndex / 2)) = plotRawWave2(MMN_Wave(ceil(dIndex / 2)), MMNData(dIndex).chMeanDEVICA - MMNData(dIndex).chMeanLastSTDICA, [], MMNData(dIndex).window, 'red');
                                    devCompare_Wave(ceil(dIndex / 2)) = plotRawWave2(devCompare_Wave(ceil(dIndex / 2)), MMNData(dIndex).chMeanDEVICA, [], MMNData(dIndex).window, 'red');
                                    devCompare_TFA(ceil(dIndex / 2)) = plotTFACompare(MMNData(dIndex).chMeanDEVICA, MMNData(dIndex - 1).chMeanDEVICA, MMNData(dIndex).fs0, MMNData(dIndex).fs, MMNData(dIndex).window, strcat( MMNData(dIndex).pairStr, posStr(pos), " dev compare"), plotSize, "off");
                                end
                                MMN_TFA(dIndex) = plotTFACompare(MMNData(dIndex).chMeanDEVICA, MMNData(dIndex).chMeanLastSTDICA, MMNData(dIndex).fs0, MMNData(dIndex).fs, MMNData(dIndex).window, strcat( MMNData(dIndex).pairStr, posStr(pos), "MMN"), plotSize, "off");
                            end

                            lines(1).X = 200;
                            addLines2Axes([devStd_wave, devCompare_Wave, MMN_Wave, MMN_TFA, devCompare_TFA], lines);
                            scaleAxes([devStd_wave, devCompare_Wave, MMN_Wave, MMN_TFA, devCompare_TFA], "x", selectWin);
                            scaleAxes([devStd_wave, devCompare_Wave, MMN_Wave], "y", [-6, 6]);
                            scaleAxes(devCompare_TFA, "c", [], [-0.3, 0.3]);
                            scaleAxes(MMN_TFA, "c", [], [0, 0.3]);

                            for dIndex = 1 : length(MMNData)

                                devStdPath = fullfile(savePath, "devStd_Wave");
                                mkdir(devStdPath);
                                print(devStd_wave(dIndex), fullfile(devStdPath, strcat(posStr(pos), MMNData(dIndex).pairStr)), "-djpeg", "-r300");


                                MMNTFAPath = fullfile(savePath, "MMN_TFA");
                                mkdir(MMNTFAPath);
                                print(MMN_TFA(dIndex), fullfile(MMNTFAPath, strcat(posStr(pos), MMNData(dIndex).pairStr)), "-djpeg", "-r300");

                                if mod(dIndex, 2) == 0

                                    MMNWavePath = fullfile(savePath, "MMN_WaveCompare");
                                    mkdir(MMNWavePath)
                                    print(MMN_Wave(ceil(dIndex / 2)), fullfile(MMNWavePath, strcat(posStr(pos), MMNData(dIndex).pairStr)), "-djpeg", "-r300");

                                    devCompareWavePath =  fullfile(savePath, "deviant Compare wave");
                                    mkdir(devCompareWavePath);
                                    print(devCompare_Wave(ceil(dIndex / 2)), fullfile(devCompareWavePath, strcat(posStr(pos), MMNData(dIndex).pairStr)), "-djpeg", "-r300");

                                    devCompareTFAPath =  fullfile(savePath, "deviant Compare TFA");
                                    mkdir(devCompareTFAPath);
                                    print(devCompare_TFA(ceil(dIndex / 2)), fullfile(devCompareTFAPath, strcat(posStr(pos), MMNData(dIndex).pairStr)), "-djpeg", "-r300");
                                end
                            end
                            close all

                        case "predictData.mat"
                            for sIndex = 1 : length(predictData)
                                prediction_wave(sIndex) =  plotRawWave(predictData(sIndex).chMeanICA, [], predictData(sIndex).window, strcat( predictData(sIndex).typeStr, posStr(pos), " prediction"), plotSize, chs, "off");
                                prediction_TFA(sIndex) =  plotTFA(predictData(sIndex).chMeanICA, predictData(sIndex).fs0, predictData(sIndex).fs, predictData(sIndex).window, strcat( predictData(sIndex).typeStr, posStr(pos), " prediction"), plotSize, "off");
                            end
                            
                            scaleAxes(prediction_wave, "y");
                            scaleAxes(prediction_TFA, "c");

                            for sIndex = 1 : length(predictData)
                                predictionWavePath =  fullfile(savePath, "prediction wave");
                                mkdir(predictionWavePath);
                                print(prediction_wave(sIndex), fullfile(predictionWavePath, strrep(predictData(sIndex).typeStr, ".", "o")), "-djpeg", "-r300");

                                predictionTFAPath =  fullfile(savePath, "precition TFA");
                                mkdir(predictionTFAPath);
                                print(prediction_TFA(sIndex), fullfile(predictionTFAPath, strcat(posStr(pos), strrep(predictData(sIndex).typeStr, ".", "o"))), "-djpeg", "-r300");
                            end
                            close all
                            if pos == 2
                                processed = 1;
                                save(processMark, "processed");
                            end

                    end
                end
            end
        end
    end
end
