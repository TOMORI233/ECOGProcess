    %% latency topo

    for dIndex = 1:length(devType)
        sigCh = cell2mat(sponH{dIndex}) == 1;
        topo_Latency = latency(dIndex).(strcat(monkeyStr(mIndex), "_mean"));
        if ~isempty(badChs{mIndex})
            topo_Latency(badChs{mIndex}) = quantWin(2);
        end
        topo_Latency(~sigCh) = quantWin(2);
        topo_Latency = ((quantWin(2) - topo_Latency)/quantWin(2)).^2;
        FigTopo_Latency(dIndex) = plotTopo_Raw(topo_Latency, [8, 8]);
        colormap(FigTopo_Latency(dIndex), "jet");
        scaleAxes(FigTopo_Latency(dIndex), "c", [0 0.5]);
        pause(1);
        set(FigTopo_Latency(dIndex), "outerposition", [300, 100, 800, 670]);
        print(FigTopo_Latency(dIndex), strcat(FIGPATH,  Protocol, "_", stimStrs(dIndex), "_Latency_Topo_Reg"), "-djpeg", "-r200");
    end
