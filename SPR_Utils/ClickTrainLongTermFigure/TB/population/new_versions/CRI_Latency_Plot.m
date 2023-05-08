%% mean and SE of CRI
CRI_Mean = mean(compare.CRI_SigMean(:, 2:end), 2);
CRI_SE = SE(compare.CRI_SigMean(:, 2:end), 2);

%% mean and SE of latency
Latency_Mean = mean(compare.latency_CR(2).Sig(:, 2:2:end), 2);
Latency_SE = SE(compare.latency_CR(2).Sig(:, 2:2:end), 2);