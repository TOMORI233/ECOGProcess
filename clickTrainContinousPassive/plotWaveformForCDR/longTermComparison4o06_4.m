clear all; clc
monkeyId = ["chouchou", "xiaoxiao"];
posStr = ["LAuC", "LPFC"];
plotFigure = 1;
reprocess = 1;
idIdx = 1:2;
s1OnsetOrS2Onset = 2; % 1: start, 2: trans
paradigmKeyword = "LongTerm4[^0]";
paradigmStr = strrep(paradigmKeyword, '[^0]', '');

for id = idIdx
    rootPath = fullfile('E:\ECoG\matData', monkeyId(id));
    FDZDataACAll.(monkeyId(id)) = cell(4, 1);
    FDZDataPFCAll.(monkeyId(id)) = cell(4, 1);
    for pN = 1 : length(paradigmKeyword)
        matPath = getSubfoldPath(rootPath,'filterResHP0o1Hz.mat', strcat(paradigmKeyword(pN), ".*", posStr(1)));
        for recordCode = 1 : length(matPath)
            matPathAC = getSubfoldPath(rootPath,'filterResHP0o1Hz.mat', strcat(paradigmKeyword(pN), ".*", posStr(1)));
            matPathPFC = getSubfoldPath(rootPath,'filterResHP0o1Hz.mat', strcat(paradigmKeyword(pN), ".*", posStr(2)));
            temp = strsplit(matPath{recordCode}, '\');
            dateStr = temp{5};
            savePath = fullfile("E:\ECoG\corelDraw\jpgHP0o1Hz", "freq band response comparison", dateStr, "4.06-4") ;
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
            clearvars -except ccgLag LAuC_FilterRes LPFC_FilterRes FDZDataACAll FDZDataPFCAll FDZDataAC FDZDataPFC processCDR savePath reprocess id monkeyId recordCode matPath matPathAC matPathPFC selectWin selectRecord posStr  paradigmKeyword paradigmStr pN filterRes rootPath cdrRes cdrPlot plotFigure dateStr plotCh chMeanSel yScale s1OnsetOrS2Onset
            % figure settings
            margins = [0.02,0.02,0.06,0.06];
            paddings = [0.01, 0.01, 0.02, 0.02];
            % raw data
            tempReg1Ord = LAuC_FilterRes(1);
            tempReg2Ord = LPFC_FilterRes(1);
            tempReg1Rev = LAuC_FilterRes(2);
            tempReg2Rev = LPFC_FilterRes(2);

            tempIrreg1Ord = LAuC_FilterRes(3);
            tempIrreg2Ord = LPFC_FilterRes(3);
            tempIrreg1Rev = LAuC_FilterRes(4);
            tempIrreg2Rev = LPFC_FilterRes(4);

            chNum = size(tempReg1Ord.chMean);
            T = tempReg1Ord.t;

            tempRegWave1Ord = tempReg1Ord.chMean; % AC 4-4.06 regular
            tempIrregWave1Ord = tempIrreg1Ord.chMean; % AC 4-4.06 irregular
            tempRegWave1Rev = tempReg1Rev.chMean; % AC 4.06-4 regular
            tempIrregWave1Rev = tempIrreg1Rev.chMean; % AC 4.06-4 irregular

            tempRegWave2Ord = tempReg2Ord.chMean; % PFC 4-4.06 regular
            tempIrregWave2Ord = tempIrreg2Ord.chMean; % PFC 4-4.06 irregular
            tempRegWave2Rev = tempReg2Rev.chMean; % PFC 4.06-4 regular
            tempIrregWave2Rev = tempIrreg2Rev.chMean; % PFC 4.06-4 irregular

            % time window
            zoomWin = [-300 600];
            zoomS2OnsetIdx = T>zoomWin(1) & T<zoomWin(2);
            zoomOnsetWinRegOrd = zoomWin - LAuC_FilterRes(1).S1Duration;
            zoomS1OnsetIdxOrd = T>zoomOnsetWinRegOrd(1) & T<zoomOnsetWinRegOrd(2);
            zoomOnsetWinRegRev = zoomWin - LAuC_FilterRes(2).S1Duration;
            zoomS1OnsetIdxRev = T>zoomOnsetWinRegRev(1) & T<zoomOnsetWinRegRev(2);
            window = [min(T) max(T)];

            % FDZData organise
            FDZTempAC = {LAuC_FilterRes.FDZData}';
            FDZTempPFC = {LPFC_FilterRes.FDZData}';
            for stimCode = 1 : length(LAuC_FilterRes)
                FDZDataACAll.(monkeyId(id)){stimCode, 1} = [FDZDataACAll.(monkeyId(id)){stimCode, 1}; FDZTempAC{stimCode, 1}];
                FDZDataPFCAll.(monkeyId(id)){stimCode, 1} = [FDZDataPFCAll.(monkeyId(id)){stimCode, 1}; FDZTempPFC{stimCode, 1}];
            end

            if plotFigure
                %% Zero-phase digital filtering
                bpRanges = [0 150;...
                    0.5 3;... % δ delta
                    3 7;... % θ theta
                    7 13;... % α alpha
                    13 30;... % β beta
                    %     30 50;... % γ1 gamma
                    %     50 100;... % γ2 gamma
                    %     100 140;... % γ3 gamma
                    ];
                yScaleS1 = [-60 60;...
                    -60 60;...
                    -50 50;...
                    -40 40;...
                    -30 30;...
                    -20 20;...
                    -20 20;...
                    -20 20;...
                    ];
                yScaleS2 = yScaleS1;
                bandStr = ["raw", "delta", "theta", "alpha", "beta", "gamma1", "gamma2", "gamma3"];
                for bN = 1 : size(bpRanges, 1)
                    bpRange = bpRanges(bN, :);
                    filtFs = tempReg1Ord.fs;

                    if bN > 1
                        bpFilt = designfilt('bandpassiir','FilterOrder',4, ...
                            'HalfPowerFrequency1',bpRange(1),'HalfPowerFrequency2',bpRange(2), ...
                            'SampleRate',filtFs);

                        filtRegWave1Ord = (filtfilt(bpFilt, tempRegWave1Ord'))';
                        filtIrregWave1Ord = (filtfilt(bpFilt, tempIrregWave1Ord'))';
                        filtRegWave2Ord = (filtfilt(bpFilt, tempRegWave2Ord'))';
                        filtIrregWave2Ord = (filtfilt(bpFilt, tempIrregWave2Ord'))';

                        filtRegWave1Rev = (filtfilt(bpFilt, tempRegWave1Rev'))';
                        filtIrregWave1Rev = (filtfilt(bpFilt, tempIrregWave1Rev'))';
                        filtRegWave2Rev = (filtfilt(bpFilt, tempRegWave2Rev'))';
                        filtIrregWave2Rev = (filtfilt(bpFilt, tempIrregWave2Rev'))';
                    else
                        filtRegWave1Ord = tempRegWave1Ord;
                        filtIrregWave1Ord = tempIrregWave1Ord;
                        filtRegWave2Ord = tempRegWave2Ord;
                        filtIrregWave2Ord = tempIrregWave2Ord;

                        filtRegWave1Rev = tempRegWave1Rev;
                        filtIrregWave1Rev = tempIrregWave1Rev;
                        filtRegWave2Rev = tempRegWave2Rev;
                        filtIrregWave2Rev = tempIrregWave2Rev;
                    end

                    % AC
                    FigRawAC = plotRawWave(filtRegWave1Rev, [], window, strcat("AC Frequency Band ", bandStr(bN), " : [", num2str(bpRange(1)), " ", num2str(bpRange(2)), "]"), [8, 8], 1:64, "off");
                    setLine(FigRawAC, "LineWidth", 1, "LineWidth", 1.5);
                    lineSetting.color = "blue"; lineSetting.style = "-"; lineSetting.width = 1;
                    FigRawAC = plotRawWave2(FigRawAC, filtIrregWave1Rev, [], window, lineSetting, [8, 8]);
                    lines.X = -1 * LAuC_FilterRes(2).S1Duration;
                    lines.color = "black";
                    lines.width = 0.5;
                    addLines2Axes(FigRawAC, lines);
                    scaleAxes(FigRawAC, "y", [-50 50]);


                    % PFC
                    FigRawPFC = plotRawWave(filtRegWave2Rev, [], window, strcat("PFC Frequency Band ", bandStr(bN), " : [", num2str(bpRange(1)), " ", num2str(bpRange(2)), "]"), [8, 8], 1:64, "off");
                    setLine(FigRawAC, "LineWidth", 1, "LineWidth", 1.5);
                    lineSetting.color = "blue"; lineSetting.style = "-"; lineSetting.width = 1;
                    FigRawPFC = plotRawWave2(FigRawPFC, filtIrregWave2Rev, [], window, lineSetting, [8, 8]);
                    lines.X = -1 * LPFC_FilterRes(2).S1Duration;
                    lines.color = "black";
                    lines.width = 0.5;
                    addLines2Axes(FigRawPFC, lines);
                    scaleAxes(FigRawPFC, "y", [-50 50]);

                    mkdir(savePath)
                    print(FigRawAC, fullfile(savePath,strcat(bandStr(bN), "band_RegIrreg_4" ,"_AC")), "-djpeg", "-r300");
                    print(FigRawPFC, fullfile(savePath,strcat(bandStr(bN), "band_RegIrreg_4" ,"_PFC")), "-djpeg", "-r300");


                    %%%%%%%%%%%%%%% hilbert trans to get envelope %%%%%%%%%%%%%%%%%%

                    % change detect response
                    envReg1Ord = (envelope(filtRegWave1Ord'))';
                    envReg2Ord = (envelope(filtRegWave2Ord'))';
                    envReg1Rev = (envelope(filtRegWave1Rev'))';
                    envReg2Rev = (envelope(filtRegWave2Rev'))';
                    t = T(zoomS2OnsetIdx);
%                     tempS1 = [envReg1Ord(:, zoomS1OnsetIdxOrd) envReg2Ord(:, zoomS1OnsetIdxOrd) filtRegWave1Ord(:, zoomS1OnsetIdxOrd) filtRegWave2Ord(:, zoomS1OnsetIdxOrd)];
%                     yScaleS1 = [min(min(tempS1)), max(max(tempS1))];
%                     tempS2 = [envReg1Ord(:, zoomS2OnsetIdx) envReg2Ord(:, zoomS2OnsetIdx) filtRegWave1Ord(:, zoomS2OnsetIdx) filtRegWave2Ord(:, zoomS2OnsetIdx)];
%                     yScaleS2 = [min(min(tempS2)), max(max(tempS2))];


                    % comparison between S2(change) onset and S1 in AC
                    if bN == 1
                        FigEnvRegAC = plotRawWave(filtRegWave1Rev(:, zoomS2OnsetIdx), [], zoomWin, strcat("AC Frequency Band ", bandStr(bN), " : [", num2str(bpRange(1)), " ", num2str(bpRange(2)), "]"), [8, 8], 1:64, "off");
                        FigEnvRegAC = plotRawWave2(FigEnvRegAC, filtRegWave1Ord(:, zoomS1OnsetIdxOrd), [], zoomWin, lineSetting, [8, 8]);
                        yl = scaleAxes(FigEnvRegAC, "y", yScaleS1(bN, :));
                    else
                        FigEnvRegAC = plotRawWave(envReg1Rev(:, zoomS2OnsetIdx), [], zoomWin, strcat("AC Frequency Band ", bandStr(bN), " : [", num2str(bpRange(1)), " ", num2str(bpRange(2)), "]"), [8, 8], 1:64, "off");
                        lineSetting.color = "red"; lineSetting.style = ":"; lineSetting.width = 1;
                        FigEnvRegAC = plotRawWave2(FigEnvRegAC, filtRegWave1Rev(:, zoomS2OnsetIdx), [], zoomWin, lineSetting, [8, 8]);
                        lineSetting.color = "blue"; lineSetting.style = "-"; lineSetting.width = 1.5;
                        FigEnvRegAC = plotRawWave2(FigEnvRegAC, envReg1Ord(:, zoomS1OnsetIdxOrd), [], zoomWin, lineSetting, [8, 8]);
                        lineSetting.color = "blue"; lineSetting.style = ":"; lineSetting.width = 1;
                        FigEnvRegAC = plotRawWave2(FigEnvRegAC, filtRegWave1Ord(:, zoomS1OnsetIdxOrd), [], zoomWin, lineSetting, [8, 8]);
                        yl = scaleAxes(FigEnvRegAC, "y", yScaleS1(bN, :));
                    end

                    
                    setLine(FigEnvRegAC, "YData", yl, "Color", [0 0 0]);


                    % comparison between S2(change) onset and S1 in PFC
                    if bN == 1
                        FigEnvRegPFC = plotRawWave(filtRegWave2Rev(:, zoomS2OnsetIdx), [], zoomWin, strcat("AC Frequency Band ", bandStr(bN), " : [", num2str(bpRange(1)), " ", num2str(bpRange(2)), "]"), [8, 8], 1:64, "off");
                        FigEnvRegPFC = plotRawWave2(FigEnvRegPFC, filtRegWave2Ord(:, zoomS1OnsetIdxOrd), [], zoomWin, lineSetting, [8, 8]);
                        yl = scaleAxes(FigEnvRegPFC, "y", yScaleS2(bN, :));
                    else
                        FigEnvRegPFC = plotRawWave(envReg2Rev(:, zoomS2OnsetIdx), [], zoomWin, strcat("PFC Frequency Band ", bandStr(bN), " : [", num2str(bpRange(1)), " ", num2str(bpRange(2)), "]"), [8, 8], 1:64, "off");
                        lineSetting.color = "red"; lineSetting.style = ":"; lineSetting.width = 1;
                        FigEnvRegPFC = plotRawWave2(FigEnvRegPFC, filtRegWave2Rev(:, zoomS2OnsetIdx), [], zoomWin, lineSetting, [8, 8]);
                        lineSetting.color = "blue"; lineSetting.style = "-"; lineSetting.width = 1.5;
                        FigEnvRegPFC = plotRawWave2(FigEnvRegPFC, envReg2Ord(:, zoomS1OnsetIdxOrd), [], zoomWin, lineSetting, [8, 8]);
                        lineSetting.color = "blue"; lineSetting.style = ":"; lineSetting.width = 1;
                        FigEnvRegPFC = plotRawWave2(FigEnvRegPFC, filtRegWave2Ord(:, zoomS1OnsetIdxOrd), [], zoomWin, lineSetting, [8, 8]);
                        yl = scaleAxes(FigEnvRegPFC, "y", yScaleS2(bN, :));
                    end

                    
                    setLine(FigEnvRegPFC, "YData", yl, "Color", [0 0 0]);

                    print(FigEnvRegAC, fullfile(savePath,strcat(bandStr(bN), "band_S1S2_4" ,"_AC")), "-djpeg", "-r300");
                    print(FigEnvRegPFC, fullfile(savePath,strcat(bandStr(bN), "band_S1S2_4" ,"_PFC")), "-djpeg", "-r300");
                    
                    
                    %%%%% x correlation, since the response pattern of the AC differs from that of %%%%%
                    %%%%% PFC, the relevant latency can be defined as the differences between S1-S2 %%%%
                    %%%%% response time-lag of the AC and the PFC                                   %%%%
                    ACS1 = filtRegWave1Ord(:, zoomS1OnsetIdxOrd);  PFCS1 = filtRegWave2Ord(:, zoomS1OnsetIdxOrd); 
                    ACS2 = filtRegWave1Rev(:, zoomS2OnsetIdx);  PFCS2 = filtRegWave2Rev(:, zoomS2OnsetIdx);

                    [r1, lags1] = mXcorr(ACS1, ACS2, 60); % AC S1-S2 response cross-correlation
                    [r2, lags2] = mXcorr(PFCS1, PFCS2, 60); % PFC S1-S2 response cross-correlation
                    lags1 = lags1 * 1000 / LAuC_FilterRes(1).fs;
                    lags2 = lags2 * 1000 / LPFC_FilterRes(1).fs;

                    % AC
                    FigXcorrRegAC = plotRawWave(r1, [], [lags1(1) lags1(end)], strcat("AC CCG ", bandStr(bN)), [8, 8], 1:64, "off");
                    yy = scaleAxes(FigXcorrRegAC, "y");
                    YY = repmat(yy, size(ACS2, 1), 1);
                    [R1, IdxS1] = max(r1');
                    
                    LAGS1 = repmat(lags1(1, IdxS1), 2, 1)';
                    lineSetting.color = 'b'; lineSetting.style = '-'; 
                    FigXcorrRegAC = plotRawWave3(FigXcorrRegAC, YY, [], LAGS1, lineSetting, [8, 8]);
                    scaleAxes(FigXcorrRegAC, "y", [-1e5 1e5]);

                    % PFC
                     FigXcorrRegPFC = plotRawWave(r2, [], [lags2(1) lags2(end)], strcat("PFC CCG ", bandStr(bN)), [8, 8], 1:64, "off");
                    yy = scaleAxes(FigXcorrRegPFC, "y");
                    YY = repmat(yy, size(PFCS2, 1), 1);
                    [R2, IdxS2] = max(r2');
                    LAGS2 = repmat(lags2(1, IdxS2), 2, 1)';
                    lineSetting.color = 'b'; lineSetting.style = '-'; 
                    FigXcorrRegPFC = plotRawWave3(FigXcorrRegPFC, YY, [], LAGS2, lineSetting, [8, 8]);
                    scaleAxes(FigXcorrRegPFC, "y", [-1e5 1e5]);


                    ccgLag.AC.(monkeyId(id)).LongTerm4o06_4.(bandStr(bN))(:, recordCode) = lags1(1, IdxS1)';
                    ccgLag.PFC.(monkeyId(id)).LongTerm4o06_4.(bandStr(bN))(:, recordCode) = lags2(1, IdxS2)';
                    print(FigXcorrRegAC, fullfile(savePath,strcat(bandStr(bN), "band_S1S2CCG_4" ,"_AC")), "-djpeg", "-r300");
                    print(FigXcorrRegPFC, fullfile(savePath,strcat(bandStr(bN), "band_S1S2CCG_4" ,"_PFC")), "-djpeg", "-r300");



                    close all;
                end
            end
        end
    end
end
    FDZData.AC = struct("FDZDataChouChou", FDZDataACAll.chouchou, "FDZDataXiaoXiao", FDZDataACAll.xiaoxiao, "t", {LAuC_FilterRes.t}', "stimStr", {LAuC_FilterRes.stimStr}', "S1Duration", {LAuC_FilterRes.S1Duration}', "fs", {LAuC_FilterRes.fs}');
    FDZData.PFC = struct("FDZDataChouChou", FDZDataPFCAll.chouchou, "FDZDataXiaoXiao", FDZDataPFCAll.xiaoxiao, "t", {LPFC_FilterRes.t}', "stimStr", {LPFC_FilterRes.stimStr}', "S1Duration", {LPFC_FilterRes.S1Duration}', "fs", {LPFC_FilterRes.fs}');