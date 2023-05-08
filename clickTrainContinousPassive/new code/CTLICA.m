function [ECOGDataset, comp, FigICAWave, FigTopo] = CTLICA(ECOGDataset, trialAll, fs, opts)

optsNames = fieldnames(opts);

for index = 1:size(optsNames, 1)
    eval([optsNames{index}, '=opts.', optsNames{index}, ';']);
end

ECOGDatasetTemp = ECOGDataset;


run("CTLconfig.m");
 trialAll([trialAll.devOrdr] == 0) = [];
    devType = unique([trialAll.devOrdr]);
    devTemp = {trialAll.devOnset}';
    [~, ordTemp] = ismember([trialAll.ordrSeq]', devType);
temp = cellfun(@(x, y) x + S1Duration(y), devTemp, num2cell(ordTemp), "UniformOutput", false);
trialAll = addFieldToStruct(trialAll, temp, "devOnset");

%% ICA
trialAll(1) = [];
comp = mICA(ECOGDataset, ICAWin, trialAll([trialAll.oddballType]' ~= "INTERRUPT"), fs, "dev onset");

t1 = -200;
t2 = t1 + 1000;
comp = realignIC(comp, ICAWin, t1, t2);
ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
ICStd = cell2mat(cellfun(@std, changeCellRowNum(comp.trial), "UniformOutput", false));

% plotRawWave(ICMean, [], window, "ICA", [8, 8]);
% % plotTFA(ICMean, fs, [], window, "ICA", [8, 8]);
% plotTopoICA(comp, [8, 8]);
% comp = reverseIC(comp, input("IC to reverse: "));
% ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
FigICAWave = plotRawWave(ICMean, ICStd, Window, "ICA", [8, 8]);
% plotTFA(ICMean, fs, [], window, "ICA", [4, 5]);
FigTopo = plotTopoICA(comp, [8, 8]);

ECOGDataset.data = comp.unmixing * ECOGDatasetTemp.data;
comp = rmfield(comp, "trial");