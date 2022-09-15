clear all; clc
monkeyId = ["chouchou", "xiaoxiao"];
posStr = ["LAuC", "LPFC"];
plotFigure = 0;
reprocess = 1;
plotMultiFigure = 0;
selectWin = [-200 600];
yScale = [80 40];
% idIdx = input('Monkey ID: 1-chouchou, 2-xiaoxiao \n');
% posIndex = input('recording area : 1-AC, 2-PFC \n');
paradigmKeyword = ["LongTerm4[^0]", "LongTerm8[^0]", "LongTerm20", "LongTerm40", "LongTerm80", "ICIThr401234", "Insert", "RegInIrreg4o32", "LowHigh4043444546", "Var3", "Tone"];
paradigmStr = strrep(paradigmKeyword, '[^0]', '');
integratePath = "E:\ECoG\matData\longTermContinuous";
badRecording = [""];

for id = 1:2
    rootPath = fullfile('E:\ECoG\matData', monkeyId(id));
    for pN = 1 : length(paradigmKeyword)

        for pos = 1:2
            matPath = getSubfoldPath(rootPath,'filterResHP0o5Hz.mat', strcat(paradigmKeyword(pN), ".*", posStr(pos)));
            recordN = 1;
            clear inteRes
            for recordCode = 1 : length(matPath)  
                temp = strsplit(matPath{recordCode}, '\');
                dateStr = string(temp{5});
                savePath = fullfile("E:\ECoG\corelDraw\jpg\filterAmp",dateStr);
                if ~exist(savePath, 'dir') || reprocess
                    load(matPath{recordCode});

                else
                    continue
                end
                if ~ismember(dateStr, badRecording)
                    for stimCode = 1 : length(filterRes)
                        %                     clearvars -except monkeyId amp latency trialAll id savePath savePath2 recordCode  matPath matPath2 selectWin reprocess selectRecord posStr pos posIndex  stimCode paradigmKeyword paradigmStr pN RawRes rootPath cdrRes cdrPlot plotFigure dateStr plotCh  yScale  plotMultiFigure
                        % get data
                        ampMethods = ["ampRMS", "ampAREA", "ampPeak", "ampTrough"];
                        %                     amp = structSelect(filterRes, ampMethods);



                        if recordN == 1
                            dataAll{stimCode, 1} = filterRes(stimCode).FDZData;
                        else
                            dataAll{stimCode, 1} = [dataAll{stimCode, 1} ; filterRes(stimCode).FDZData];
                        end
                        for mN = 1 : length(ampMethods)
                            if recordN == 1
                                ampAll.(ampMethods(mN)).(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all = filterRes(stimCode).(ampMethods(mN));
                            else
                                ampAll.(ampMethods(mN)).(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all = [ampAll.(ampMethods(mN)).(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all filterRes(stimCode).(ampMethods(mN))];
                            end
                        end

                        ampAll.(ampMethods(mN)).(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).(dateStr) = filterRes(stimCode).(ampMethods(mN));
                        ampMean.(ampMethods(mN)).(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).(dateStr)(1, :) = mean(filterRes(stimCode).(ampMethods(mN))');
                        ampMean.(ampMethods(mN)).(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).(dateStr)(2, :) = std(filterRes(stimCode).(ampMethods(mN))')/sqrt(size(filterRes(stimCode).(ampMethods(mN)), 2));
                    end
                    recordN = recordN + 1;
                end

                if recordCode == length(matPath)
                   tempStruct = structSelect(filterRes, ["t", "stimStr", "S1Duration", "fs", "fs0"]);
                    for stimCode = 1 :  length(filterRes)
                        chMean{stimCode, 1} = cell2mat(cellfun(@mean, changeCellRowNum(dataAll{stimCode, 1}), "UniformOutput", false));
                        chStd{stimCode, 1} = cell2mat(cellfun(@std, changeCellRowNum(dataAll{stimCode, 1}), "UniformOutput", false));
                    end
                    inteRes = addFieldToStruct(tempStruct, [chMean, chStd], ["chMean"; "chStd"]);
                    intePath = fullfile(integratePath, monkeyId(id), paradigmStr(pN));
                    mkdir(intePath);
                    save(fullfile(intePath, strcat(posStr(pos), "_inteRes.mat")), "inteRes");
                end
            end
            for stimCode = 1 : length(filterRes)
                for mN = 1 : length(ampMethods)
                    ampMean.(ampMethods(mN)).(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all(1, :) = mean(ampAll.(ampMethods(mN)).(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all');
                    ampMean.(ampMethods(mN)).(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all(2, :) = std(ampAll.(ampMethods(mN)).(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all')/sqrt(size(ampAll.(ampMethods(mN)).(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all, 2));
                end
            end
        end
    end
end

%%
[sigIndex, h, p] = clickTrainContinuousSelectChannel;

%%
monkeyId = ["chouchou", "xiaoxiao"];
posStr = ["LAuC", "LPFC"];
ICIBasic = ["LongTerm4", "LongTerm8", "LongTerm20", "LongTerm40", "LongTerm80"];
others = ["ICIThr401234", "Insert", "RegInIrreg4o32", "LowHigh4043444546", "Var3", "Tone"];
integratePath = "E:\ECoG\matData\longTermContinuous";

for id = 1 : 2
    for pos = 1 : 2
        tempSel = sigIndex.(monkeyId(id)).(posStr(pos));
        for mN = 1 : length(ampMethods)
            for stimCode = 1 : 4

                for ICIN = 1 : length(ICIBasic)
                    cdrPlot.(monkeyId(id)).(posStr(pos)).diffICI(stimCode).ampRaw.(ampMethods(mN))(ICIN, :) = ampMean.(ampMethods(mN)).(monkeyId(id)).(posStr(pos))(stimCode).(ICIBasic(ICIN)).all(1, :);
                end

                
                cdrPlot.(monkeyId(id)).(posStr(pos)).diffICI(stimCode).ampSel.(ampMethods(mN)) = cdrPlot.(monkeyId(id)).(posStr(pos)).diffICI(stimCode).ampRaw.(ampMethods(mN))(:, tempSel);
                cdrPlot.(monkeyId(id)).(posStr(pos)).diffICI(stimCode).ampEx.(ampMethods(mN)) = cell2mat(excludeTrials(array2VectorCell(cdrPlot.(monkeyId(id)).(posStr(pos)).diffICI(stimCode).ampRaw.(ampMethods(mN))'), 0.1))';

            end


            for otherN = 1 : length(others)
                for stimCode = 1 : 4
                    cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampRaw.(ampMethods(mN))(stimCode, :) = ampMean.(ampMethods(mN)).(monkeyId(id)).(posStr(pos))(stimCode).(others(otherN)).all(1, :);
                end
                cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampSel.(ampMethods(mN)) = cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampRaw.(ampMethods(mN))(:, tempSel);
                cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampEx.(ampMethods(mN)) = cell2mat(excludeTrials(array2VectorCell(cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampRaw.(ampMethods(mN))'), 0.1))';
                if others(otherN) == "LowHigh43444546" || others(otherN) == "ICIThr401234"
                    cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampSel.(ampMethods(mN)) = flipud(cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampSel.(ampMethods(mN)));
                    cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampEx.(ampMethods(mN)) = flipud(cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampEx.(ampMethods(mN)));
                end
            end
        end
    end
end


%% plot figure
ampPath = "E:\ECoG\matData\longTermContinuous";
wins.ampRMS = filterRes(1).ampSelWin;
wins.ampAREA = filterRes(1).ampSelWin;
wins.ampTrough = filterRes(1).ampSelWin;
wins.ampRMS = filterRes(1).ampSelWin;
save(fullfile(ampPath, "amp.mat"), "cdrPlot", "ampAll", "ampMean", "wins");
