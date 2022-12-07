function [comp, IC] = ICA_ExcludeArtifacts(trialsECOG, opts)

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

FigICAWave = plotRawWave(ICMean, ICStd, Window, "ICA", [8, 8]);
FigTopo = plotTopo(comp, [8, 8]);
scaleAxes(FigICAWave, "y", [], [-8 8], "max");
IC = input("ICs to exclude: ");
close(FigTopo);
close(FigICAWave);
comp = rmfield(comp, "trial");

