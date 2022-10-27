Fig_RegIrreg = plotRawWave(filterRes(1).chMean, [], [filterRes(1).t(1) filterRes(1).t(end)], "Reg vs Irreg", [8, 8], (1 : 64)', "on");
lineSetting.color = "k";
Fig_RegIrreg = plotRawWave2(Fig_RegIrreg, filterRes(3).chMean, [], [filterRes(3).t(1) filterRes(3).t(end)], lineSetting);
scaleAxes(Fig_RegIrreg,'y', [-60 60 ]);
scaleAxes(Fig_RegIrreg,'x', [-1000 2000 ]);
    