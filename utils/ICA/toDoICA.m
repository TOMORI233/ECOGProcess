function [ECOGDataset, comp, FigICAWave, FigTopo] = toDoICA(ECOGDataset, trialAll, fs)
ECOGDatasetTemp = ECOGDataset;

%% ICA
window  = [-2000, 2000];
comp = mICA(ECOGDataset, trialAll([trialAll.oddballType]' ~= "INTERRUPT"), window, "dev onset", fs);

t1 = [-2000, -1500, -1000, -500, 0];
t2 = t1 + 200;
comp = realignIC(comp, window, t1, t2);
ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
% plotRawWave(ICMean, [], window, "ICA", [8, 8]);
% % plotTFA(ICMean, fs, [], window, "ICA", [8, 8]);
% plotTopo(comp, [8, 8]);
% 
% 
% comp = reverseIC(comp, input("IC to reverse: "));
% ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
FigICAWave = plotRawWave(ICMean, [], window, "ICA", [8, 8]);
% plotTFA(ICMean, fs, [], window, "ICA", [4, 5]);
FigTopo = plotTopo(comp, [8, 8]);

ECOGDataset.data = comp.unmixing * ECOGDatasetTemp.data;
comp = rmfield(comp, "trial");