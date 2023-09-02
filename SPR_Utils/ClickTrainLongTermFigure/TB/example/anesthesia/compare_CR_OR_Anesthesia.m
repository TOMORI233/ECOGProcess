
rspRatio = cell2mat(cellfun(@(x, y) mean(x./y), CRI(1).rsp, ORI(1).rsp, "UniformOutput", false));
badCH = find(rspRatio > 0.95);

trialsECOG = trialsECOG_S1_Merge([trialAll.devOrdr] == 1);

 wave = changeCellRowNum(cellfun(@(x) x(:, tIndex), trialsECOG, "UniformOutput", false));
cellfun(@(x) rms(x, 2), wave, "UniformOutput", false);

%% 麻醉之后的change反应与onset比较
tIndex = t>quantWin(1) & t<quantWin(2);
CRsp = cellfun(@(x) rms(x(:, tIndex), 2), chMean, "UniformOutput", false);
ORsp = cellfun(@(x) rms(x(:, tIndex), 2), chMeanS1, "UniformOutput", false);
rspRatio = cell2mat(cellfun(@(x, y) x./y, CRsp, ORsp, "UniformOutput", false));


%% 麻醉之前的change反应与onset比较
tIndex = t>quantWin(1) & t<quantWin(2);
tIndex2 = t+5004.1>quantWin(1) & t+5004.1<quantWin(2);
CRsp = cellfun(@(x) rms(x(:, tIndex), 2), chMean, "UniformOutput", false);
ORsp = cellfun(@(x) rms(x(:, tIndex2), 2), chMeanS1, "UniformOutput", false);
rspRatio = cell2mat(cellfun(@(x, y) x./y, CRsp, ORsp, "UniformOutput", false));

