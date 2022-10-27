clear all; clc
monkeyId = ["chouchou", "xiaoxiao"];
posStr = ["LAuC", "LPFC"];
plotFigure = 0;
reprocess = 0;
processCDR = 1;
plotMultiFigure = 1;
selectWin = [-200 600];
yScale = [80 40];
% idIdx = input('Monkey ID: 1-chouchou, 2-xiaoxiao \n');
idIdx = 1:2;
% posIndex = input('recording area : 1-AC, 2-PFC \n');
posIndex = 1:2;
% s1OnsetOrS2Onset = input('zero is : 1-s1 onset, 2-s2 onset \n'); % 1: start, 2: trans
s1OnsetOrS2Onset = 2; % 1: start, 2: trans

% paradigmKeyword = ["LongTerm4[^0]", "LongTerm8[^0]", "LongTerm20", "LongTerm40", "LongTerm80"];
paradigmKeyword = ["LongTerm4[^0]"];
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
    matPath = getSubfoldPath(rootPath,'filterResHP0o5Hz.mat', strcat(paradigmKeyword(end), ".*", posStr(1)));
%       for recordCode = selectRecord

    for recordCode = 1 : length(matPath)
        temp = strsplit(matPath{recordCode}, '\');
        dateStr = temp{5};
        savePath = fullfile("E:\ECoG\corelDraw\RegIrregFFT0o1Hz",dateStr);
        %     for pN = 1
        for pN = 1 : length(paradigmKeyword)
            for pos = posIndex
                matPath = getSubfoldPath(rootPath,'filterResHP0o1Hz.mat', strcat(paradigmKeyword(pN), ".*", posStr(pos)));
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
                    clearvars -except meanFFT fftMean powMean chMean processCDR monkeyId id savePath savePath2 recordCode  matPath selectWin reprocess selectRecord posStr pos posIndex pos stimCode paradigmKeyword paradigmStr pN filterRes rootPath cdrRes cdrPlot plotFigure dateStr plotCh yScale s1OnsetOrS2Onset plotMultiFigure
                    % set window
                    if s1OnsetOrS2Onset == 1
                        window = [-2000 11000];
                        t = filterRes(stimCode).t + filterRes(stimCode).S1Duration;
                      
                    elseif s1OnsetOrS2Onset == 2
                        window = [-2000 11000] - filterRes(stimCode).S1Duration;
                    end
                    
                    % get data from filterRes.mat
                    fs = filterRes(stimCode).fs;
                    FDZData = filterRes(stimCode).FDZData;
                    FDZDataTemp = excludeTrials(FDZData, 0.1);
                    temp = changeCellRowNum(FDZDataTemp);
                    selectIdx = find(filterRes(stimCode).t < 0 & filterRes(stimCode).t > -4500);

                    % FFT followed by mean
                    [f, Pow, P] = cellfun(@(x) mFFT(x(:, selectIdx), fs), temp, 'UniformOutput', false);
                    Fs = f{1};
                    fftMean{pN}{stimCode, pos} = cell2mat(cellfun(@(x) mean(x), P, 'UniformOutput', false));
                    powMean{pN}{stimCode, pos} = cell2mat(cellfun(@(x) mean(x), Pow, 'UniformOutput', false));  
                    % mean followed by FFT and TFA

                    chMean{pN}{stimCode, pos} = cell2mat(cellfun(@(x) mean(x), temp, "UniformOutput", false));
                    chMean2{pN}{stimCode, pos} = cell2mat(cellfun(@(x) mean(x(:, selectIdx)), temp, "UniformOutput", false));
                    [f, Pow, meanFFT{pN}{stimCode, pos} ] =  mFFT(chMean2{pN}{stimCode, pos}, fs);
                    Fs2 = f;
                    
                    %             print(Fig_wave, strcat(PEPATH, AREANAME, "_PE_Raw_", num2str(dIndex), "_", DateStr), "-djpeg", "-r200");
                end

            end
        end

%          clear cdrPlot cdrRes

hilbert

%% Reg vs Irreg
        if plotMultiFigure && plotFigure
            ICIStr = ["4ms", "8ms", "20ms", "40ms", "80ms"];
            if ~exist(savePath, 'dir')
                for posN = 1 : 2
                        % reg vs irreg
                        Fig_RegIrregFFT = plotFFT(fftMean{1}{1 , posN}, Fs, [min(Fs), max(Fs)], "FFT mean", [8, 8], (1 : 64)', "off");
                        Fig_RegIrregFFT = plotFFT2(Fig_RegIrregFFT, fftMean{1}{3, posN}, Fs, [min(Fs), max(Fs)], 'k');
                        Fig_RegIrregPow = plotFFT(powMean{1}{1 , posN}, Fs, [min(Fs), max(Fs)], "Pow mean", [8, 8], (1 : 64)', "off");
                        Fig_RegIrregPow = plotFFT2(Fig_RegIrregPow, powMean{1}{3, posN}, Fs, [min(Fs), max(Fs)], 'k');
                        Fig_RegIrregMeanFFT = plotFFT(meanFFT{1}{1 , posN}, Fs2, [min(Fs2), max(Fs2)], "mean FFT", [8, 8], (1 : 64)', "off");
                        Fig_RegIrregMeanFFT = plotFFT2(Fig_RegIrregMeanFFT, meanFFT{1}{3 , posN}, Fs2, [min(Fs2), max(Fs2)], 'k');
                        Fig_RegTFA = plotTFA(chMean{1}{1 , posN}, fs, fs, window, 'mean reg TFA', [8, 8], "off");
                        Fig_IrregTFA = plotTFA(chMean{1}{3 , posN}, fs, fs, window, 'mean irreg TFA', [8, 8], "off");
                        Fig_RegIrregTFA = plotTFACompare(chMean{1}{1 , posN}, chMean{1}{3 , posN}, fs, fs, window, 'mean irreg TFA', [8, 8], "off");
                        % set axes


                        scaleAxes([Fig_RegIrregFFT Fig_RegIrregPow Fig_RegIrregMeanFFT],'x', [0 10]);
                        scaleAxes([Fig_RegIrregFFT Fig_RegIrregPow Fig_RegIrregMeanFFT],'y', [0 20]);
                        scaleAxes([Fig_RegTFA Fig_IrregTFA],'x', window);
                        scaleAxes([Fig_RegTFA Fig_IrregTFA],'c', [0 15]);
                        scaleAxes([Fig_RegIrregTFA],'c', [-10 10]);
%                         setAxes([Fig_RegTFA Fig_IrregTFA Fig_RegIrregTFA], 'visible', 'off');

%                         % reset figure size
% 
%                         set(Fig_RegIrreg, "outerposition", [300, 100, 800, 670]);

                        % plot layout
                        if contains(matPath{recordCode}, 'cc')
                            plotLayout([Fig_RegIrregFFT Fig_RegIrregPow Fig_RegIrregMeanFFT]  , posN, 0.3);
                        else
                            plotLayout([Fig_RegIrregFFT Fig_RegIrregPow Fig_RegIrregMeanFFT]  , posN + 2, 0.3);
                        end

                        % save
                        mkdir(savePath)
                        print(Fig_RegIrregFFT, fullfile(savePath, strcat(paradigmStr, "_FFT_", posStr(posN))), "-djpeg", "-r300");
                        print(Fig_RegIrregPow, fullfile(savePath, strcat(paradigmStr, "_Pow_", posStr(posN))), "-djpeg", "-r300");
                        print(Fig_RegIrregMeanFFT, fullfile(savePath, strcat(paradigmStr, "_meanFFT_", posStr(posN))), "-djpeg", "-r300");                        
                        print(Fig_RegTFA, fullfile(savePath, strcat(paradigmStr, "_RegTFA_", posStr(posN))), "-djpeg", "-r300");
                        print(Fig_IrregTFA, fullfile(savePath, strcat(paradigmStr, "_IrregTFA_", posStr(posN))), "-djpeg", "-r300");
                        print(Fig_RegIrregTFA, fullfile(savePath, strcat(paradigmStr, "_RegIrregTFA_", posStr(posN))), "-djpeg", "-r300");
                        close all
                    
                end
            end
        end

    end
end
