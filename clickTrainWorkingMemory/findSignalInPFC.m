posStr = ["LAuC", "LPFC"];
apStr = ["Active", "Passive"];
activeOrPassive = 1; % 1:active / 2:passive
pos = 2; % 1:LAuC / 2:LPFC
matPath = strcat("E:\ECoG\matData\behavior\ClickTrainOddCompareTone\", apStr(activeOrPassive), "\xx20220805");
load(strcat(matPath, "\", posStr(pos), "_MMNData.mat"));


plotSize = [8, 8];
chs = (1 : 64)';

for dIndex = 1 : length(MMNData)
    if mod(dIndex, 2) == 1
%         devCompare_Wave(ceil(dIndex / 2)) = plotRawWave(MMNData(dIndex).chMeanDEV, [], MMNData(dIndex).window, strcat( MMNData(dIndex).pairStr, posStr(pos), " dev reg vs irreg"), plotSize, chs, "on");
        devCompare_Wave(ceil(dIndex / 2)) = plotRawWave(MMNData(dIndex).chMeanDEVICA, [], MMNData(dIndex).window, strcat( MMNData(dIndex).pairStr, posStr(pos), " dev reg vs irreg"), plotSize, chs, "on");

        setLine(devCompare_Wave(ceil(dIndex / 2)), "Color", "blue", "LineStyle", "-");

    else
%         devCompare_Wave(ceil(dIndex / 2)) = plotRawWave2(devCompare_Wave(ceil(dIndex / 2)), MMNData(dIndex).chMeanDEV, [], MMNData(dIndex).window, 'red');
        devCompare_Wave(ceil(dIndex / 2)) = plotRawWave2(devCompare_Wave(ceil(dIndex / 2)), MMNData(dIndex).chMeanDEVICA, [], MMNData(dIndex).window, 'red');
    end
end

scaleAxes(devCompare_Wave, "y", [], [-60, 60]);