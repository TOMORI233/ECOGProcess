%%  compute CRI/ORI and plot CRI/ORI topo
devType = unique([trialAll.devOrdr]);
t = linspace(Window(1), Window(2), diff(Window) /1000 * fs + 1)';
for dIndex = 1:length(devType)
    tIndex = [trialAll.devOrdr] == devType(dIndex);
    trials = trialAll(tIndex);
    trialsECOG = trialsECOG_Merge(tIndex);
    trialsECOG_S1 = trialsECOG_S1_Merge(tIndex);

    % compute CRI
    [temp, amp, rmsSpon] = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trialsECOG, 'UniformOutput', false);
    CRI(dIndex).info = stimStrs(dIndex);
    CRI(dIndex).mean = cellfun(@mean, changeCellRowNum(temp));
    CRI(dIndex).se = cellfun(@(x) std(x)/sqrt(length(x)), changeCellRowNum(temp));
    CRI(dIndex).raw = changeCellRowNum(temp);
    CRI(dIndex).rsp = changeCellRowNum(amp);
    CRI(dIndex).base = changeCellRowNum(rmsSpon);


    % compute ORI
    [temp, ampS1, rmsSponS1] = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trialsECOG_S1, 'UniformOutput', false);
    ORI(dIndex).info = stimStrs(dIndex);
    ORI(dIndex).mean = cellfun(@mean, changeCellRowNum(temp));
    ORI(dIndex).se = cellfun(@(x) std(x)/sqrt(length(x)), changeCellRowNum(temp));
    ORI(dIndex).raw = changeCellRowNum(temp);
    ORI(dIndex).rsp = changeCellRowNum(ampS1);
    ORI(dIndex).base = changeCellRowNum(rmsSponS1);

    %         % CRI topo
    %         topo_Reg = CRI(dIndex).mean;
    %         topo_Reg_S1 = ORI(dIndex).mean;
    %         FigTopo(dIndex) = plotTopo_Raw(topo_Reg, [8, 8]);
    %         FigTopo_S1(dIndex) = plotTopo_Raw(topo_Reg_S1, [8, 8]);
    %         colormap(FigTopo(dIndex), "jet"); colormap(FigTopo_S1(dIndex), "jet");
    %         scaleAxes(FigTopo(dIndex), "c", CRIScale{mIndex}(CRIMethod, :));
    %         scaleAxes(FigTopo_S1(dIndex), "c", CRIScale{mIndex}(CRIMethod, :));
    %         pause(1);
    %         set([FigTopo(dIndex), FigTopo_S1(dIndex)], "outerposition", [300, 100, 800, 670]);
    %         print(FigTopo(dIndex), strcat(FIGPATH,  stimStrs(dIndex), "_CRI_Topo"), "-djpeg", "-r200");
    %         print(FigTopo_S1(dIndex), strcat(FIGPATH, stimStrs(dIndex), "_CRI_Topo_S1"), "-djpeg", "-r200");
end
close all