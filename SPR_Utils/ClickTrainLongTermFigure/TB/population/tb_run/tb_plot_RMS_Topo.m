% RMS topo
[~, neighbours] = mPrepareNeighbours(1:64, [8,8]);
run("CTLconfig.m");
if contains(FIGPATH, "CC")
    badCHSel = [16];
end
devType = unique([trialAll.devOrdr]);
t = linspace(Window(1), Window(2), diff(Window) /1000 * fs + 1)';
for dIndex = 1:length(devType)
    topo_Reg = cellfun(@mean, CRI_Boot(dIndex).rsp);
    for i = 1:length(badCHSel)
        topo_Reg(badCHSel(i)) = mean(topo_Reg(neighbours{badCHSel(i)}));
    end
    FigTopo(dIndex) = plotTopo_Raw(topo_Reg, [8, 8]);
    colormap(FigTopo(dIndex), "jet"); 
    scaleAxes(FigTopo(dIndex), "c", [0, 15]);
    pause(1);
    set(FigTopo(dIndex), "outerposition", [300, 100, 800, 670]);
    print(FigTopo(dIndex), strcat(FIGPATH,  stimStrs(dIndex), "_RMS_Topo"), "-djpeg", "-r200");
end
close all