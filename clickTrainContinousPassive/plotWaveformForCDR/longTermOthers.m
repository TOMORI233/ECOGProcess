clear all; clc
monkeyId = ["chouchou", "xiaoxiao"];
posStr = ["LAuC", "LPFC"];
plotFigure = 0;
plotMultiFigure = 1;
selectWin = [-200 600];
yScale = [60 30];
idIdx = input('Monkey ID: 1-chouchou, 2-xiaoxiao \n');
posIndex = input('recording area : 1-AC, 2-PFC \n');
s1OnsetOrS2Onset = input('zero is : 1-s1 onset, 2-s2 onset \n'); % 1: start, 2: trans

% rawResDataPath = getSubfoldPath('E:\ECoG','Res.mat','^(?!.*Merge)');

% paradigmKeyword = "ICIThr401234"; %Insert, RegInIrreg4o32, LowHigh43444546, ICIThr401234, Var3, offset, Tone
paradigmKeyword = ["ICIThr401234", "Insert", "RegInIrreg4o32", "LowHigh43444546", "Var3", "Tone"]; %Insert, RegInIrreg4o32, LowHigh43444546, ICIThr401234, Var3, offset, Tone

paradigmStr = strrep(paradigmKeyword, '[^0]', '');
% display recording tabel
% matPath = getSubfoldPath(rootPath,'RawRes.mat', strcat(paradigmKeyword(1), ".*", posStr(1)));
% recordTable = cell2table([num2cell((1 : length(matPath))'), matPath], "VariableNames", {'recordingCode', 'matPath'});
% fig = uifigure('Position', [500 100 800 600]);
% uit = uitable(fig, 'Data', recordTable, 'Position', [0 0 800 600] , 'ColumnWidth', {200,600});
% selectRecord = input('selected record ID: \n');
% close(fig);


for id = idIdx
    rootPath = fullfile('E:\ECoG\matData', monkeyId(id));

    for pN = 1 : length(paradigmKeyword)
        matPath = getSubfoldPath(rootPath,'RawRes.mat', strcat(paradigmKeyword(pN), ".*", posStr(1)));
        for recordCode = 1 : length(matPath)
            %     for recordCode = selectRecord
            for pos = posIndex
                matPath = getSubfoldPath(rootPath,'RawRes.mat', strcat(paradigmKeyword(pN), ".*", posStr(pos)));
                load(matPath{recordCode});
                temp = strsplit(matPath{recordCode}, '\');
                dateStr = temp{5};
                for stimCode = 1 : length(RawRes)
                    clearvars -except id monkeyId recordCode matPath selectWin selectRecord posStr pos posIndex pos stimCode paradigmKeyword paradigmStr pN RawRes rootPath cdrRes cdrPlot plotFigure dateStr plotCh chMeanSel yScale s1OnsetOrS2Onset plotMultiFigure
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
                    chMeanSel{pN}{stimCode, pos}= chMean(:, tIndex);

                    if plotFigure
                        % preview result in selected window
                        %                 Fig_wave = plotRawWave(chMeanSel{pN}{stimCode, pos}, [], selectWin, strcat(paradigmStr, RawRes(stimCode).stimStr));
                        Fig_wave = plotRawWave(chMeanSel{pN}{stimCode, pos}, [], selectWin);

                        % get all axes
                        allAxes = findobj(Fig_wave, "Type", "axes");

                        % set axes
                        scaleAxes(Fig_wave,'y', [-1 * yScale(pos) yScale(pos) ]);
                        setAxes(Fig_wave, 'yticklabel', '');
                        setAxes(Fig_wave, 'xticklabel', '');

                        % reset lineWidth
                        for axesN = 1 : length(allAxes)
                            allAxes(axesN).Children(2).LineWidth = 3;
                        end

                        % reset figure size
                        Fig_wave.Position = [300, 100, 800, 670];

                        % plot layout
                        if contains(matPath{recordCode}, 'cc')
                            plotLayout(Fig_wave, pos);
                        else

                            plotLayout(Fig_wave, pos + 2);

                        end
                    end


                    % data for corelDraw
                    RawRes(stimCode).tCDR = t(tIndex);
                    RawRes(stimCode).chMeanCDR = chMeanSel{pN}{stimCode, pos};

                    cdrRes.(paradigmStr(pN)).(dateStr)(stimCode).tCDR = t(tIndex);
                    cdrRes.(paradigmStr(pN)).(dateStr)(stimCode).chMeanCDR = chMeanSel{pN}{stimCode, pos};
                    cdrRes.(paradigmStr(pN)).(dateStr)(stimCode).stimStr = RawRes(stimCode).stimStr;
                    % save(matPath{recordCode}, "RawRes");

                    for ch = 1 : size(chMeanSel{pN}{stimCode, pos}, 1)
                        if paradigmKeyword(pN) == "LowHigh43444546" || paradigmKeyword(pN) == "ICIThr401234"
                            cdrPlot.(strcat('ch', num2str(ch))){recordCode, pos}(:, 2*(length(RawRes) - stimCode + 1) - 1) = t(tIndex);
                            cdrPlot.(strcat('ch', num2str(ch))){recordCode, pos}(:, 2*(length(RawRes) - stimCode + 1)) = chMeanSel{pN}{stimCode, pos}(ch , :)';
                        elseif paradigmKeyword(pN) == "offset"
                            cdrPlot.(strcat('ch', num2str(ch))){recordCode, 2 - mod(stimCode , 2)}(:, 2 * ceil(stimCode / 2) - 1) = t(tIndex);
                            cdrPlot.(strcat('ch', num2str(ch))){recordCode, 2 - mod(stimCode , 2)}(:, 2* ceil(stimCode / 2)) = chMeanSel{pN}{stimCode, pos}(ch , :)';
                        else
                            cdrPlot.(strcat('ch', num2str(ch))){recordCode, pos}(:, 2*stimCode - 1) = t(tIndex);
                            cdrPlot.(strcat('ch', num2str(ch))){recordCode, pos}(:, 2*stimCode) = chMeanSel{pN}{stimCode, pos}(ch , :)';
                        end
                    end
                end
                clear cdrPlot cdrRes
            end



            %% save
            savePath = fullfile("E:\ECoG\corelDraw\jpg", paradigmStr(pN), dateStr) ;
            if plotMultiFigure
                if ~exist(savePath, 'dir')
                    mkdir(savePath)
                    %             % reg vs irreg
                    %             Fig_MultiWave = plotRawWave(chMeanSel{pN}{1 , 1}, [], selectWin);
                    %             Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{1, 2}, [], selectWin, 'k');

                    % 4,8,20,40,80
                    for posN = 1 : 2 % pfc

                        if paradigmKeyword(pN) == "LowHigh43444546" || paradigmKeyword(pN) == "ICIThr401234"
                            Fig_MultiWave = plotRawWave(chMeanSel{pN}{1 , posN}, [], selectWin);
                            Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{1, posN}, [], selectWin, '#000000');
                            Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{2, posN}, [], selectWin, '#0000FF');
                            Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{3, posN}, [], selectWin, '#FFA500');
                            Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{4, posN}, [], selectWin, '#FF0000');
                        else
                            Fig_MultiWave = plotRawWave(chMeanSel{pN}{1 , posN}, [], selectWin);
                            Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{4, posN}, [], selectWin, '#000000');
                            Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{3, posN}, [], selectWin, '#0000FF');
                            Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{2, posN}, [], selectWin, '#FFA500');
                            Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{1, posN}, [], selectWin, '#FF0000');
                        end

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
                        print(Fig_MultiWave, fullfile(savePath,  posStr(posN)), "-djpeg", "-r300");
                        close all

                    end
                else
                    continue
                end
            end
        end
    end
end