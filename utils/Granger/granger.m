ccc;

SAVEROOTPATH = 'F:\Lab\Projects\ECOG\Granger Causality\DATA\prediction';

% Prediction
load("D:\Lab members\KXK\TrialDataAreas.mat");



% dataAC = load("..\..\7-10Freq\batch\Active\CC\Population\Prediction\AC_Prediction_Data.mat");
% dataPFC = load("..\..\7-10Freq\batch\Active\CC\Population\Prediction\PFC_Prediction_Data.mat");
window = DataAC.window;

trialsECOG_AC = DataAC.trialsECOG;
trialsECOG_PFC = DataPFC.trialsECOG;

% PE
% dataAC = load("..\..\7-10Freq\batch\Active\CC\Population\PE\AC_PE_Data.mat");
% dataPFC = load("..\..\7-10Freq\batch\Active\CC\Population\PE\PFC_PE_Data.mat");
% window = dataAC.windowPE;
% 
% trialsECOG_AC = dataAC.trialsECOG([dataAC.dRatioAll] == 1);
% trialsECOG_PFC = dataPFC.trialsECOG([dataPFC.dRatioAll] == 1);
% trialsECOG_AC = dataAC.trialsECOG([dataAC.dRatioAll] > 1);
% trialsECOG_PFC = dataPFC.trialsECOG([dataPFC.dRatioAll] > 1);

fs = DataAC.fs;

nChsAC = size(trialsECOG_AC{1}, 1);
nChsPFC = size(trialsECOG_PFC{1}, 1);

t = linspace(window(1), window(2), size(trialsECOG_AC{1}, 2));

nperm = 0;
fRange = [0, 70];

windowNew = [0, 5000]; % from 1st to 10th ISI

%% 
[~, f, coi] = cwtAny(trialsECOG_AC, fs, "mode", "CPU");

fIdx = find(f < fRange(2), 1) - 1:length(f);
f = f(fIdx);

tIdx = find(t >= windowNew(1), 1):find(t >= windowNew(2), 1);
t = t(tIdx);
coi = coi(tIdx);

for cIndex = 1:nChsAC
    temp = cellfun(@(x) x(cIndex, :), trialsECOG_AC, "UniformOutput", false);
    cwtres = cwtAny(temp, fs, 10, "mode", "GPU");
    cwtres = cwtres(:, :, fIdx, tIdx);
    save(fullfile(SAVEROOTPATH, ['cwt result\cwtres_AC-', num2str(cIndex), '.mat']), "cwtres", "f", "coi", "t");
end

for cIndex = 1:nChsPFC
    temp = cellfun(@(x) x(cIndex, :), trialsECOG_PFC, "UniformOutput", false);
    cwtres = cwtAny(temp, fs, 10, "mode", "GPU");
    cwtres = cwtres(:, :, fIdx, tIdx);
    save(fullfile(SAVEROOTPATH, ['cwt result\cwtres_PFC-', num2str(cIndex), '.mat']), "cwtres", "f", "coi", "t");
end

%%
load(fullfile(SAVEROOTPATH, 'cwt result\cwtres_AC-1.mat'), "f", "coi");

for cIndexAC = 1:nChsAC
    cwtresAC = load(fullfile(SAVEROOTPATH, ['cwt result\cwtres_AC-', num2str(cIndexAC), '.mat'])).cwtres;
    for cIndexPFC = 1:nChsPFC
        if exist(fullfile(SAVEROOTPATH, ['granger result\grangerres_AC-', num2str(cIndexAC), '_PFC-', num2str(cIndexPFC), '.mat']), "file")
            disp([fullfile(SAVEROOTPATH, ['granger result\grangerres_AC-', num2str(cIndexAC), '_PFC-', num2str(cIndexPFC), '.mat']), ' exist. Skip']);
            continue;
        end
        cwtresPFC = load(fullfile(SAVEROOTPATH, ['cwt result\cwtres_PFC-', num2str(cIndexPFC), '.mat'])).cwtres;
        temp = cat(2, cwtresAC, cwtresPFC);
        res = mGrangerWaveletFourier(temp, f, coi, fs, fRange, nperm);
        res.channelcmb([1, 4]) = {['AC-', num2str(cIndexAC)]};
        res.channelcmb([2, 3]) = {['PFC-', num2str(cIndexPFC)]};
        res.time = t;
        mSave(fullfile(SAVEROOTPATH, ['granger result\grangerres_AC-', num2str(cIndexAC), '_PFC-', num2str(cIndexPFC), '.mat']), "res");
    end
end


%%
t = res.time;

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
scaleAxes("c", "on");
scaleAxes("x", [-200, 800]);
addLines2Axes(struct("X", 0, "color", "w", "width", 1.5));
% scaleAxes("x", [-100, 3500]);
% addLines2Axes(struct("X", num2cell((0:6)' * dataAC.trialAll(1).ISI), "color", "w", "width", 1.5));
colorbar('position', [0.96, 0.1, 0.5 * 0.03, 0.8]);