%% comparison between devTypes_ dev Onset 
for gIndex = 1 : length(group_Index)
    temp = group_Index{gIndex};
    group = [];
    for dIndex  = 1 : length(temp)
        dIdx = temp(dIndex);
        group(dIndex).chMean = chMean{dIdx};
        group(dIndex).color = colors(dIndex);
    end
    FigGroup(gIndex) = plotRawWaveMulti_SPR(group, Window);
    addLegend2Fig(FigGroup(gIndex), stimStrs(group_Index{gIndex}));
end

%% comparison between devTypes_ sound Onset
for gIndex = 1 : length(group_Index)
    temp = group_Index{gIndex};
    groupS1 = [];
    for dIndex  = 1 : length(temp)
        dIdx = temp(dIndex);
        groupS1(dIndex).chMean = chMeanS1{dIdx};
        groupS1(dIndex).color = colors(dIndex);
    end
    FigGroupS1(gIndex) = plotRawWaveMulti_SPR(groupS1, Window);
    addLegend2Fig(FigGroupS1(gIndex), stimStrs(group_Index{gIndex}));
end
%% scale
scaleAxes([FigGroup, FigGroupS1] , "x", PlotWin);
scaleAxes([FigGroup, FigGroupS1], "y", "on");
for gIndex = 1 : length(FigGroup)
    print(FigGroup(gIndex), strcat(FIGPATH, group_Str(gIndex)), "-djpeg", "-r200");
    close(FigGroup(gIndex));
end
for gIndex = 1 : length(FigGroupS1)
    print(FigGroupS1(gIndex), strcat(FIGPATH, "S1", group_Str(gIndex)), "-djpeg", "-r200");
    close(FigGroupS1(gIndex));
end