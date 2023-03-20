devType = unique([trialAll.devOrdr]);
if contains(FIGPATH, "CC")
    CLim = 10;
elseif contains(FIGPATH, "XX")
    CLim = 10;
end

%% plot p-value topo
for dIndex = 3 : length(devType)
    temp = fftPValue(dIndex).pValue;
%     temp = fftPValue(dIndex).FFT_Ratio;
    topo = logg(pBase, temp/pBase);
    topo(isinf(topo)) = CLim;
    topo(topo > CLim) = CLim;
    FigTopo(dIndex) = plotTopo_Raw(topo, [8, 8]);
    colormap(FigTopo(dIndex), "jet");
    scaleAxes(FigTopo(dIndex), "c", [0 1]*CLim);
    Image = FigTopo(dIndex).Children(2).Children(2);
    FigTopo(dIndex).Children(2).Children(2).AlphaData = Image.CData > 0;
    delete(FigTopo(dIndex).Children(2).Children(1)); % delete contour
    delete(FigTopo(dIndex).Children(1)); % delete colorbar
    pause(1);
    set(FigTopo(dIndex), "outerposition", [300, 100, 800, 670]);
    setAxes(FigTopo(dIndex), 'visible', 'off');
    plotLayout(gca, (mIndex - 1) * 2 + 1, 0.4);
    print(FigTopo(dIndex), strcat(FIGPATH, stimStrs(dIndex), "_FFT_pValue_Topo"), "-djpeg", "-r200");
end

%% plot FFT Ratio topo
for dIndex = 3 : length(devType)
    topo = fftPValue(dIndex).FFT_Ratio;
    FigTopo(dIndex) = plotTopo_Raw(topo, [8, 8]);
    colormap(FigTopo(dIndex), "jet");
    scaleAxes(FigTopo(dIndex), "c", [0 5]);
    Image = FigTopo(dIndex).Children(2).Children(2);
    FigTopo(dIndex).Children(2).Children(2).AlphaData = Image.CData > 0;
    delete(FigTopo(dIndex).Children(2).Children(1)); % delete contour
    delete(FigTopo(dIndex).Children(1)); % delete colorbar

 

    pause(1);
    set(FigTopo(dIndex), "outerposition", [300, 100, 800, 670]);
    setAxes(FigTopo(dIndex), 'visible', 'off');
    plotLayout(gca, (mIndex - 1) * 2 + 1, 0.4);
    print(FigTopo(dIndex), strcat(FIGPATH, stimStrs(dIndex), "_FFT_Ratio_Topo"), "-djpeg", "-r200");
end

close all