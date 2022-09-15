clear all; clc
monkeyId = ["chouchou", "xiaoxiao"];
posStr = ["LAuC", "LPFC"];
plotFigure = 1;
reprocess = 0;
processCDR = 1;
plotMultiFigure = 1;
selectWin = [-200 600];
yScale = [60 30];
% idIdx = input('Monkey ID: 1-chouchou, 2-xiaoxiao \n');
idIdx = 1:2;
% posIndex = input('recording area : 1-AC, 2-PFC \n');
posIndex = 1:2;
% s1OnsetOrS2Onset = input('zero is : 1-s1 onset, 2-s2 onset \n'); % 1: start, 2: trans
s1OnsetOrS2Onset = 2; % 1: start, 2: trans

% filterResDataPath = getSubfoldPath('E:\ECoG','Res.mat','^(?!.*Merge)');

% paradigmKeyword = "Insert"; %Insert, RegInIrreg4o32, LowHigh43444546, ICIThr401234, Var3, offset, Tone
paradigmKeyword = ["LongTerm4[^0]", "LongTerm8[^0]", "LongTerm20", "LongTerm40", "LongTerm80"];
% paradigmKeyword = ["NormSqrtLongTerm4[^0]", "NormLongTerm4[^0]"];
% paradigmKeyword = ["ratioDetectCommon", "ratioDetectSmall", "ratioDetectLarge", "ICIBind"];
% paradigmKeyword = ["ICIThr401234", "Insert", "RegInIrreg4o32", "LowHigh43444546", "Var3", "Tone"]; %Insert, RegInIrreg4o32, LowHigh43444546, ICIThr401234, Var3, offset, Tone

paradigmStr = strrep(paradigmKeyword, '[^0]', '');



for id = idIdx
    rootPath = fullfile('E:\ECoG\matData', monkeyId(id));
