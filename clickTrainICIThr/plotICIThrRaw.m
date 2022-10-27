clear all; clc
monkeyId = ["cc", "xx"];
posStr = ["LAuC", "LPFC"];
plotFigure = 0;
reprocess = 1;
plotMultiFigure = 0;
selectWin = [0 500];
plotSize = [8, 8];
chs = (1 : 64)';
% idIdx = input('Monkey ID: 1-chouchou, 2-xiaoxiao \n');
% posIndex = input('recording area : 1-AC, 2-PFC \n');
paradigmKeyword = "ClickTrainOddICIThr";
paradigmStr = strrep(paradigmKeyword, '[^0]', '');
resData = ["MMNData.mat", "predictData.mat"];
badRecording = [""];
pairStrRep = num2cell(["4ms", "4_03ms", "4_06ms", "4_09ms", "4_12ms"]);
colors = ["#AAAAAA", "black", "blue", "#FFA500", "red"];
for resN = 1 : length(resData) %% result type
    for id = 1:2 % monkey id
        rootPath = "E:\ECoG\matData\behavior";
        for pN = 1 : length(paradigmKeyword) % protocol number
            for pos = 1:2 % LAuC or LPFC
                matPath = getSubfoldPath(rootPath, resData(resN) , strcat(paradigmKeyword(pN), ".*", monkeyId(id), ".*" , posStr(pos)));
                recordN = 1;
                for recordCode = 1 : length(matPath) % recording order
                    temp = strsplit(matPath{recordCode}, '\');
                    dateStr = string(temp{6});
                    savePath = fullfile("E:\ECoG\corelDraw\jpg\Raw", paradigmStr(pN), dateStr);
                    if ~exist(savePath, 'dir') || reprocess
                        clear MMNData clear predictData
                        load(matPath{recordCode});
                    else
                        continue
                    end

                    clear dev_TFA devCompare_Wave  MMN_Wave MMN_TFA devStd_wave prediction_TFA prediction_wave
                    disp(strjoin(["processing", paradigmStr(pN), monkeyId(id), posStr(pos), "...(", num2str(recordCode), '/', num2str(length(matPath)), ')'], ' '));

                    %% plot behavior result
                    pairStr = {'4ms','4.03ms','4.06ms','4.09ms','4.12ms'};
                    trialAll = cell2mat([{MMNData.trialsC}'; {MMNData.trialsW}']);
                    trials = trialAll([trialAll.interrupt] == false);
                    [FigBehavior, mAxe] = plotBehaviorOnly(trialAll, "k", "7-10");
                    behavPath = fullfile(savePath, "behavior");
                    mkdir(behavPath)
                    print(FigBehavior, fullfile(behavPath,  "behaviorResult"), "-djpeg", "-r300");
                    close(FigBehavior);



                    switch resData(resN)
                        case "MMNData.mat"
                            MMNData = addFieldToStruct(MMNData, pairStrRep', "pairStr");
                            for dIndex = 1 : length(MMNData)
                                devStd_wave(dIndex) = plotRawWave(MMNData(dIndex).chMeanDEV, [], MMNData(dIndex).window, strcat( MMNData(dIndex).pairStr,posStr(pos), " dev vs last std"), plotSize, chs, "off");
                                lineSetting.color = "blue";
                                devStd_wave(dIndex) = plotRawWave2(devStd_wave(dIndex), MMNData(dIndex).chMeanLastSTD, [], MMNData(dIndex).window, lineSetting);
                                dev_TFA(dIndex) = plotTFA(MMNData(dIndex).chMeanDEV, MMNData(dIndex).fs0, MMNData(dIndex).fs, MMNData(dIndex).window, strcat( MMNData(dIndex).pairStr, posStr(pos), MMNData(dIndex).pairStr), plotSize, "off");

                                if dIndex == 1
                                    MMN_Wave = plotRawWave(MMNData(dIndex).chMeanDEV - MMNData(dIndex).chMeanLastSTD, [], MMNData(dIndex).window, strcat( MMNData(dIndex).pairStr, posStr(pos), " MMN reg vs irreg"), plotSize, chs, "off");
                                    devCompare_Wave = plotRawWave(MMNData(dIndex).chMeanDEV, [], MMNData(dIndex).window, strcat( MMNData(dIndex).pairStr, posStr(pos), " dev reg vs irreg"), plotSize, chs, "off");
                                    setLine([MMN_Wave devCompare_Wave], "Color", "#AAAAAA", "LineStyle", "-");
                                else
                                    lineSetting.color = colors(dIndex);
                                    MMN_Wave = plotRawWave2(MMN_Wave, MMNData(dIndex).chMeanDEV - MMNData(dIndex).chMeanLastSTD, [], MMNData(dIndex).window, lineSetting);
                                    devCompare_Wave = plotRawWave2(devCompare_Wave, MMNData(dIndex).chMeanDEV, [], MMNData(dIndex).window, lineSetting);
                                end
                                MMN_TFA(dIndex) = plotTFACompare(MMNData(dIndex).chMeanDEV, MMNData(dIndex).chMeanLastSTD, MMNData(dIndex).fs0, MMNData(dIndex).fs, MMNData(dIndex).window, strcat( MMNData(dIndex).pairStr, posStr(pos), "MMN"), plotSize, "off");
                            end

                            lines(1).X = 200;
                            addLines2Axes([devStd_wave, devCompare_Wave, MMN_Wave, MMN_TFA, dev_TFA], lines);
                            scaleAxes([devStd_wave, devCompare_Wave, MMN_Wave, MMN_TFA, dev_TFA], "x", selectWin);
                            scaleAxes([devStd_wave, devCompare_Wave, MMN_Wave], "y", [-50, 50]);
                            scaleAxes(MMN_Wave, "y", [-40, 40]);
                            scaleAxes([MMN_TFA , dev_TFA], "c", [], [0, 20]);

                            for dIndex = 1 : length(MMNData)

                                devStdPath = fullfile(savePath, "devStd_Wave");
                                mkdir(devStdPath);
                                print(devStd_wave(dIndex), fullfile(devStdPath, strcat(posStr(pos), MMNData(dIndex).pairStr)), "-djpeg", "-r300");


                                MMNTFAPath = fullfile(savePath, "MMN_TFA");
                                mkdir(MMNTFAPath);
                                print(MMN_TFA(dIndex), fullfile(MMNTFAPath, strcat(posStr(pos), MMNData(dIndex).pairStr)), "-djpeg", "-r300");

                                devTFAPath = fullfile(savePath, "MMN_TFA");
                                mkdir(devTFAPath);
                                print(dev_TFA(dIndex), fullfile(devTFAPath, strcat(posStr(pos), MMNData(dIndex).pairStr)), "-djpeg", "-r300");
                            end

                            MMNWavePath = fullfile(savePath, "MMN_WaveCompare");
                            mkdir(MMNWavePath)
                            print(MMN_Wave, fullfile(MMNWavePath, strcat(posStr(pos), MMNData(dIndex).pairStr)), "-djpeg", "-r300");

                            devCompareWavePath =  fullfile(savePath, "deviant Compare wave");
                            mkdir(devCompareWavePath);
                            print(devCompare_Wave, fullfile(devCompareWavePath, strcat(posStr(pos), MMNData(dIndex).pairStr)), "-djpeg", "-r300");

                            close all
                        case "predictData.mat"
                            for sIndex = 1 : length(predictData)
                                prediction_wave(sIndex) =  plotRawWave(predictData(sIndex).chMean, [], predictData(sIndex).window, strcat( predictData(sIndex).typeStr, posStr(pos), " prediction"), plotSize, chs, "off");
                                prediction_TFA(sIndex) =  plotTFA(predictData(sIndex).chMean, predictData(sIndex).fs0, predictData(sIndex).fs, predictData(sIndex).window, strcat( predictData(sIndex).typeStr, posStr(pos), " prediction"), plotSize, "off");
                            end
                            lines(1).X = 200;
                            addLines2Axes([prediction_wave, prediction_TFA], lines);
                            scaleAxes(prediction_wave, "y", [-60, 60]);
                            scaleAxes(prediction_TFA, "c", [], [0, 20]);

                            for sIndex = 1 : length(predictData)
                                predictionWavePath =  fullfile(savePath, "prediction wave");
                                mkdir(predictionWavePath);
                                print(prediction_wave(sIndex), fullfile(predictionWavePath, strcat(posStr(pos), predictData(sIndex).typeStr)), "-djpeg", "-r300");

                                predictionTFAPath =  fullfile(savePath, "precition TFA");
                                mkdir(predictionTFAPath);
                                print(prediction_TFA(sIndex), fullfile(predictionTFAPath, strcat(posStr(pos), predictData(sIndex).typeStr)), "-djpeg", "-r300");
                            end
                            close all
                    end
                end
            end
        end
    end
end
