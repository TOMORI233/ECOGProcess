clear; clc;
load('E:\ECoG\matData\chouchou\cc20220713\Block-1_ClickTrainSSALongTerm4\LAuC_filterResHP0o1Hz.mat');
LAuC_FilterRes = filterRes;
load('E:\ECoG\matData\chouchou\cc20220713\Block-1_ClickTrainSSALongTerm4\LPFC_filterResHP0o1Hz.mat');
LPFC_FilterRes = filterRes;

acSelect = 13;
pfcSelect = 13;

% figure settings
margins = [0.02,0.02,0.06,0.06];
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

% time window
zoomWin = [-100 400];
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
    else
        filtRegWave1 = tempRegWave1;
        filtIrregWave1 = tempIrregWave1;
        filtRegWave2 = tempRegWave2;
        filtIrregWave2 = tempIrregWave2;
    end


    Fig = figure;
    maximizeFig(Fig);
    %%%%%%%%%%%%%%%% compare raw wave and filtered output %%%%%%%%%%%%%%%%
    mSubplot(Fig,4, columns, 1, [1 1], margins, paddings);
    plot(T, tempIrregWave1, 'color', '#AAAAAA'); hold on
    plot(T, tempRegWave1, 'color', 'black'); hold on
    plot(T, filtIrregWave1, 'Color', 'blue', 'LineWidth', 2); hold on;
    plot(T, filtRegWave1, 'color', 'red', 'LineWidth', 2); hold on;
    xlim([-7000 5000]);
    title(strcat("Frequency Band ", bandStr(bN), " : [", num2str(bpRange(1)), " ", num2str(bpRange(2)), "], Auditory Cortex"));

    mSubplot(Fig,4, columns, columns + 1, [1 1], margins, paddings);
    plot(T, tempIrregWave2, 'color', '#AAAAAA'); hold on
    plot(T, tempRegWave2, 'color', 'black'); hold on
    plot(T, filtIrregWave2, 'Color', 'blue', 'LineWidth', 2); hold on;
    plot(T, filtRegWave2, 'color', 'red', 'LineWidth', 2); hold on;
    xlim([-7000 5000]);
    title(strcat("Frequency Band ", bandStr(bN), " : [", num2str(bpRange(1)), " ", num2str(bpRange(2)), "], PFC"));

    %%%%%%%%%% compare spetrum during stable stationary phase %%%%%%%%%%%%%
    mSubplot(Fig,4, columns, 2, [1 1], margins, paddings);
    [ffReg, ~, PReg] = mFFT(filtRegWave1(T > -4000 & T < 0), filtFs);
    plot(ffReg, PReg, "Color", 'red'); hold on;
    [ffIrreg, ~, PIrreg] = mFFT(filtIrregWave1(T > -4000 & T < 0), filtFs);
    plot(ffIrreg, PIrreg, "Color", 'blue'); hold on;
    xlim([0 bpRange(2) * 1.2]);
    if bN == 1
        xlim([0 60]);
    end
    title("AC FFT, [-4 0]s to change point");

    mSubplot(Fig,4, columns, columns + 2, [1 1], margins, paddings);
    [ffReg, ~, PReg] = mFFT(filtRegWave2(T > -4000 & T < 0), filtFs);
    plot(ffReg, PReg, "Color", 'red'); hold on;
    [ffIrreg, ~, PIrreg] = mFFT(filtIrregWave2(T > -4000 & T < 0), filtFs);
    plot(ffIrreg, PIrreg, "Color", 'blue'); hold on;
    xlim([0 bpRange(2) * 1.2]);
    if bN == 1
        xlim([0 60]);
    end
    title("PFC FFT, [-4 0]s to change point");



    %%%%%%%%%%%%%%% hilbert trans to get envelope %%%%%%%%%%%%%%%%%%

    % change detect response
    envReg1 = envelope(filtRegWave1(zoomS2OnsetIdx));
    envReg2 = envelope(filtRegWave2(zoomS2OnsetIdx));
    t = T(zoomS2OnsetIdx);

    mSubplot(Fig,4 ,columns, 3, [1 1], margins, paddings);
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
    title("change detect response");
    legend

    % s1 onset response
    envReg1 = envelope(filtRegWave1(zoomS1OnsetIdx));
    envReg2 = envelope(filtRegWave2(zoomS1OnsetIdx));
    t = T(zoomS1OnsetIdx);
    mSubplot(Fig,4 ,columns, columns + 3, [1 1], margins, paddings);
    if bN == 1
        plot(t, filtRegWave1(zoomS1OnsetIdx), 'r-', 'DisplayName', 'AC wave'); hold on;
        plot(t, filtRegWave2(zoomS1OnsetIdx), 'b-', 'DisplayName', 'PFC wave');
    else
        plot(t, envReg1, 'color', 'red', 'DisplayName', 'AC envelope'); hold on
        plot(t, filtRegWave1(zoomS1OnsetIdx), 'r:', 'DisplayName', 'AC wave'); hold on;
        plot(t, envReg2, 'color', 'blue', 'DisplayName', 'PFC envelope'); hold on
        plot(t, filtRegWave2(zoomS1OnsetIdx), 'b:', 'DisplayName', 'PFC wave');
    end
    xlim(zoomOnsetWinReg);
    title("s1 Onset Response");
    legend

    %%%%% x correlation, since the response pattern of the AC differs from that of %%%%%
    %%%%% PFC, the relevant latency can be defined as the differences between S1-S2 %%%%
    %%%%% response time-lag of the AC and the PFC                                   %%%%

    ACS1 = filtRegWave1(zoomS1OnsetIdx);  ACS2 = filtRegWave1(zoomS2OnsetIdx);
    PFCS1 = filtRegWave2(zoomS1OnsetIdx);  PFCS2 = filtRegWave2(zoomS2OnsetIdx);
    [r1, lags1] = xcorr(ACS1, ACS2); % AC S1-S2 response cross-correlation
    [r2, lags2] = xcorr(PFCS1, PFCS2); % PFC S1-S2 response cross-correlation
    [rS1, lagsS1] = xcorr(ACS1, PFCS1); % AC S1- PFC S1 response cross-correlation
    [rS2, lagsS2] = xcorr(ACS2, PFCS2); % AC S2- PFC S2 response cross-correlation

    mSubplot(Fig,4 ,columns, 4, [1 1], margins, paddings);
    plot(lags1, r1); hold on;
    [~, lagIdx] = max(r1); % since AC S1 S2 have same response pattern, use absolute cc index
    stem(lags1(lagIdx), r1(lagIdx)); hold on
    title(strcat("AC S1-S2 response CCG, lag=", num2str(lags1(lagIdx) * 1000 / filtFs), "ms"));

    mSubplot(Fig,4 ,columns, columns + 4, [1 1], margins, paddings);
    plot(lags2, r2); hold on;
    [~, lagIdx] = max(r2); % since AC S1 S2 have same response pattern, use absolute cc index
    stem(lags2(lagIdx), r2(lagIdx)); hold on
    title(strcat("PFC S1-S2 response CCG, lag=", num2str(lags2(lagIdx) * 1000 / filtFs), "ms"));

    mSubplot(Fig,4 ,columns, 2 * columns + 4, [1 1], margins, paddings);
    plot(lagsS1, rS1); hold on;
    [~, lagIdx] = max(abs(rS1)); % since AC and PFC differs in response pattern, use absolute cc index
    stem(lagsS1(lagIdx), rS1(lagIdx)); hold on
    title(strcat("AC S1 - PFC S1 response CCG, lag=", num2str(lagsS1(lagIdx) * 1000 / filtFs), "ms"));

    mSubplot(Fig,4 ,columns, 3 * columns + 4, [1 1], margins, paddings);
    plot(lagsS2, rS2); hold on;
    [~, lagIdx] = max(abs(rS2)); % since AC and PFC differs in response pattern, use absolute cc index
    stem(lagsS2(lagIdx), rS2(lagIdx)); hold on
    title(strcat("AC S2 - PFC S2 response CCG, lag=", num2str(lagsS2(lagIdx) * 1000 / filtFs), "ms"));


