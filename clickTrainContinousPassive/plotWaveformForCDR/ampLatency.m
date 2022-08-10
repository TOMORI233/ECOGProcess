clear all; clc
monkeyId = ["chouchou", "xiaoxiao"];
posStr = ["LAuC", "LPFC"];
plotFigure = 0;
reprocess = 0;
plotMultiFigure = 0;
selectWin = [-200 600];
yScale = [80 40];
% idIdx = input('Monkey ID: 1-chouchou, 2-xiaoxiao \n');
% posIndex = input('recording area : 1-AC, 2-PFC \n');
paradigmKeyword = ["LongTerm4[^0]", "LongTerm8[^0]", "LongTerm20", "LongTerm40", "LongTerm80", "ICIThr401234", "Insert", "RegInIrreg4o32", "LowHigh4043444546", "Var3", "Tone"];
paradigmStr = strrep(paradigmKeyword, '[^0]', '');

for id = 1:2
    rootPath = fullfile('E:\ECoG\matData', monkeyId(id));
    for pN = 1 : length(paradigmKeyword)
        for pos = 1:2
            matPath = getSubfoldPath(rootPath,'ampLatencyRaw.mat', strcat(paradigmKeyword(pN), ".*", posStr(pos)));
            matPath2 = strrep(matPath, 'ampLatencyRaw.mat', 'RawRes.mat');
            for recordCode = 1 : length(matPath)
                temp = strsplit(matPath{recordCode}, '\');
                dateStr = temp{5};
                savePath = fullfile("E:\ECoG\corelDraw\jpg\ampLatency",dateStr);
                if ~exist(savePath, 'dir') || reprocess
                    load(matPath{recordCode});
                    load(matPath2{recordCode});
                else
                    continue
                end
                devType = unique([trialAll.devOrdr]);
                for stimCode = 1 : length(devType)
                    %                     clearvars -except monkeyId amp latency trialAll id savePath savePath2 recordCode  matPath matPath2 selectWin reprocess selectRecord posStr pos posIndex  stimCode paradigmKeyword paradigmStr pN RawRes rootPath cdrRes cdrPlot plotFigure dateStr plotCh  yScale  plotMultiFigure
                    % get data
                    tIndex = find([trialAll.devOrdr] == devType(stimCode));
                    if recordCode == 1
                        ampAll.(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all = cell2mat(amp(tIndex)');
                        latencyAll.(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all = cell2mat(latency(tIndex)');
                    else
                        ampAll.(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all = [ampAll.(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all cell2mat(amp(tIndex)')];
                        latencyAll.(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all = [latencyAll.(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all cell2mat(latency(tIndex)')];
                    end
                    ampAll.(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).(dateStr) = cell2mat(amp(tIndex)');
                    latencyAll.(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).(dateStr) = cell2mat(latency(tIndex)');
                    ampMean.(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).(dateStr)(1, :) = mean(cell2mat(amp(tIndex)')');
                    ampMean.(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).(dateStr)(2, :) = std(cell2mat(amp(tIndex)')')/sqrt(length(tIndex));
                    latencyMean.(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).(dateStr)(1, :) = mean(cell2mat(latency(tIndex)')');
                    latencyMean.(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).(dateStr)(1, :) = std(cell2mat(latency(tIndex)')')/sqrt(length(tIndex));

                end
            end
            for stimCode = 1 : length(devType)
                ampMean.(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all(1, :) = mean(ampAll.(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all');
                ampMean.(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all(2, :) = std(ampAll.(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all')/sqrt(length(tIndex));
                latencyMean.(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all(1, :) = mean(latencyAll.(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all');
                latencyMean.(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all(2, :) = std(latencyAll.(monkeyId(id)).(posStr(pos))(stimCode).(paradigmStr(pN)).all')/sqrt(length(tIndex));
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
ampPath = fullfile("E:\ECoG\corelDraw\jpg\amp");
latencyPath = fullfile("E:\ECoG\corelDraw\jpg\latency");
for id = 1 : 2
    for pos = 1 : 2
        tempSel = sigIndex.(monkeyId(id)).(posStr(pos));
        for stimCode = 1 : 4
            for ICIN = 1 : length(ICIBasic)
                cdrPlot.(monkeyId(id)).(posStr(pos)).diffICI(stimCode).ampRaw(ICIN, :) = ampMean.(monkeyId(id)).(posStr(pos))(stimCode).(ICIBasic(ICIN)).all(1, :);
                cdrPlot.(monkeyId(id)).(posStr(pos)).diffICI(stimCode).latencyRaw(ICIN, :) = latencyMean.(monkeyId(id)).(posStr(pos))(stimCode).(ICIBasic(ICIN)).all(1, :);
            end

            cdrPlot.(monkeyId(id)).(posStr(pos)).diffICI(stimCode).ampSel = cdrPlot.(monkeyId(id)).(posStr(pos)).diffICI(stimCode).ampRaw(:, tempSel);
            cdrPlot.(monkeyId(id)).(posStr(pos)).diffICI(stimCode).latencySel =  cdrPlot.(monkeyId(id)).(posStr(pos)).diffICI(stimCode).latencyRaw(:, tempSel);
            cdrPlot.(monkeyId(id)).(posStr(pos)).diffICI(stimCode).ampEx = cell2mat(excludeTrials(array2VectorCell(cdrPlot.(monkeyId(id)).(posStr(pos)).diffICI(stimCode).ampRaw'), 0.1))';
            cdrPlot.(monkeyId(id)).(posStr(pos)).diffICI(stimCode).latencyEx =  cell2mat(excludeTrials(array2VectorCell(cdrPlot.(monkeyId(id)).(posStr(pos)).diffICI(stimCode).latencyRaw'), 0.1))';


        end


        for otherN = 1 : length(others)
            for stimCode = 1 : 4
                cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampRaw(stimCode, :) = ampMean.(monkeyId(id)).(posStr(pos))(stimCode).(others(otherN)).all(1, :);
                cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).latencyRaw(stimCode, :) = latencyMean.(monkeyId(id)).(posStr(pos))(stimCode).(others(otherN)).all(1, :);
            end
            cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampSel = cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampRaw(:, tempSel);
            cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).latencySel = cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).latencyRaw(:, tempSel);
            cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampEx = cell2mat(excludeTrials(array2VectorCell(cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampRaw'), 0.1))';
            cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).latencyEx =  cell2mat(excludeTrials(array2VectorCell(cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).latencyRaw'), 0.1))';
            if others(otherN) == "LowHigh43444546" || others(otherN) == "ICIThr401234"
                cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampSel = flipud(cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampSel);
                cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).latencySel = flipud(cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).latencySel);
                cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampEx = flipud(cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampEx);
                cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).latencyEx =  flipud(cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).latencyEx);
            end
        end
    end
end


%% plot figure


