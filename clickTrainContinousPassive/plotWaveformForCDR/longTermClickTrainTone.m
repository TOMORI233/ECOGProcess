%% 4ms click train
clear all; clc
monkeyId = ["chouchou", "xiaoxiao"];
posStr = ["LAuC", "LPFC"];
plotFigure = 0;
plotMultiFigure = 1;
selectWin = [-200 600];
yScale = [120 120];
idIdx = input('Monkey ID: 1-chouchou, 2-xiaoxiao \n');
posIndex = input('recording area : 1-AC, 2-PFC \n');
s1OnsetOrS2Onset = input('zero is : 1-s1 onset, 2-s2 onset \n'); % 1: start, 2: trans
rootPath = fullfile('E:\ECoG\matData', monkeyId(idIdx));
% rawResDataPath = getSubfoldPath('E:\ECoG','Res.mat','^(?!.*Merge)');

paradigmKeyword = ["LongTerm4[^0]", "LongTerm8[^0]", "LongTerm20", "LongTerm40", "LongTerm80"];
paradigmStr = strrep(paradigmKeyword, '[^0]', '');
% display recording tabel
matPath = getSubfoldPath(rootPath,'RawRes.mat', strcat(paradigmKeyword(1), ".*", posStr(1)));
recordTable = cell2table([num2cell((1 : length(matPath))'), matPath], "VariableNames", {'recordingCode', 'matPath'});
fig = uifigure('Position', [500 100 800 600]);
uit = uitable(fig, 'Data', recordTable, 'Position', [0 0 800 600] , 'ColumnWidth', {200,600});
selectRecord = input('selected record ID: \n');
close(fig);

%     for pN = 1
for pN = 1 : length(paradigmKeyword)
    for recordCode = selectRecord

        for pos = posIndex
            matPath = getSubfoldPath(rootPath,'RawRes.mat', strcat(paradigmKeyword(pN), ".*", posStr(pos)));

            load(matPath{recordCode});
            temp = strsplit(matPath{recordCode}, '\');
            dateStr = temp{5};


            for stimCode = 1 : length(RawRes)
                clearvars -except recordCode matPath selectWin selectRecord posStr pos posIndex pos stimCode paradigmKeyword paradigmStr pN RawRes rootPath cdrRes cdrPlot plotFigure dateStr plotCh chMeanSel yScale s1OnsetOrS2Onset plotMultiFigure idIdx
                % get data
                chMean = RawRes(stimCode).chMean;
                t = RawRes(stimCode).t;
                stimStr = RawRes(stimCode).stimStr;
                if s1OnsetOrS2Onset == 1
                    window = [0 11000];
                    t = RawRes(stimCode).t + RawRes(stimCode).S1Duration;
                    selectWin = [0 diff(selectWin)];
                elseif s1OnsetOrS2Onset == 2
                    window = [0 11000] - RawRes(stimCode).S1Duration;
                end


                tIndex = find(t > selectWin(1) & t < selectWin(2));
                tIndex = tIndex(1 : floor(length(tIndex) / 10) * 10);
                chMeanSel{pN}{stimCode, pos} = chMean(:, tIndex);
                % data for corelDraw
                RawRes(stimCode).tCDR = t(tIndex);
                RawRes(stimCode).chMeanCDR = chMeanSel{pN}{stimCode, pos};

                cdrRes.(paradigmStr(pN)).(dateStr)(stimCode).tCDR = t(tIndex);
                cdrRes.(paradigmStr(pN)).(dateStr)(stimCode).chMeanCDR = chMeanSel{pN}{stimCode, pos};
                cdrRes.(paradigmStr(pN)).(dateStr)(stimCode).stimStr = RawRes(stimCode).stimStr;
                % save(matPath{recordCode}, "RawRes");

                for ch = 1 : size(chMeanSel{pN}{stimCode, pos}, 1)
                    cdrPlot.(strcat('ch', num2str(ch))){recordCode, stimCode}(:, 2*pN - 1) = t(tIndex);
                    cdrPlot.(strcat('ch', num2str(ch))){recordCode, stimCode}(:, 2*pN) = chMeanSel{pN}{stimCode, pos}(ch , :)';
                end
                %             print(Fig_wave, strcat(PEPATH, AREANAME, "_PE_Raw_", num2str(dIndex), "_", DateStr), "-djpeg", "-r200");
            end

        end

    end
end

%% tone
clearvars -except chMeanSel selectWin yScale plotMultiFigure posStr monkeyId plotFigure idIdx posIndex s1OnsetOrS2Onset; clc
monkeyId = ["chouchou", "xiaoxiao"];
posStr = ["LAuC", "LPFC"];
rootPath = fullfile('E:\ECoG\matData', monkeyId(idIdx));
% rawResDataPath = getSubfoldPath('E:\ECoG','Res.mat','^(?!.*Merge)');

paradigmKeyword = "Tone"; %Insert, RegInIrreg4o32, LowHigh43444546, ICIThr401234, Var3, offset, Tone
paradigmStr = strrep(paradigmKeyword, '[^0]', '');
% % display recording tabel
% matPath = getSubfoldPath(rootPath,'RawRes.mat', strcat(paradigmKeyword(1), ".*", posStr(1)));
% recordTable = cell2table([num2cell((1 : length(matPath))'), matPath], "VariableNames", {'recordingCode', 'matPath'});
% fig = uifigure('Position', [500 100 800 600]);
% uit = uitable(fig, 'Data', recordTable, 'Position', [0 0 800 600] , 'ColumnWidth', {200,600});
selectRecord = input('selected record ID: \n');
% close(fig);

% for pN = 1
for pN = 1 : length(paradigmKeyword)

    for recordCode = selectRecord
        for pos = posIndex
            matPath = getSubfoldPath(rootPath,'RawRes.mat', strcat(paradigmKeyword(pN), ".*", posStr(pos)));
            load(matPath{recordCode});
            temp = strsplit(matPath{recordCode}, '\');
            dateStr = temp{5};
            for stimCode = 1 : length(RawRes)
                clearvars -except recordCode matPath selectWin selectRecord posStr pos posIndex pos stimCode paradigmKeyword paradigmStr pN RawRes rootPath cdrRes cdrPlot plotFigure dateStr plotCh chMeanSel chMeanSel2 yScale s1OnsetOrS2Onset plotMultiFigure
                % get data
                chMean = RawRes(stimCode).chMean;
                t = RawRes(stimCode).t;
                stimStr = RawRes(stimCode).stimStr;
                if s1OnsetOrS2Onset == 1
                    window = [0 11000];
                elseif s1OnsetOrS2Onset == 2
                    window = [0 11000] - RawRes(stimCode).S1Duration;
                end

                tIndex = find(t > selectWin(1) & t < selectWin(2));
                tIndex = tIndex(1 : floor(length(tIndex) / 10) * 10);
                chMeanSel2{pN}{stimCode, pos}= chMean(:, tIndex);

                % data for corelDraw
                RawRes(stimCode).tCDR = t(tIndex);
                RawRes(stimCode).chMeanCDR = chMeanSel2{pN}{stimCode, pos};

                cdrRes.(paradigmStr(pN)).(dateStr)(stimCode).tCDR = t(tIndex);
                cdrRes.(paradigmStr(pN)).(dateStr)(stimCode).chMeanCDR = chMeanSel2{pN}{stimCode, pos};
                cdrRes.(paradigmStr(pN)).(dateStr)(stimCode).stimStr = RawRes(stimCode).stimStr;
                % save(matPath{recordCode}, "RawRes");

                for ch = 1 : size(chMeanSel2{pN}{stimCode, pos}, 1)
                    if paradigmKeyword == "LowHigh43444546" || paradigmKeyword == "ICIThr401234"
                        cdrPlot.(strcat('ch', num2str(ch))){recordCode}(:, 2*(length(RawRes) - stimCode + 1) - 1) = t(tIndex);
                        cdrPlot.(strcat('ch', num2str(ch))){recordCode}(:, 2*(length(RawRes) - stimCode + 1)) = chMeanSel2{pN}{stimCode, pos}(ch , :)';
                    elseif paradigmKeyword == "offset"
                        cdrPlot.(strcat('ch', num2str(ch))){recordCode, 2 - mod(stimCode , 2)}(:, 2 * ceil(stimCode / 2) - 1) = t(tIndex);
                        cdrPlot.(strcat('ch', num2str(ch))){recordCode, 2 - mod(stimCode , 2)}(:, 2* ceil(stimCode / 2)) = chMeanSel2{pN}{stimCode, pos}(ch , :)';
                    else
                        cdrPlot.(strcat('ch', num2str(ch))){recordCode}(:, 2*stimCode - 1) = t(tIndex);
                        cdrPlot.(strcat('ch', num2str(ch))){recordCode}(:, 2*stimCode) = chMeanSel2{pN}{stimCode, pos}(ch , :)';
                    end
                end
            end
        end
    end
end

%% save
if plotMultiFigure
    %             % reg vs irreg
    %             Fig_MultiWave = plotRawWave(chMeanSel{pN}{1 , 1}, [], selectWin);
    %             Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{1, 2}, [], selectWin, 'k');

    % 4,8,20,40,80
    for posN = 1 : 2 % pfc

        Fig_MultiWave = plotRawWave(chMeanSel{1}{1 , posN}, [], selectWin); % click train
        Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel2{1}{1, posN}, [], selectWin, '#0000FF'); % tone

        % get all axes
        allAxes2 = findobj(Fig_MultiWave, "Type", "axes");

        % set axes

        scaleAxes(Fig_MultiWave,'y', [-1 * yScale(posN) yScale(posN) ]);
        setAxes(Fig_MultiWave, 'yticklabel', '');
        setAxes(Fig_MultiWave, 'xticklabel', '');
        setAxes(Fig_MultiWave, 'visible', 'off');
        % reset lineWidth, lineColor
        setLine(Fig_MultiWave, "LineWidth", 1.5, "LineStyle", "-")
        %     setLine(Fig_MultiWave, "Color", "black" , "LineStyle", "-");
        setLine(Fig_MultiWave, "YData", [-1 * yScale(posN) yScale(posN) ], "LineStyle", "--");
        setLine(Fig_MultiWave, "LineWidth", 1, "LineStyle", "--");
        % reset figure size
        set(Fig_MultiWave, "outerposition", [300, 100, 800, 670]);

        % plot layout
        if contains(matPath{recordCode}, 'cc')
            plotLayout(Fig_MultiWave, posN, 0.3);
        else

            plotLayout(Fig_MultiWave, posN + 2, 0.3);
        end


        %% save
        print(Fig_MultiWave, strcat("E:\ECoG\corelDraw\PDF\", dateStr , paradigmStr,  posStr(posN)), "-djpeg", "-r300");
        close all
    end
end
