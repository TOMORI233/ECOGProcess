clear; clc;
%% Parameter settings
params.posIndex = 1; % 1-AC, 2-PFC
params.choiceWin = [100, 600];
params.processFcn = @ActiveProcess_7_10Freq;

fs = 500; % Hz, for downsampling

%% Processing
MATPATH = 'E:\ECoG\MAT Data\CC\7-10Freq Active\cc20220519\cc20220519_AC.mat';
ROOTPATH = "D:\Education\Lab\Projects\ECOG\Figures\7-10Freq\";
temp = string(split(MATPATH, '\'));
DateStr = temp(end - 1);
[trialAll, ECOGDataset1] = ECOGPreprocess(MATPATH, params);
params.posIndex = 2; % 1-AC, 2-PFC
[~, ECOGDataset2] = ECOGPreprocess(MATPATH, params);
fs0 = ECOGDataset1.fs;

devFreqAll = [trialAll.devFreq];
stdFreqAll = cellfun(@(x) x(1), {trialAll.freqSeq});
dRatioAll = roundn(devFreqAll ./ stdFreqAll, -2);
dRatio = unique(dRatioAll);
dRatio(dRatio == 0) = [];

%% RSA
window = [-500, 1000];

for dIndex = 1:length(dRatio)
    trials = trialAll(dRatioAll == dRatio(dIndex) & [trialAll.correct]);
    [~, chMean, ~] = selectEcog(ECOGDataset1, trials, "dev onset", window);
    [t, f, TFR1, coi] = computeTFA(chMean, fs0, fs);
    t = t + window(1) / 1000;
    
    [~, chMean, ~] = selectEcog(ECOGDataset2, trials, "dev onset", window);
    [~, ~, TFR2, ~] = computeTFA(chMean, fs0, fs);
    
    rho = zeros(size(TFR1, 2), size(TFR1, 2), size(TFR1, 3));
    for eIndex = 1:size(TFR1, 3)
        rho(:, :, eIndex) = corr(TFR1(:, :, eIndex), TFR2(:, :, eIndex), "type", "Pearson");
    end
    
    figure;
    imagesc('XData', t, 'YData', t, 'CData', rho(:, :, 1));
    hold on;
    plot([min(t) max(t)], [0, 0], "w--", "LineWidth", 1.5);
    plot([0, 0], [min(t) max(t)], "w--", "LineWidth", 1.5);
    xlim([min(t) max(t)]);
    ylim([min(t) max(t)]);
    xlabel('trial time - AC');
    ylabel('trial time - PFC');
    title(['Align to last sound onset - dRatio = ', num2str(dRatio(dIndex))]);
    cb = colorbar;
    ylabel(cb, 'similarity', "FontSize", 12);
    % RSAPATH = strcat(ROOTPATH, DateStr, "\RSA\");
    % mkdir(RSAPATH);
    % print(gcf, strcat(RSAPATH, DateStr), "-djpeg", "-r200");
end