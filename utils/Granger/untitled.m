ccc;

dataAC = load("..\..\7-10Freq\batch\Active\CC\Population\Prediction\AC_Prediction_Data.mat");
dataPFC = load("..\..\7-10Freq\batch\Active\CC\Population\Prediction\PFC_Prediction_Data.mat");

% dataAC = load("..\..\7-10Freq\batch\Active\CC\Population\PE\AC_PE_Data.mat");
% dataPFC = load("..\..\7-10Freq\batch\Active\CC\Population\PE\PFC_PE_Data.mat");

% trialsECOG_AC = dataAC.trialsECOG([dataAC.dRatioAll] == 1);
% trialsECOG_PFC = dataPFC.trialsECOG([dataPFC.dRatioAll] == 1);
% trialsECOG_AC = dataAC.trialsECOG([dataAC.dRatioAll] > 1);
% trialsECOG_PFC = dataPFC.trialsECOG([dataPFC.dRatioAll] > 1);

trialsECOG_AC = dataAC.trialsECOG;
trialsECOG_PFC = dataPFC.trialsECOG;

window = dataAC.windowP;
fs = dataAC.fs;

nChsAC = size(trialsECOG_AC{1}, 1);
nChsPFC = size(trialsECOG_PFC{1}, 1);

nTime = size(trialsECOG_AC{1}, 2);
t = linspace(window(1), window(2), nTime);

%% 
% window1 = [2000, 5000];
% tIdx = fix((window1(1) - window(1)) / 1000 * fs):fix((window1(2) - window(1)) / 1000 * fs);
% trialsECOG_AC  = cellfun(@(x) x(:, tIdx), trialsECOG_AC, "UniformOutput", false);
% trialsECOG_PFC = cellfun(@(x) x(:, tIdx), trialsECOG_PFC, "UniformOutput", false);
% 
% nTime = size(trialsECOG_AC{1}, 2);
% t = linspace(window1(1), window1(2), nTime);

% for cIndexAC = 1:nChsAC
%     for cIndexPFC = 1:nChsPFC
%         tempAC = cellfun(@(x) x(cIndexAC, :), trialsECOG_AC, "UniformOutput", false);
%         tempPFC = cellfun(@(x) x(cIndexPFC, :), trialsECOG_PFC, "UniformOutput", false);
%         res = mGrangerWavelet(tempAC, tempPFC, fs);
%     end
% end

for cIndexAC = 7
    for cIndexPFC = 35
        tempAC = cellfun(@(x) x(cIndexAC, :), trialsECOG_AC, "UniformOutput", false);
        tempPFC = cellfun(@(x) x(cIndexPFC, :), trialsECOG_PFC, "UniformOutput", false);
        res = mGrangerWaveletRaw(tempAC, tempPFC, fs, [], 10);
    end
end

%%
figure;
maximizeFig;
mSubplot(1, 2, 1);
mask = squeeze(max(res.grangerspctrm(1, :, :, 2:end), [], [2, 3]));
temp = squeeze(res.grangerspctrm(1, :, :, 1));
% temp = temp .* (temp > max(mask));
imagesc("XData", t, "YData", res.freq, "CData", temp);
hold on;
plot(t, res.coi, "w--", "LineWidth", 1.5);
set(gca, "YScale", "log");
yticks([0, 2.^(0:nextpow2(max(res.freq)) - 1)]);
set(gca, "XLimitMethod", "tight");
set(gca, "YLimitMethod", "tight");
title('From AC-1 to PFC-1');

mSubplot(1, 2, 2);
mask = squeeze(max(res.grangerspctrm(2, :, :, 2:end), [], [2, 3]));
temp = squeeze(res.grangerspctrm(2, :, :, 1));
% temp = temp .* (temp > max(mask));
imagesc("XData", t, "YData", res.freq, "CData", temp);
hold on;
plot(t, res.coi, "w--", "LineWidth", 1.5);
set(gca, "YScale", "log");
yticks([0, 2.^(0:nextpow2(max(res.freq)) - 1)]);
set(gca, "XLimitMethod", "tight");
set(gca, "YLimitMethod", "tight");
title('From PFC-1 to AC-1');

colormap('jet');
scaleAxes("c");
scaleAxes("x", [-100, 3500]);
addLines2Axes(struct("X", num2cell((0:6)' * dataAC.trialAll(1).ISI), "color", "w", "width", 1.5));
% addLines2Axes(struct("X", 0, "color", "w", "width", 1.5));
colorbar('position', [0.96, 0.1, 0.5 * 0.03, 0.8]);