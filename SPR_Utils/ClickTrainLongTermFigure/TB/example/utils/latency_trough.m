%% Raw
[latency_mean, latency_se, latency_raw, smthWave] = waveLatency_trough(trialsECOG, Window, latencyWin, 50, fs); %
smthWave = changeCellRowNum(smthWave);

chMean = cell2mat(cellfun(@mean , changeCellRowNum(trialsECOG), 'UniformOutput', false));
smthMean = cell2mat(cellfun(@mean , changeCellRowNum(smthWave), 'UniformOutput', false));

FIGRAW = figure;
chSel = 13;
quantIdx = t > quantWin(1) & t < quantWin(2);
lantencyIdx = t > latencyWin(1) & t < latencyWin(2);
subplot(1,2,1);
for tIndex = 1 : length(trialsECOG)
    plot(linspace(latencyWin(1), latencyWin(2), sum(lantencyIdx)) ,trialsECOG{tIndex}(chSel, lantencyIdx), 'k-'); hold on;
    %             plot(linspace(quantWin(1), quantWin(2), sum(quantIdx)) ,trialsECOG{tIndex}(chSel, quantIdx), 'r-'); hold on;
end
plot(linspace(latencyWin(1), latencyWin(2), sum(lantencyIdx)) ,chMean(chSel, lantencyIdx), 'r-', "LineWidth", 3); hold on;

subplot(1,2,2);
for tIndex = 1 : length(trialsECOG)
    plot(linspace(latencyWin(1), latencyWin(2), sum(lantencyIdx)) ,smthWave{tIndex}(chSel, :), 'k-'); hold on;
end
plot(linspace(latencyWin(1), latencyWin(2), sum(lantencyIdx)) ,smthMean(chSel, :), 'r-', "LineWidth", 3); hold on;

%% ICA
opts.chs = 1 : size(trialsECOG{1}, 1);
opts.sampleinfo = [zeros(length(trialsECOG), 1) ones(length(trialsECOG), 1)];
opts.Window = Window;
opts.fs = fs;

[comp{dIndex}, IC(dIndex), FigTopo(dIndex)] = ICA_latency(trialsECOG, opts);
trialsICA = cellfun(@(x) comp{dIndex}.unmixing * x, trialsECOG, "UniformOutput", false);
[latency_mean, latency_se, latency_raw, smthWave] = waveLatency_trough(trialsICA, Window, latencyWin, 50, fs); %
smthWave = changeCellRowNum(smthWave);

ICAMean = cell2mat(cellfun(@mean , changeCellRowNum(trialsICA), 'UniformOutput', false));
smthMean = cell2mat(cellfun(@mean , changeCellRowNum(smthWave), 'UniformOutput', false));
FIGRAW = figure;
chSel = IC(dIndex);
quantIdx = t > quantWin(1) & t < quantWin(2);
lantencyIdx = t > latencyWin(1) & t < latencyWin(2);
subplot(1,2,1);
for tIndex = 1 : length(trialsECOG)
    plot(linspace(latencyWin(1), latencyWin(2), sum(lantencyIdx)) ,trialsICA{tIndex}(chSel, lantencyIdx), 'k-'); hold on;
end
plot(linspace(latencyWin(1), latencyWin(2), sum(lantencyIdx)) ,ICAMean(chSel, lantencyIdx), 'r-', "LineWidth", 3); hold on;
subplot(1,2,2);
for tIndex = 1 : length(trialsECOG)
    plot(linspace(latencyWin(1), latencyWin(2), sum(lantencyIdx)) ,smthWave{tIndex}(chSel, :), 'k-'); hold on;
end
plot(linspace(latencyWin(1), latencyWin(2), sum(lantencyIdx)) ,smthMean(chSel, :), 'r-', "LineWidth", 3); hold on;
