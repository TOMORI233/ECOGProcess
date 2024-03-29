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
paradigmKeyword = "ClickTrainOddCompare";
paradigmStr = strrep(paradigmKeyword, '[^0]', '');
resData = ["MMNData.mat", "preditionData.mat"];
badRecording = [""];
pairStrRep = num2cell(["RegC", "RegD", "IrregC", "IrregD", "FuzaToneC", "FuzaToneD"]);

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
                    savePath = fullfile("E:\ECoG\corelDraw\jpg", paradigmStr(pN), dateStr);
                    if ~exist(savePath, 'dir') || reprocess
                        load(matPath{recordCode});
                    else
                        continue
                    end

                    clear MMNData devCompare_TFA devCompare_Wave  MMN_Wave MMN_TFA devStd_wave
                    disp(strjoin(["processing", paradigmStr(pN), monkeyId(id), posStr(pos), "...(", num2str(recordCode), '/', num2str(length(matPath)), ')'], ' '));
                    MMNData = addFieldToStruct(MMNData, pairStrRep', "pairStr");

                    %% plot behavior result
                    pairStr = {'4-4.06RC','4-4.06RD','4-4.06IC','4-4.06ID','FuzaTone-C','FuzaTone-D'};
                    typeStr = {'4-4.06Regular','4-4.06Irregular','ComplexTone'};
                    trialAll = cell2mat([{MMNData.trialsC}'; {MMNData.trialsW}']);
                    trials = trialAll([trialAll.interrupt] == false);
                    [FigBehavior, mAxe] = plotClickTrainWMBehaviorOnly(trials, "k", {'control', 'dev'}, pairStr);
                    behavPath = fullfile(savePath, "behavior");
                    mkdir(behavPath)
                    print(FigBehavior, fullfile(behavPath,  "behaviorResult"), "-djpeg", "-r300");
                    close(FigBehavior);



                    switch resData(resN)
                        case "MMNData.mat"
                            for dIndex = 1 : length(MMNData)
                                devStd_wave(dIndex) = plotRawWave(MMNData(dIndex).chMeanDEV, [], MMNData(dIndex).window, strcat( MMNData(dIndex).pairStr,posStr(pos), " dev vs last std"), plotSize, chs, "off");
                                lineSetting.color = "blue";
                                devStd_wave(dIndex) = plotRawWave2(devStd_wave(dIndex), MMNData(dIndex).chMeanLastSTD, [], MMNData(dIndex).window, lineSetting);
                                if mod(dIndex, 2) == 1
                                    MMN_Wave(ceil(dIndex / 2)) = plotRawWave(MMNData(dIndex).chMeanDEV - MMNData(dIndex).chMeanLastSTD, [], MMNData(dIndex).window, strcat( MMNData(dIndex).pairStr, posStr(pos), " MMN reg vs irreg"), plotSize, chs, "off");
                                    devCompare_Wave(ceil(dIndex / 2)) = plotRawWave(MMNData(dIndex).chMeanDEV, [], MMNData(dIndex).window, strcat( MMNData(dIndex).pairStr, posStr(pos), " dev reg vs irreg"), plotSize, chs, "off");
                                    setLine([MMN_Wave(ceil(dIndex / 2)) devCompare_Wave(ceil(dIndex / 2))], "Color", "blue", "LineStyle", "-");
                                else
                                    lineSetting.color = "red";
                                    MMN_Wave(ceil(dIndex / 2)) = plotRawWave2(MMN_Wave(ceil(dIndex / 2)), MMNData(dIndex).chMeanDEV - MMNData(dIndex).chMeanLastSTD, [], MMNData(dIndex).window, lineSetting);
                                    devCompare_Wave(ceil(dIndex / 2)) = plotRawWave2(devCompare_Wave(ceil(dIndex / 2)), MMNData(dIndex).chMeanDEV, [], MMNData(dIndex).window, lineSetting);
                                    devCompare_TFA(ceil(dIndex / 2)) = plotTFACompare(MMNData(dIndex).chMeanDEV, MMNData(dIndex - 1).chMeanDEV, MMNData(dIndex).fs0, MMNData(dIndex).fs, MMNData(dIndex).window, strcat( MMNData(dIndex).pairStr, posStr(pos), "dev compare"), plotSize, "off");
                                end
                                MMN_TFA(dIndex) = plotTFACompare(MMNData(dIndex).chMeanDEV, MMNData(dIndex).chMeanLastSTD, MMNData(dIndex).fs0, MMNData(dIndex).fs, MMNData(dIndex).window, strcat( MMNData(dIndex).pairStr, posStr(pos), "MMN"), plotSize, "off");
                            end

                            lines(1).X = 200;
                            addLines2Axes([devStd_wave, devCompare_Wave, MMN_Wave, MMN_TFA, devCompare_TFA], lines);
                            scaleAxes([devStd_wave, devCompare_Wave, MMN_Wave, MMN_TFA, devCompare_TFA], "x", selectWin);
                            scaleAxes([devStd_wave, devCompare_Wave, MMN_Wave], "y", [-60, 60]);
                            scaleAxes([MMN_TFA , devCompare_TFA], "c", [], [0, 20]);

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
                        case "preditionData"
                            
                    end
                end
            end
        end
    end
end
