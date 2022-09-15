clear all; clc
monkeyId = ["chouchou", "xiaoxiao"];
posStr = ["LAuC", "LPFC"];
plotFigure = 0;
reprocess = 0;
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
paradigmKeyword = ["LongTerm4[^0]", "NormSqrtLongTerm4[^0]", "NormLongTerm4[^0]", "LongTermNew4[^0]"];
% paradigmKeyword = ["NormSqrtLongTerm4[^0]", "NormLongTerm4[^0]"];

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
        matPath = getSubfoldPath(rootPath,'filterResHP0o1Hz.mat', strcat(paradigmKeyword(pN), ".*", posStr(1)));
        for recordCode = 1 : length(matPath)
%                 for recordCode = selectRecord
            for pos = posIndex
                matPath = getSubfoldPath(rootPath,'filterResHP0o1Hz.mat', strcat(paradigmKeyword(pN), ".*", posStr(pos)));
                
                temp = strsplit(matPath{recordCode}, '\');
                dateStr = temp{5};
                savePath = fullfile("E:\ECoG\corelDraw\jpgHP0o1Hz\RegIrreg", paradigmStr(pN), dateStr) ;
                if ~exist(savePath, 'dir') || reprocess
                    load(matPath{recordCode});
                    plotFigure = 1;
                else
                    plotFigure = 0;
                    continue
                end
                for stimCode = 1 : length(filterRes)
                    clearvars -except processCDR savePath reprocess id monkeyId recordCode matPath selectWin selectRecord posStr pos posIndex pos stimCode paradigmKeyword paradigmStr pN filterRes rootPath cdrRes cdrPlot plotFigure dateStr plotCh chMeanSel yScale s1OnsetOrS2Onset 
                    % get data
                    chMean = filterRes(stimCode).chMean;
                    t = filterRes(stimCode).t;
                    stimStr = filterRes(stimCode).stimStr;

                    if s1OnsetOrS2Onset == 1
                        t = filterRes(stimCode).t + filterRes(stimCode).S1Duration;
                        selectWin = [0 diff(selectWin)] - 200;
                    end

                    tIndex = find(t > selectWin(1) & t < selectWin(2));
                    tIndex = tIndex(1 : floor(length(tIndex) / 10) * 10);
                    chMeanSel{pN}{stimCode, pos}= chMean(:, tIndex);

                end
%                 clear cdrPlot cdrRes
            end



            %% save
            if  plotFigure
                if ~exist(savePath, 'dir')
                    mkdir(savePath)
                    % 4
                    for posN = 1 : 2 % pfc
%         % reg vs irreg
                        Fig_RegIrreg = plotRawWave(chMeanSel{pN}{1 , posN}, [], selectWin, "Reg vs Irreg", [8, 8], (1 : 64)', "off");
                        Fig_RegIrreg = plotRawWave2(Fig_RegIrreg, chMeanSel{pN}{3, posN}, [], selectWin, 'k');
                        % set axes

                        scaleAxes(Fig_RegIrreg,'y', [-1 * yScale(posN) yScale(posN) ]);
                        setAxes(Fig_RegIrreg, 'yticklabel', '');
                        setAxes(Fig_RegIrreg, 'xticklabel', '');
                        setAxes(Fig_RegIrreg, 'visible', 'off');
                        % reset lineWidth, lineColor
                        setLine(Fig_RegIrreg, "LineWidth", 1.5, "LineStyle", "-")
                        %     setLine(Fig_MultiWave, "Color", "black" , "LineStyle", "-");
                        setLine(Fig_RegIrreg, "YData", [-1 * yScale(posN) yScale(posN) ], "LineStyle", "--");
                        setLine(Fig_RegIrreg, "LineWidth", 1, "LineStyle", "--");
                        % reset figure size

                        set(Fig_RegIrreg, "outerposition", [300, 100, 800, 670]);

                        % plot layout
                        if contains(matPath{recordCode}, 'cc')
                            plotLayout(Fig_RegIrreg, posN, 0.3);
                        else

                            plotLayout(Fig_RegIrreg, posN + 2, 0.3);
                        end

                        % save
                        mkdir(savePath)
                        print(Fig_RegIrreg, fullfile(savePath, strcat("4ms_", posStr(posN))), "-djpeg", "-r300");
                        close all
               

                    end
                else
                    continue
                end
            end
        end
    end
end