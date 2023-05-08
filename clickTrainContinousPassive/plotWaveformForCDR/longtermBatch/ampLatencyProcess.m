
badRecording = [""];

for id = 1:2
    rootPath = fullfile('E:\ECoG\matData', monkeyId(id));
    for pN = 1 : length(paradigmKeyword)

        for pos = 1:2
            matPath = getSubfoldPath(rootPath, matfile, strcat(paradigmKeyword(pN), ".*", posStr(pos)));
            recordN = 1;
            for recordCode = 1 : length(matPath)  
                temp = strsplit(matPath{recordCode}, '\');
                dateStr = string(temp{5});
                savePath = fullfile(figRootPath, "filterAmp", dateStr);
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


%% save amp.mat
wins.ampRMS = filterRes(1).ampSelWin;
wins.ampAREA = filterRes(1).ampSelWin;
wins.ampTrough = filterRes(1).ampSelWin2;
wins.ampPeak = filterRes(1).ampSelWin;
save(fullfile(matSavePath, "amp.mat"), "cdrPlot", "ampAll", "ampMean", "wins");

run("calCdrPlot.m");

%% plot figure
run("ampPlot.m");




