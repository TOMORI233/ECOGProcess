load('E:\ECoG\matData\behavior\ClickTrainOddCompareTone\Active\xx20220804\LAuC_MMNData.mat');
LAuC_MMNData = MMNData;
load('E:\ECoG\matData\behavior\ClickTrainOddCompareTone\Active\xx20220804\LPFC_MMNData.mat');
LPFC_MMNData = MMNData;

acSelect = 37;
% RSA
temp1 = LAuC_MMNData(4);
temp2 = LPFC_MMNData(4);
window = temp1.window;
chNum = size(temp1.chMeanDEV);
%% RSA by TFA
[t, f, TFR1, coi] = computeTFA(temp1.chMeanDEV, temp1.fs0, 1000, [0 20]);
t = t + window(1) / 1000;

% [~, ~, TFR2, ~] = computeTFA(temp2.chMeanDEV, temp2.fs0, temp2.fs);
 [~, ~, TFR2, ~] = computeTFA(temp2.chMeanDEV, temp2.fs0, 1000, [0 20]);

[~, fIdx] = findWithinInterval(f, [0 10]);
TFR1Temp = TFR1(fIdx, :, :);
TFR2Temp = TFR2(fIdx, :, :);

rho = zeros(size(TFR1Temp, 2), size(TFR1Temp, 2), size(TFR1Temp, 3));
for eIndex = 1:size(TFR2Temp, 3)
    rho(:, :, eIndex) = corr(TFR1Temp(:, :, acSelect), TFR2Temp(:, :, eIndex), "type", "Pearson");
end

%% RSA by raw wave
T = linspace(window(1), window(2), size(temp1.chMeanDEV, 2));
t = T/1000;
bsz = 200; % ms
bstep = 5; % ms
rWin = [window(1) : bstep : window(2) - bsz; window(1) +  bsz: bstep : window(2)]';
rWave1 = zeros(floor(bsz / 1000 * temp1.fs0), size(rWin, 1), size(temp1.chMeanDEV, 1));
rWave2 = zeros(floor(bsz / 1000 * temp1.fs0), size(rWin, 1), size(temp1.chMeanDEV, 1));
rho = zeros(size(rWin, 1), size(rWin, 1), size(temp1.chMeanDEV, 1));
for eIndex = 1 : size(temp1.chMeanDEV, 1)
    for sIndex = 1 : size(rWin, 1)
        seg1 = findWithinWindow(temp1.chMeanDEV(eIndex, :), T, rWin(sIndex, :));
        seg2 = findWithinWindow(temp2.chMeanDEV(eIndex, :), T, rWin(sIndex, :));
        seg1Temp = seg1(1 : min([size(rWave1, 1), length(seg1), length(seg2)]))';
        seg2Temp = seg2(1 : min([size(rWave2, 1), length(seg1), length(seg2)]))';
        rWave1(:, sIndex, eIndex) = seg1Temp';
        rWave2(:, sIndex, eIndex) = seg2Temp';
    end
end

for eIndex = 1:size(temp1.chMeanDEV, 1)
    rho(:, :, eIndex) = corr(rWave1(:, :, acSelect), rWave2(:, :, eIndex), "type", "Pearson");
end


%% plot figure 
Fig = figure;
maximizeFig(Fig);
for eIndex = 1:chNum
    mSubplot(Fig, 8, 8, eIndex, [1, 1]);
    imagesc('XData', t, 'YData', t, 'CData', rho(:, :, eIndex));
    hold on;
    plot([min(t) max(t)], [0, 0], "w--", "LineWidth", 1.5); hold on;
    plot([min(t) max(t)], [0.2, 0.2], "k--", "LineWidth", 1.5);hold on;
    plot([0, 0], [min(t) max(t)], "w--", "LineWidth", 1.5);hold on;
    plot([0.2, 0.2], [min(t) max(t)], "k--", "LineWidth", 1.5);hold on;
    plot([min(t) max(t)], [min(t) max(t)], "w--", "LineWidth", 1.5);hold on;
    xlim([-0.1 0.5]);
    ylim([-0.1 0.5]);
%     xlim([min(t) max(t)]);
%     ylim([min(t) max(t)]);
    if mod(eIndex, 8) == 1
        ylabel('trial time - PFC');
    end

    if floor((eIndex - 1) / 8) == 7
        xlabel('trial time - AC');
    end
    % title(['Align to last sound onset - dRatio = ', num2str(dRatio(dIndex))]);
    cb = colorbar;
    ylabel(cb, 'similarity', "FontSize", 12);
end
% RSAPATH = strcat(ROOTPATH, DateStr, "\RSA\");
% mkdir(RSAPATH);
% print(gcf, strcat(RSAPATH, DateStr), "-djpeg", "-r200");
colormap jet

