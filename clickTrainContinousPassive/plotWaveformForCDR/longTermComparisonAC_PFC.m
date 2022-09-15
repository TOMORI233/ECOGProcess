clear all; clc
monkeyId = ["chouchou", "xiaoxiao"];
posStr = ["LAuC", "LPFC"];
plotFigure = 1;
reprocess = 1;
idIdx = 1:2;
s1OnsetOrS2Onset = 2; % 1: start, 2: trans
paradigmKeyword = "LongTerm4[^0]";
paradigmStr = strrep(paradigmKeyword, '[^0]', '');

for id = 2
    rootPath = fullfile('E:\ECoG\matData', monkeyId(id));
    FDZDataACAll.(monkeyId(id)) = cell(4, 1);
    FDZDataPFCAll.(monkeyId(id)) = cell(4, 1);
    for pN = 1 : length(paradigmKeyword)
        date = "20220715";
        matPath = getSubfoldPath(rootPath,'filterResHP0o1Hz.mat', strcat(date, ".*", paradigmKeyword(pN), ".*", posStr(1)));
        for recordCode = 1 : length(matPath)
            date = "xx20220715";
            matPathAC = getSubfoldPath(rootPath,'filterResHP0o1Hz.mat', strcat(date, ".*", paradigmKeyword(pN), ".*", posStr(1)));
            matPathPFC = getSubfoldPath(rootPath,'filterResHP0o1Hz.mat', strcat(date, ".*", paradigmKeyword(pN), ".*", posStr(2)));
            temp = strsplit(matPath{recordCode}, '\');
            dateStr = temp{5};
            savePath = fullfile("E:\ECoG\corelDraw\jpgHP0o1Hz", "freq band response comparison", dateStr, "AC13-PFC13") ;
            if ~exist(savePath, 'dir') || reprocess
                load(matPathAC{recordCode});
                LAuC_FilterRes = filterRes;
                load(matPathPFC{recordCode});
                LPFC_FilterRes = filterRes;
            else
                plotFigure = 0;
                continue
            end



            %
            clearvars -except  reprocess LAuC_FilterRes LPFC_FilterRes FDZDataACAll FDZDataPFCAll  savePath id monkeyId recordCode matPath matPathAC matPathPFC   posStr  paradigmKeyword paradigmStr pN filterRes rootPath   plotFigure dateStr
            mkdir(savePath);
            if id == 1
                acSelect = 13;
                pfcSelect = 13;
            elseif id == 2
                acSelect = 35;
                pfcSelect = 13;
            end


            % figure settings
            margins = [0.04, 0.04, 0.08, 0.08];
            paddings = [0.01, 0.01, 0.02, 0.02];

            columns = 4;

            % raw data
            tempReg1 = LAuC_FilterRes(2);
            tempReg2 = LPFC_FilterRes(2);

            tempIrreg1 = LAuC_FilterRes(4);
            tempIrreg2 = LPFC_FilterRes(4);
            window = [tempReg1.t(2) tempReg1.t(end)];
            chNum = size(tempReg1.chMean);
            T = tempReg1.t;

            tempRegWave1 = tempReg1.chMean(acSelect, :); % AC regular
            tempIrregWave1 = tempIrreg1.chMean(acSelect, :); % AC irregular
            tempRegWave2 = tempReg2.chMean(pfcSelect, :); % PFC regular
            tempIrregWave2 = tempIrreg2.chMean(pfcSelect, :); % PFC irregular



            % get FDZData
            FDZReg1 = changeCellRowNum(tempReg1.FDZData);
            FDZIrreg1 = changeCellRowNum(tempIrreg1.FDZData);
            FDZReg2 = changeCellRowNum(tempReg2.FDZData);
            FDZIrreg2 = changeCellRowNum(tempIrreg2.FDZData);


            tempRegFDZ1 = FDZReg1{acSelect}; % AC regular
            tempIrregFDZ1 = FDZIrreg1{acSelect}; % AC irregular
            tempRegFDZ2 = FDZReg2{pfcSelect}; % PFC regular
            tempIrregFDZ2 = FDZIrreg2{pfcSelect}; % PFC irregular


            % time window
            zoomWin = [-300 600];
            zoomS2OnsetIdx = T>zoomWin(1) & T<zoomWin(2);
            zoomOnsetWinReg = zoomWin - LAuC_FilterRes(2).S1Duration;
            zoomS1OnsetIdx = T>zoomOnsetWinReg(1) & T<zoomOnsetWinReg(2);

            %% Zero-phase digital filtering
            % 1-10Hz order = 4
            % 10-20Hz order = 6
            bpRanges = [0 150;...
                0.5 3;... % δ delta
                3 7;... % θ theta
                7 13;... % α alfa
                13 30;... % β beta
                %     30 50;... % γ1 gamma
                %     50 100;... % γ2 gamma
                %     100 140;... % γ3 gamma
                ];


            bandStr = ["raw", "δ", "θ", "α", "β", "γ1", "γ2", "γ3"];
            for bN = 1 : size(bpRanges, 1)
                bpRange = bpRanges(bN, :);
                filtFs = tempReg1.fs;

                if bN > 1
                    bpFilt = designfilt('bandpassiir','FilterOrder',4, ...
                        'HalfPowerFrequency1',bpRange(1),'HalfPowerFrequency2',bpRange(2), ...
                        'SampleRate',filtFs);

                    filtRegWave1 = filtfilt(bpFilt, tempRegWave1);
                    filtIrregWave1 = filtfilt(bpFilt, tempIrregWave1);
                    filtRegWave2 = filtfilt(bpFilt, tempRegWave2);
                    filtIrregWave2 = filtfilt(bpFilt, tempIrregWave2);



                    filtRegFDZ1 = cellfun(@(x) filtfilt(bpFilt, x), array2VectorCell(tempRegFDZ1), 'UniformOutput', false);
                    filtIrregFDZ1 = cellfun(@(x) filtfilt(bpFilt, x), array2VectorCell(tempIrregFDZ1), 'UniformOutput', false);
                    filtRegFDZ2 = cellfun(@(x) filtfilt(bpFilt, x), array2VectorCell(tempRegFDZ2), 'UniformOutput', false);
                    filtIrregFDZ2 = cellfun(@(x) filtfilt(bpFilt, x), array2VectorCell(tempIrregFDZ2), 'UniformOutput', false);

                else
                    filtRegWave1 = tempRegWave1;
                    filtIrregWave1 = tempIrregWave1;
                    filtRegWave2 = tempRegWave2;
                    filtIrregWave2 = tempIrregWave2;


                    filtRegFDZ1 = array2VectorCell(tempRegFDZ1);
                    filtIrregFDZ1 = array2VectorCell(tempIrregFDZ1);
                    filtRegFDZ2 = array2VectorCell(tempRegFDZ2);
                    filtIrregFDZ2 = array2VectorCell(tempIrregFDZ2);



                end


                Fig(bN) = figure;
                maximizeFig(Fig(bN));

                %%%%%%%%%%%%%%%% compare raw wave and filtered output %%%%%%%%%%%%%%%%
                mSubplot(Fig(bN),4, columns, 1, [1 1], margins, paddings);
                plot(T, tempIrregWave1, 'color', '#AAAAAA'); hold on
                plot(T, tempRegWave1, 'color', 'black'); hold on
                plot(T, filtIrregWave1, 'Color', 'blue', 'LineWidth', 2); hold on;
                plot(T, filtRegWave1, 'color', 'red', 'LineWidth', 2); hold on;
                xlim([-7000 5000]);
                title(strcat("Frequency Band ", bandStr(bN), " : [", num2str(bpRange(1)), " ", num2str(bpRange(2)), "], Auditory Cortex"));

                mSubplot(Fig(bN),4, columns, columns + 1, [1 1], margins, paddings);
                plot(T, tempIrregWave2, 'color', '#AAAAAA'); hold on
                plot(T, tempRegWave2, 'color', 'black'); hold on
                plot(T, filtIrregWave2, 'Color', 'blue', 'LineWidth', 2); hold on;
                plot(T, filtRegWave2, 'color', 'red', 'LineWidth', 2); hold on;
                xlim([-7000 5000]);
                title(strcat("Frequency Band ", bandStr(bN), " : [", num2str(bpRange(1)), " ", num2str(bpRange(2)), "], PFC"));

                %%%%%%%%%% compare spetrum during stable stationary phase %%%%%%%%%%%%%
                smoothBin = 7;
                mSubplot(Fig(bN),4, columns, 2, [1 1], margins, paddings);
                [ffReg, ~, PReg] = mFFT(filtRegWave1(T > -4000 & T < 0), filtFs);
                PReg = smoothdata(PReg,'gaussian',smoothBin);
                plot(ffReg, PReg, "Color", 'red'); hold on;
                [ffIrreg, ~, PIrreg] = mFFT(filtIrregWave1(T > -4000 & T < 0), filtFs);
                PIrreg = smoothdata(PIrreg,'gaussian',smoothBin);
                plot(ffIrreg, PIrreg, "Color", 'blue'); hold on;
                xlim([0 bpRange(2) * 1.2]);
                if bN == 1
                    xlim([0 60]);
                end
                title("AC FFT, [-4 0]s to change point");

                mSubplot(Fig(bN),4, columns, columns + 2, [1 1], margins, paddings);
                [ffReg, ~, PReg] = mFFT(filtRegWave2(T > -4000 & T < 0), filtFs);
                PReg = smoothdata(PReg,'gaussian',smoothBin);
                plot(ffReg, PReg, "Color", 'red'); hold on;
                [ffIrreg, ~, PIrreg] = mFFT(filtIrregWave2(T > -4000 & T < 0), filtFs);
                PIrreg = smoothdata(PIrreg,'gaussian',smoothBin);
                plot(ffIrreg, PIrreg, "Color", 'blue'); hold on;
                xlim([0 bpRange(2) * 1.2]);
                if bN == 1
                    xlim([0 60]);
                end
                title("PFC FFT, [-4 0]s to change point");



                %%%%%%%%%%%%%%% mean raw wave of PFC and AC %%%%%%%%%%%%%%%%%%

                %% change detect response by average
                envReg1 = envelope(filtRegWave1(zoomS2OnsetIdx));
                envReg2 = envelope(filtRegWave2(zoomS2OnsetIdx));
                t = T(zoomS2OnsetIdx);

                mSubplot(Fig(bN),4 ,columns, 2 *columns + 3, [1 1], margins, paddings);
                if bN == 1
                    plot(t, filtRegWave1(zoomS2OnsetIdx), 'r-', 'DisplayName', 'AC wave'); hold on;
                    plot(t, filtRegWave2(zoomS2OnsetIdx), 'b-', 'DisplayName', 'PFC wave');
                else
                    plot(t, envReg1, 'color', 'red', 'DisplayName', 'AC envelope'); hold on
                    plot(t, filtRegWave1(zoomS2OnsetIdx), 'r:', 'DisplayName', 'AC wave'); hold on;
                    plot(t, envReg2, 'color', 'blue', 'DisplayName', 'PFC envelope'); hold on
                    plot(t, filtRegWave2(zoomS2OnsetIdx), 'b:', 'DisplayName', 'PFC wave');
                end
                xlim(zoomWin);
                title("change detect response by average");
                legend

                %% change detect response by individual
                % AC
                mSubplot(Fig(bN),4 ,columns, 3 * columns + 3, [1 1], margins, paddings);
                for trialN = 1 : length(filtRegFDZ1)
                    envReg1 = envelope(filtRegFDZ1{trialN}(zoomS2OnsetIdx));
                    t = T(zoomS2OnsetIdx);


                    if bN == 1
                        plot(t, filtRegFDZ1{trialN}(zoomS2OnsetIdx), 'r:', 'DisplayName', 'AC wave'); hold on;
                    else
                        plot(t, envReg1, 'color', 'red', 'DisplayName', 'AC envelope'); hold on
                        plot(t, filtRegFDZ1{trialN}(zoomS2OnsetIdx), 'r:', 'DisplayName', 'AC wave'); hold on;
                    end
                end

                xlim(zoomWin);

                title("AC change detect response by individual");


                % PFC
%                 mSubplot(Fig(bN),4 ,columns, 2 * columns + 2, [1 1], margins, paddings);
                for trialN = 1 : length(filtRegFDZ2)
                    envReg2 = envelope(filtRegFDZ2{trialN}(zoomS2OnsetIdx));
                    t = T(zoomS2OnsetIdx);


                    if bN == 1
                        plot(t, filtRegFDZ2{trialN}(zoomS2OnsetIdx), 'b:', 'DisplayName', 'PFC wave'); hold on;
                    else
                        plot(t, envReg2, 'color', 'blue', 'DisplayName', 'PFC envelope'); hold on
                        plot(t, filtRegFDZ2{trialN}(zoomS2OnsetIdx), 'b:', 'DisplayName', 'PFC wave'); hold on;
                    end
                end
                xlim(zoomWin);
                title("PFC change detect response by individual");


                %% s1 onset response by average
                envReg1 = envelope(filtRegWave1(zoomS1OnsetIdx));
                envReg2 = envelope(filtRegWave2(zoomS1OnsetIdx));
                t = T(zoomS1OnsetIdx);
                mSubplot(Fig(bN),4 ,columns, 3, [1 1], margins, paddings);
                if bN == 1
                    plot(t, filtRegWave1(zoomS1OnsetIdx), 'r-', 'DisplayName', 'AC wave'); hold on;
                    plot(t, filtRegWave2(zoomS1OnsetIdx), 'b-', 'DisplayName', 'PFC wave'); hold on;
                else
                    plot(t, envReg1, 'color', 'red', 'DisplayName', 'AC envelope'); hold on
                    plot(t, filtRegWave1(zoomS1OnsetIdx), 'r:', 'DisplayName', 'AC wave'); hold on;
                    plot(t, envReg2, 'color', 'blue', 'DisplayName', 'PFC envelope'); hold on
                    plot(t, filtRegWave2(zoomS1OnsetIdx), 'b:', 'DisplayName', 'PFC wave'); hold on;
                end
                xlim(zoomOnsetWinReg);
                title("s1 Onset Response by average");
                legend

                %% S1 response by individual
                % AC
                mSubplot(Fig(bN),4 ,columns, columns + 3, [1 1], margins, paddings);
                for trialN = 1 : length(filtRegFDZ1)
                    envReg1 = envelope(filtRegFDZ1{trialN}(zoomS1OnsetIdx));
                    t = T(zoomS1OnsetIdx);


                    if bN == 1
                        plot(t, filtRegFDZ1{trialN}(zoomS1OnsetIdx), 'r:', 'DisplayName', 'AC wave'); hold on;
                    else
                        plot(t, envReg1, 'color', 'red', 'DisplayName', 'AC envelope'); hold on
                        plot(t, filtRegFDZ1{trialN}(zoomS1OnsetIdx), 'r:', 'DisplayName', 'AC wave'); hold on;
                    end
                end
                xlim(zoomOnsetWinReg);
                title("AC S1 response by individual");


                % PFC
%                 mSubplot(Fig(bN),4 ,columns, 2 * columns + 2, [1 1], margins, paddings);
                for trialN = 1 : length(filtRegFDZ2)
                    envReg2 = envelope(filtRegFDZ2{trialN}(zoomS1OnsetIdx));
                    t = T(zoomS1OnsetIdx);


                    if bN == 1
                        plot(t, filtRegFDZ2{trialN}(zoomS1OnsetIdx), 'b:', 'DisplayName', 'PFC wave'); hold on;
                    else
                        plot(t, envReg2, 'color', 'blue', 'DisplayName', 'PFC envelope'); hold on
                        plot(t, filtRegFDZ2{trialN}(zoomS1OnsetIdx), 'b:', 'DisplayName', 'PFC wave'); hold on;
                    end
                end
                xlim(zoomOnsetWinReg);
                title("PFC S1 response by individual");


                %% %%% x correlation, since the response pattern of the AC differs from that of %%%%%
                %%%%% PFC, the relevant latency can be defined as the differences between S1-S2 %%%%
                %%%%% response time-lag of the AC and the PFC                                   %%%%

                ACS1 = cellfun(@(x) x(zoomS1OnsetIdx), filtRegFDZ1, 'UniformOutput', false);
                ACS2 = cellfun(@(x) x(zoomS2OnsetIdx), filtRegFDZ1, 'UniformOutput', false);
                PFCS1 = cellfun(@(x) x(zoomS1OnsetIdx), filtRegFDZ2, 'UniformOutput', false);
                PFCS2 = cellfun(@(x) x(zoomS2OnsetIdx), filtRegFDZ2, 'UniformOutput', false);

                [r1, lags1] = cellfun(@(x, y) xcorr(x, y, 60), ACS1, ACS2, 'UniformOutput', false); % AC S1-S2 response cross-correlation
                [r2, lags2] = cellfun(@(x, y) xcorr(x, y, 60), PFCS1, PFCS2, 'UniformOutput', false); % PFC S1-S2 response cross-correlation
                [rS1, lagsS1] = cellfun(@(x, y) xcorr(x, y, 60), ACS1, PFCS1, 'UniformOutput', false); % AC S1- PFC S1 response cross-correlation
                [rS2, lagsS2] = cellfun(@(x, y) xcorr(x, y, 60), ACS2, PFCS2, 'UniformOutput', false); % AC S2- PFC S2 response cross-correlation

                R1 = cell2mat(r1);
                R2 = cell2mat(r2);
                RS1 = cell2mat(rS1);
                RS2 = cell2mat(rS2);

                lags1 = lags1{1} * 1000 / filtFs;
                lags2 = lags2{1} * 1000 / filtFs;
                lagsS1 = lagsS1{1} * 1000 / filtFs;
                lagsS2 = lagsS2{1} * 1000 / filtFs;


                %                 mSubplot(Fig(bN),4 ,columns, 4, [1 1], margins, paddings);
                %                 plot(lags1, r1); hold on;
                %                 [~, lagIdx] = max(r1); % since AC S1 S2 have same response pattern, use absolute cc index
                %                 stem(lags1(lagIdx), r1(lagIdx)); hold on
                %                 title(strcat("AC S1-S2 response CCG, lag=", num2str(lags1(lagIdx)), "ms"));
                %
                %                 mSubplot(Fig(bN),4 ,columns, columns + 4, [1 1], margins, paddings);
                %                 plot(lags2, r2); hold on;
                %                 [~, lagIdx] = max(r2); % since AC S1 S2 have same response pattern, use absolute cc index
                %                 stem(lags2(lagIdx), r2(lagIdx)); hold on
                %                 title(strcat("PFC S1-S2 response CCG, lag=", num2str(lags2(lagIdx)), "ms"));

                FS1 = mSubplot(Fig(bN),4 ,columns, 4, [1 1], margins, paddings);
                [~, lagIdx] = max(abs(RS1')); % since AC and PFC differs in response pattern, use absolute cc index
                for i = 1 : size(RS1, 1)
                    plot(lagsS1, RS1(i, :), 'b:', "LineWidth", 0.5); hold on;
%                     stem(lagsS1(lagIdx(i)), RS1(i, lagIdx(i))); hold on
                end
                plot(lagsS1, mean(RS1), 'r-', "LineWidth", 1.5); hold on;
                stem([mean(lagsS1(lagIdx)) mean(lagsS1(lagIdx))], FS1.YLim, 'Color', 'red'); hold on
                [~, lagIdxMean] = max(abs(mean(RS1))); % since AC and PFC differs in response pattern, use absolute cc index
                stem([mean(lagsS1(lagIdxMean)) mean(lagsS1(lagIdxMean))], FS1.YLim, 'Color', 'green'); hold on
                
                title(strcat("AC S1 - PFC S1 response CCG, lag=", num2str(mean(lagsS1(lagIdx))), "ms"));

                FS2 = mSubplot(Fig(bN),4 ,columns, columns + 4, [1 1], margins, paddings);
                [~, lagIdx] = max(abs(RS2')); % since AC and PFC differs in response pattern, use absolute cc index
                for i = 1 : size(RS2, 1)
                    plot(lagsS2, RS2(i, :), 'b:', "LineWidth", 0.5); hold on;
%                     stem(lagsS2(lagIdx(i)), RS2(i, lagIdx(i))); hold on
                end
                plot(lagsS2, mean(RS2), 'r-', "LineWidth", 1.5); hold on;
                stem([mean(lagsS2(lagIdx)) mean(lagsS2(lagIdx))], FS2.YLim); hold on
                [~, lagIdxMean] = max(abs(mean(RS2))); % since AC and PFC differs in response pattern, use absolute cc index
                stem([mean(lagsS2(lagIdxMean)) mean(lagsS2(lagIdxMean))], FS2.YLim, 'Color', 'green'); hold on

                title(strcat("AC S2 - PFC S2 response CCG, lag=", num2str(mean(lagsS2(lagIdx))), "ms"));


                %% %%%%%%%%%%% spectral gram of click train stimulus %%%%%%%%%%%%%
                run("checkClickTrainLength.m");
                % whole freq band
                mSubplot(Fig(bN),4 ,columns, 2 * columns + 1, [1 1], margins, paddings);
                plot(f,P1);
                title('Single-Sided Amplitude Spectrum of X(t)');
                xlabel('f (Hz)');
                ylabel('|P1(f)|');
                % 0-500 Hz
                mSubplot(Fig(bN),4 ,columns, 2 * columns + 2, [1 1], margins, paddings);
                plot(f,P1);
                title('Single-Sided Amplitude Spectrum of X(t)');
                xlabel('f (Hz)');
                ylabel('|P1(f)|');
                xlim([0 500]);
                print(Fig(bN), fullfile(savePath,strcat(bandStr(bN), "band_AC", num2str(acSelect), "-PFC", num2str(pfcSelect))), "-djpeg", "-r300");
                close all;



            end
        end
    end
end
% FDZData.AC = struct("FDZDataChouChou", FDZDataACAll.chouchou, "FDZDataXiaoXiao", FDZDataACAll.xiaoxiao, "t", {LAuC_FilterRes.t}', "stimStr", {LAuC_FilterRes.stimStr}', "S1Duration", {LAuC_FilterRes.S1Duration}', "fs", {LAuC_FilterRes.fs}');
% FDZData.PFC = struct("FDZDataChouChou", FDZDataPFCAll.chouchou, "FDZDataXiaoXiao", FDZDataPFCAll.xiaoxiao, "t", {LPFC_FilterRes.t}', "stimStr", {LPFC_FilterRes.stimStr}', "S1Duration", {LPFC_FilterRes.S1Duration}', "fs", {LPFC_FilterRes.fs}');
%
