clc; clear;
BLOCKPATH = 'D:\ECoG\xiaoxiao\xx20220817\Block-1';
temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs'});
epocs = temp.epocs;
temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'streams'}, 'STORE', {'LAuC'});
ECOGDataset = temp.streams.LAuC;
choiceWin = [100, 800]; % ms
trialAll = ActiveProcess_1_9Freq(epocs);

temp = [];
temp.data = ECOGDataset.data(17, :);
temp.channels = 17;
temp.fs = ECOGDataset.fs;
trialsECOG1 = cell2mat(selectEcog(temp, trialAll, "dev onset", [0, 200]));
trialsECOG2 = cell2mat(selectEcog(temp, trialAll, "last std", [0, 200]));
trialsECOG = [trialsECOG1; trialsECOG2];
[~, pcaData, k] = mPCA(double(trialsECOG), 0.9);
pcaData = pcaData(:, 1:k);
K = elbow_method(pcaData);
[idx, C, ~] = kmeans(pcaData, K);

result.clusterIdx = idx;
result.pcaData = pcaData;
result.K = K;
result.chanIdx = 1;
result.wave = trialsECOG;
plotPCA(result, [1 2]);

result.clusterIdx = [ones(length(trialAll), 1); 2 * ones(length(trialAll), 1)];
result.pcaData = pcaData;
result.K = length(unique(result.clusterIdx));
result.chanIdx = 1;
result.wave = trialsECOG;
plotPCA(result, [1 2]);