%% Tuning topo of DRP
FigTopo = figure;
maximizeFig(FigTopo);
paddings = [0.1, 0.1, 0.01, 0.01];

subplotNumDRP = [1:6, 13:18];
subplotNumP = [7:12, 19:24];

cmSig = colormap('jet');
cmSig(1:129, :) = repmat([1 1 1], [129, 1]);

for wIndex = 1:12
    % DRP
    mAxesDRP(wIndex) = mSubplot(FigTopo, 4, 6, subplotNumDRP(wIndex), 1, "paddings", paddings, "shape", "square-min");
    tuning = resDP(wIndex).v - 0.5;
    plotTopo(tuning, "contourOpt", "on");
    plotLayout(gca, (monkeyID - 1) * 2 + posIndex, 0.4);
    title(['DRP topo [', num2str(resDP(wIndex).window(1)), ' ', num2str(resDP(wIndex).window(2)), ']']);

    % p
    mAxesP(wIndex) = mSubplot(FigTopo, 4, 6, subplotNumP(wIndex), 1, "paddings", paddings, "shape", "square-min");
    P = resDP(wIndex).p;
    P(P == 0) = 1 / nIter;
    P = log(P / alpha) / log(alpha_log);
    plotTopo(P, "contourOpt", "on");
    plotLayout(gca, (monkeyID - 1) * 2 + posIndex, 0.4);
    title(['p topo [', num2str(resDP(wIndex).window(1)), ' ', num2str(resDP(wIndex).window(2)), ']']);
    colormap(mAxesP(wIndex), cmSig);
end
scaleAxes(mAxesDRP, "c", "symOpts", "max");
scaleAxes(mAxesP, "c", "symOpts", "max");
cb1 = colorbar(mAxesDRP(end), 'position', [0.95, 0.1, 0.01, 0.8]);
cb1.Label.String = "DRP value";
cb1.Label.FontSize = 15;
cb1.Label.VerticalAlignment = 'bottom';
cb1.Label.Rotation = -90;
cb2 = colorbar(mAxesP(end), 'position', [0.05, 0.1, 0.01, 0.8]);
cb2.Label.String = ['ANOVA p=log_{', num2str(alpha_log), '}(p/', num2str(alpha), ')'];
cb2.Label.FontSize = 15;
setAxes(FigTopo, "visible", "off");
mPrint(FigTopo, [MONKEYPATH, AREANAME, '_DM_Topo.jpg'], "-djpeg", "-r600");