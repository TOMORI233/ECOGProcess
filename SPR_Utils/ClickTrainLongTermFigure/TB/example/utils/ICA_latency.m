function [comp, IC, FigTopo] = ICA_latency(trialsECOG, opts)

optsNames = fieldnames(opts);

for index = 1:size(optsNames, 1)
    eval([optsNames{index}, '=opts.', optsNames{index}, ';']);
end


comp = mICA2(trialsECOG, sampleinfo, chs, Window, fs);

t1 = -10;
t2 = t1 + 300;
comp = realignIC(comp, Window, t1, t2);
ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
ICStd = cell2mat(cellfun(@std, changeCellRowNum(comp.trial), "UniformOutput", false));
chPlot = reshape(1:12, 3, 4);
FigICAWave = plotRawWave(ICMean, ICStd, Window, "ICA", [3, 4], 1 : 12);
Fig = plotTopoICA(comp, [8, 8], [3, 4]);
scaleAxes(FigICAWave, "y", [], [-8 8], "max");
IC = input("Selected IC: ");
close(Fig);
close(FigICAWave);

FigTopo = plotTopoICA(comp, [8, 8], [1, 1], IC);
set(FigWave(mIndex), "outerposition", [300, 100, 800, 670]);