% display recording tabel
matPath = getSubfoldPath(rootPath,'filterResHP0o1Hz.mat', strcat(paradigmKeyword(1), ".*", posStr(1)));
% recordTable = cell2table([num2cell((1 : length(matPath))'), matPath], "VariableNames", {'recordingCode', 'matPath'});
% fig = uifigure('Position', [500 100 800 600]);
% uit = uitable(fig, 'Data', recordTable, 'Position', [0 0 800 600] , 'ColumnWidth', {200,600});
% selectRecord = input('selected record ID: \n');
% close(fig);
    for pN = 1 : length(paradigmKeyword)
        matPathTemp = getSubfoldPath(rootPath,'filterResHP0o1Hz.mat', strcat(paradigmKeyword(pN), ".*", posStr(1)));
        for recordCode = 1 : length(matPathTemp)
%                 for recordCode = selectRecord
            for pos = posIndex
                matPath = getSubfoldPath(rootPath,'filterResHP0o1Hz.mat', strcat(paradigmKeyword(pN), ".*", posStr(pos)));
                
                temp = strsplit(matPath{recordCode}, '\');
                dateStr = temp{5};
                savePath = fullfile("E:\ECoG\corelDraw\jpgHP0o1Hz", paradigmStr(pN), dateStr) ;
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
                    clearvars -except processCDR savePath reprocess id monkeyId recordCode matPath selectWin selectRecord posStr pos posIndex pos stimCode paradigmKeyword paradigmStr pN filterRes rootPath cdrRes cdrPlot plotFigure dateStr plotCh chMeanSel yScale s1OnsetOrS2Onset plotMultiFigure
                    % get data
                    chMean = filterRes(stimCode).chMean;
                    t = filterRes(stimCode).t;
                    stimStr = filterRes(stimCode).stimStr;

                    if s1OnsetOrS2Onset == 1
                        window = [0 11000];
                    elseif s1OnsetOrS2Onset == 2
                        window = [0 11000] - filterRes(stimCode).S1Duration;
                    end

                    tIndex = find(t > selectWin(1) & t < selectWin(2));
                    tIndex = tIndex(1 : floor(length(tIndex) / 10) * 10);
                    chMeanSel{pN}{stimCode, pos}= chMean(:, tIndex);

                    % data for corelDraw
                    filterRes(stimCode).tCDR = t(tIndex);
                    filterRes(stimCode).chMeanCDR = chMeanSel{pN}{stimCode, pos};

                    cdrRes.(posStr(pos)).(paradigmStr(pN)).(dateStr)(stimCode).tCDR = t(tIndex);
                    cdrRes.(posStr(pos)).(paradigmStr(pN)).(dateStr)(stimCode).chMeanCDR = chMeanSel{pN}{stimCode, pos};
                    cdrRes.(posStr(pos)).(paradigmStr(pN)).(dateStr)(stimCode).stimStr = filterRes(stimCode).stimStr;
                    % save(matPath{recordCode}, "filterRes");

                    for ch = 1 : size(chMeanSel{pN}{stimCode, pos}, 1)
                        if paradigmStr(pN) == "LowHigh4043444546" || paradigmStr(pN) == "ICIThr401234"
                            cdrPlot.(paradigmStr(pN)).(posStr(pos)).(strcat('ch', num2str(ch))).(dateStr)(:, 2*(length(filterRes) - stimCode + 1) - 1) = t(tIndex);
                            cdrPlot.(paradigmStr(pN)).(posStr(pos)).(strcat('ch', num2str(ch))).(dateStr)(:, 2*(length(filterRes) - stimCode + 1)) = chMeanSel{pN}{stimCode, pos}(ch , :)';
                        elseif paradigmStr(pN) == "offset"
                            cdrPlot.(paradigmStr(pN)).(posStr(pos)).(strcat('ch', num2str(ch))).(dateStr){1, 2 - mod(stimCode , 2)}(:, 2 * ceil(stimCode / 2) - 1) = t(tIndex);
                            cdrPlot.(paradigmStr(pN)).(posStr(pos)).(strcat('ch', num2str(ch))).(dateStr){1, 2 - mod(stimCode , 2)}(:, 2* ceil(stimCode / 2)) = chMeanSel{pN}{stimCode, pos}(ch , :)';
                        else
                            cdrPlot.(paradigmStr(pN)).(posStr(pos)).(strcat('ch', num2str(ch))).(dateStr)(:, 2*stimCode - 1) = t(tIndex);
                            cdrPlot.(paradigmStr(pN)).(posStr(pos)).(strcat('ch', num2str(ch))).(dateStr)(:, 2*stimCode) = chMeanSel{pN}{stimCode, pos}(ch , :)';
                        end
                    end
                end
%                 clear cdrPlot cdrRes
            end



            %% save
            if plotMultiFigure && plotFigure
                if ~exist(savePath, 'dir')
                    mkdir(savePath)
                    for posN = 1 : 2 % 1:ac, 2:pfc
                        stimType = size(chMeanSel{pN}, 1);
                        switch stimType
                            case 5
                                colors = ["#FF0000", "#FFA500", "#0000FF", "#000000", "#AAAAAA"];
                            case 6
                                colors = ["#FF0000", "#B03060", "#FFA500", "#0000FF", "#000000", "#AAAAAA"];
                        end
                        
                        if paradigmKeyword(pN) == "ICIBind"
                            % min order colored red
                            for stimN = 1 : stimType
                                if stimN == 1
                                    Fig_MultiWave = plotRawWave(chMeanSel{pN}{stimN , posN}, [], selectWin, paradigmKeyword(pN), [8, 8], (1 : 64)', "on");
                                else
                                    lineSetting.color = colors(stimN);
                                    Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{stimN, posN}, [], selectWin, lineSetting);
                                end
                            end

                        else
                                % max order colored red
                            for stimN = 1 : stimType
                                if stimN == 1
                                    Fig_MultiWave = plotRawWave(chMeanSel{pN}{stimType - stimN + 1 , posN}, [], selectWin, paradigmKeyword(pN), [8, 8], (1 : 64)', "on");
                                else
                                    lineSetting.color = colors(stimN);
                                    Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{stimType - stimN + 1, posN}, [], selectWin, lineSetting);
                                end
                            end
                                        
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