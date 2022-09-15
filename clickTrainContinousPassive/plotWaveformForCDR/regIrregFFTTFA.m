clear all; clc
monkeyId = ["chouchou", "xiaoxiao"];
posStr = ["LAuC", "LPFC"];
plotFigure = 0;
reprocess = 0;
processCDR = 1;
plotMultiFigure = 1;
selectWin = [-200 600]
yScale = [80 40];
% idIdx = input('Monkey ID: 1-chouchou, 2-xiaoxiao \n');
idIdx = 1:2;
% posIndex = input('recording area : 1-AC, 2-PFC \n');
posIndex = 1:2;
% s1OnsetOrS2Onset = input('zero is : 1-s1 onset, 2-s2 onset \n'); % 1: start, 2: trans
s1OnsetOrS2Onset = 2; % 1: start, 2: trans

paradigmKeyword = ["LongTerm4[^0]", "LongTerm8[^0]", "LongTerm20", "LongTerm40", "LongTerm80"];
% paradigmKeyword = ["LongTerm4[^0]"];
paradigmStr = strrep(paradigmKeyword, '[^0]', '');
% display recording tabel
% matPath = getSubfoldPath(rootPath,'filterRes.mat', strcat(paradigmKeyword(1), ".*", posStr(1)));
% recordTable = cell2table([num2cell((1 : length(matPath))'), matPath], "VariableNames", {'recordingCode', 'matPath'});
% fig = uifigure('Position', [500 100 800 600]);
% uit = uitable(fig, 'Data', recordTable, 'Position', [0 0 800 600] , 'ColumnWidth', {200,600});
% selectRecord = input('selected record ID: \n');
% close(fig);

for id = idIdx
    rootPath = fullfile('E:\ECoG\matData', monkeyId(id));
    matPath = getSubfoldPath(rootPath,'filterResHP1Hz.mat', strcat(paradigmKeyword(5), ".*", posStr(1)));
%       for recordCode = selectRecord

    for recordCode = 1 : length(matPath)
        temp = strsplit(matPath{recordCode}, '\');
        dateStr = temp{5};
        savePath = fullfile("E:\ECoG\corelDraw\jpgHP1Hz\diffICIBaseFFT",dateStr);
        savePath2 = fullfile("E:\ECoG\corelDraw\jpgHP1Hz\RegIrregFFT",dateStr);
        %     for pN = 1
        for pN = 1 : length(paradigmKeyword)
            for pos = posIndex
                matPath = getSubfoldPath(rootPath,'filterResHP1Hz.mat', strcat(paradigmKeyword(pN), ".*", posStr(pos)));
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
                    clearvars -except fftMean powMean chMean processCDR monkeyId id savePath savePath2 recordCode  matPath selectWin reprocess selectRecord posStr pos posIndex pos stimCode paradigmKeyword paradigmStr pN filterRes rootPath cdrRes cdrPlot plotFigure dateStr plotCh yScale s1OnsetOrS2Onset plotMultiFigure
                    % set window
                    if s1OnsetOrS2Onset == 1
                        window = [0 11000];
                        t = filterRes(stimCode).t + filterRes(stimCode).S1Duration;
                        selectWin = [0 diff(selectWin)];
                    elseif s1OnsetOrS2Onset == 2
                        window = [0 11000] - filterRes(stimCode).S1Duration;
                    end
                    
                    % get data from filterRes.mat
                    fs = filterRes(stimCode).fs;
                    FDZData = filterRes(stimCode).FDZData;
                    FDZDataTemp = excludeTrials(FDZData, 0.1);
                    temp = changeCellRowNum(FDZDataTemp);
                    % FFT followed by mean
                    [f, Pow, P] = cellfun(@(x) mFFT(x, fs), temp, 'UniformOutput', false);
                    Fs = f{1};
                    fftMean{pN}{stimCode, pos} = cell2mat(cellfun(@(x) mean(x), P, 'UniformOutput', false));
                    powMean{pN}{stimCode, pos} = cell2mat(cellfun(@(x) mean(x), Pow, 'UniformOutput', false));  
                    % mean followed by FFT and TFA
                    chMean{pN}{stimCode, pos} = cell2mat(cellfun(@mean, temp, "UniformOutput", false));

                    %             print(Fig_wave, strcat(PEPATH, AREANAME, "_PE_Raw_", num2str(dIndex), "_", DateStr), "-djpeg", "-r200");
                end

            end
        end

%          clear cdrPlot cdrRes



%% Reg vs Irreg
        if plotMultiFigure && plotFigure
            ICIStr = ["4ms", "8ms", "20ms", "40ms", "80ms"];
            if ~exist(savePath2, 'dir')
                for posN = 1 : 2
                        %         % reg vs irreg
                        Fig_RegIrregFFT = plotFFT(fftMean{1}{1 , posN}, Fs, [min(Fs), max(Fs)], "FFT mean", [8, 8], (1 : 64)', "on");
                        Fig_RegIrregFFT = plotFFT2(Fig_RegIrregFFT, fftMean{1}{3, posN}, Fs, [min(Fs), max(Fs)], 'k');
                        Fig_RegIrregPow = plotFFT(powMean{1}{1 , posN}, Fs, [min(Fs), max(Fs)], "Pow mean", [8, 8], (1 : 64)', "on");
                        Fig_RegIrregPow = plotFFT2(Fig_RegIrregPow, powMean{1}{3, posN}, Fs, [min(Fs), max(Fs)], 'k');
                        Fig_RegTFA = plotTFA(chMean{1}{1 , posN}, fs, fs, window, 'mean reg TFA', [8, 8], "on");
                        Fig_IrregTFA = plotTFA(chMean{1}{3 , posN}, fs, fs, window, 'mean irreg TFA', [8, 8], "on");

                        % set axes


                        scaleAxes([Fig_RegIrregFFT Fig_RegIrregPow],'x', [0 10]);
                        setAxes(Fig_RegIrreg, 'visible', 'off');

                        % reset figure size

                        set(Fig_RegIrreg, "outerposition", [300, 100, 800, 670]);

                        % plot layout
                        if contains(matPath{recordCode}, 'cc')
                            plotLayout(Fig_RegIrreg, posN, 0.3);
                        else

                            plotLayout(Fig_RegIrreg, posN + 2, 0.3);
                        end

                        % save
                        mkdir(savePath2)
                        print(Fig_RegIrreg, fullfile(savePath2, strcat(ICIStr(1), "_", posStr(posN))), "-djpeg", "-r300");
                        close all
                    
                end
            end
        end


%% 4,8,20,40,80
        if plotMultiFigure && plotFigure
            if ~exist(savePath, 'dir')
                regIrreg = ["RegOrd", "RegRev", "IrregOrd", "IrregRev"];
                for posN = 1 : 2 

                    
                    for stimPlot = 1:4


                        Fig_MultiWave = plotRawWave(chMeanSel{1}{stimPlot , posN}, [], selectWin, "diffICI", [8, 8], (1 : 64)', "off");
                        Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{5}{stimPlot, posN}, [], selectWin, '#AAAAAA');
                        Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{4}{stimPlot, posN}, [], selectWin, '#000000');
                        Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{3}{stimPlot, posN}, [], selectWin, '#0000FF');
                        Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{2}{stimPlot, posN}, [], selectWin, '#FFA500');
                        Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{1}{stimPlot, posN}, [], selectWin, '#FF0000');

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

                        % save
                        mkdir(savePath)
                        print(Fig_MultiWave, fullfile(savePath,strcat(regIrreg(stimPlot) ,posStr(posN))), "-djpeg", "-r300");
                        close all

                    end


                end
            else
                continue
            end
        end
    end
end