end


% %% RSA by TFA
% [t, f, TFR1, coi] = computeTFA(tempReg1.chMean, tempReg1.fs, tempReg1.fs, [0 20]);
% t = t + window(1) / 1000;
% 
% % [~, ~, TFR2, ~] = computeTFA(temp2.chMean, temp2.fs0, temp2.fs);
% [~, ~, TFR2, ~] = computeTFA(tempReg2.chMean, tempReg2.fs, tempReg2.fs, [0 20]);
% 
% [~, fIdx] = findWithinInterval(f, [0 10]);
% % TFR1Temp = TFR1(fIdx, :, :);
% % TFR2Temp = TFR2(fIdx, :, :);
% %
% % rho = zeros(size(TFR1Temp, 2), size(TFR1Temp, 2), size(TFR1Temp, 3));
% % for eIndex = 1:size(TFR2Temp, 3)
% %     rho(:, :, eIndex) = corr(TFR1Temp(:, :, acSelect), TFR2Temp(:, :, eIndex), "type", "Pearson");
% % end
% 
% %% RSA by raw wave
% T = linspace(window(1), window(2), size(tempReg1.chMean, 2));
% t = T/1000;
% bsz = 200; % ms
% bstep = 5; % ms
% rWin = [window(1) : bstep : window(2) - bsz; window(1) +  bsz: bstep : window(2)]';
% [~,idx] = findWithinWindow(tempReg1.chMean(1, :), T, rWin(1, :));
% rWave1 = zeros(length(idx), size(rWin, 1), size(tempReg1.chMean, 1));
% rWave2 = zeros(length(idx), size(rWin, 1), size(tempReg1.chMean, 1));
% 
% % rWave1 = zeros(floor(bsz / 1000 * temp1.fs), size(rWin, 1), size(temp1.chMean, 1));
% % rWave2 = zeros(floor(bsz / 1000 * temp1.fs), size(rWin, 1), size(temp1.chMean, 1));
% rho = zeros(size(rWin, 1), size(rWin, 1), size(tempReg1.chMean, 1));
% for eIndex = 1 : size(tempReg1.chMean, 1) % ch number
%     for sIndex = 1 : size(rWin, 1) % window number
%         seg1 = findWithinWindow(tempReg1.chMean(eIndex, :), T, rWin(sIndex, :));
%         seg2 = findWithinWindow(tempReg2.chMean(eIndex, :), T, rWin(sIndex, :));
%         seg1Temp = seg1(1 : min([size(rWave1, 1), length(seg1), length(seg2)]))';
%         seg2Temp = seg2(1 : min([size(rWave2, 1), length(seg1), length(seg2)]))';
%         rWave1(:, sIndex, eIndex) = seg1Temp';
%         rWave2(:, sIndex, eIndex) = seg2Temp';
%     end
% end
% 
% for eIndex = 1:size(tempReg1.chMean, 1)
%     rho(:, :, eIndex) = corr(rWave1(:, :, acSelect), rWave2(:, :, eIndex), "type", "Pearson");
% end
% 
% 
% %% plot figure
% Fig = figure;
% maximizeFig(Fig);
% for eIndex = 1:chNum
%     mSubplot(Fig, 8, 8, eIndex, [1, 1]);
%     imagesc('XData', t, 'YData', t, 'CData', rho(:, :, eIndex));
%     hold on;
%     plot([min(t) max(t)], [0, 0], "w--", "LineWidth", 1.5); hold on;
%     plot([min(t) max(t)], [0.2, 0.2], "k--", "LineWidth", 1.5);hold on;
%     plot([0, 0], [min(t) max(t)], "w--", "LineWidth", 1.5);hold on;
%     plot([0.2, 0.2], [min(t) max(t)], "k--", "LineWidth", 1.5);hold on;
%     plot([min(t) max(t)], [min(t) max(t)], "w--", "LineWidth", 1.5);hold on;
%     xlim([-0.1 0.5]);
%     ylim([-0.1 0.5]);
%     %     xlim([min(t) max(t)]);
%     %     ylim([min(t) max(t)]);
%     if mod(eIndex, 8) == 1
%         ylabel('trial time - PFC');
%     end
% 
%     if floor((eIndex - 1) / 8) == 7
%         xlabel('trial time - AC');
%     end
%     % title(['Align to last sound onset - dRatio = ', num2str(dRatio(dIndex))]);
%     cb = colorbar;
%     ylabel(cb, 'similarity', "FontSize", 12);
% end
% % RSAPATH = strcat(ROOTPATH, DateStr, "\RSA\");
% % mkdir(RSAPATH);
% % print(gcf, strcat(RSAPATH, DateStr), "-djpeg", "-r200");
% colormap jet
% 
