chSelect = 3; 
toPlot = cell2mat(cellfun(@(x, y) [x, ones(length(x), 1)*y], {spikeRes(chSelect).data.spike}', num2cell(1:length(spikeRes(chSelect).data))', "UniformOutput", false));
 MUARawPot = cellfun(@(x) x-mean(x(:, MUA.tWave > -100 & MUA.tWave < 0), 2), MUA.rawWave, "UniformOutput", false);
 MUAPlot = MUA.Wave-mean(MUA.Wave(:, MUA.tWave > -100 & MUA.tWave < 0), 2);
 trialsWAVE = changeCellRowNum(trialsWAVE);