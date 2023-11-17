clc; clear; close all
%% load path
dateStr = "cc20230710";
% dateStr = "xx20230707";
rootPath = "E:\ECOG\corelDraw\ClickTrainLongTerm\Anesthesia";
Protocol = "Figure_Anesthesia_BaseICI_Ratio_Tone_Push";
ketamin_8_Path = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-7_AC\Figures\");
ketamin_stop20 = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-9_AC\Figures\");
ketamin_stop40 = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-10_AC\Figures\");
ketamin_stop60 = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-11_AC\Figures\");
ketamin_stop80 = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-12_AC\Figures\");
awakePath = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-2_AC\Figures\");
MATNAME = "cdrPlotFilter.mat";
data.Awake = load(strcat(awakePath, MATNAME));
if length(data.Awake) > 4
    data.Awake.RegRatio(5) = [];  data.Awake.RegRatioS1(5) = [];
end


MATNAME = "cdrPlotFilter.mat";
data.Ket8 = load(strcat(ketamin_8_Path, MATNAME));
data.stop0_20 = load(strcat(ketamin_stop20, MATNAME));
data.stop20_40 = load(strcat(ketamin_stop40, MATNAME));
data.stop40_60 = load(strcat(ketamin_stop60, MATNAME));
data.stop60_80 = load(strcat(ketamin_stop80, MATNAME));
data.Awake = load(strcat(awakePath, MATNAME));
data.Awake.RegRatio(5) = [];  data.Awake.RegRatioS1(5) = [];


%% diff stim under same level
Window = data.Awake.Window;
states = string(fields(data));
stimStrs = ["4-4o06", "8-8o12", "4-5", "250-200Hz"];
for sIndex = 1 : length(states)
    clear chPlot
    chPlot = data.(states(sIndex)).RegRatio;
    for dIndex = 1 : length(stimStrs)
        chPlot(dIndex).width = 2;
    end
    FigWave = plotRawWaveMulti_SPR(chPlot, Window, strrep(states(sIndex), "_", "-"), [8, 8]);
    scaleAxes(FigWave, "y", [-20, 20]);
    scaleAxes(FigWave, "x", [-100, 500]);
    addLegend2Fig(FigWave, strrep(stimStrs, "_", "-"));
    FIGPATH = strcat(rootPath, "\Anesthesia_Compare\",  dateStr, "\diffStimComparison\");
    mkdir(FIGPATH);
    print(FigWave, strcat(FIGPATH, states(sIndex)), "-djpeg", "-r200");
end
close all

%% waveform comparison
Window = data.Awake.Window;
stateColors = flip(["#FF0000", "#FFAA00", "#00FF00", "#0000FF", "#000000", "#888888"]);
states = string(fields(data));
stimStrs = ["4-4o06", "8-8o12", "4-5", "250-200Hz"];
for dIndex = 1 : length(stimStrs)
    clear chPlot
    statesData = structfun(@(x) x.RegRatio(dIndex), data, "UniformOutput", false);
    for sIndex = 1 : length(states)
        chPlot(sIndex).chMean = statesData.(states(sIndex)).chMean;
        chPlot(sIndex).color = stateColors(sIndex);
        chPlot(sIndex).width = 2;
    end
    FigWave = plotRawWaveMulti_SPR(chPlot, Window, stimStrs(dIndex), [8, 8]);
    scaleAxes(FigWave, "y", [-20, 20]);
    scaleAxes(FigWave, "x", [-100, 500]);
    addLegend2Fig(FigWave, strrep(states, "_", "-"));
    FIGPATH = strcat(rootPath, "\Anesthesia_Compare\", dateStr, "\Anesthesia2Awake\");
    mkdir(FIGPATH);
    print(FigWave, strcat(FIGPATH, stimStrs(dIndex)), "-djpeg", "-r200");

end
close all



%% waveform comparison S1
Window = data.Awake.Window;
stateColors = flip(["#FF0000", "#FFAA00", "#00FF00", "#0000FF", "#000000", "#888888"]);
states = string(fields(data));
stimStrs = ["4-4o06", "8-8o12", "4-5", "250-200Hz"];
for dIndex = 1 : length(stimStrs)
    clear chPlot
    statesData = structfun(@(x) x.RegRatioS1(dIndex), data, "UniformOutput", false);
    for sIndex = 1 : length(states)
        chPlot(sIndex).chMean = statesData.(states(sIndex)).chMean;
        chPlot(sIndex).color = stateColors(sIndex);
        chPlot(sIndex).width = 2;
    end
    FigWave = plotRawWaveMulti_SPR(chPlot, Window, stimStrs(dIndex), [8, 8]);
    scaleAxes(FigWave, "y", [-40, 40]);

    scaleAxes(FigWave, "x", [-100, 500]);
    addLegend2Fig(FigWave, strrep(states, "_", "-"));
    FIGPATH = strcat(rootPath, "\Anesthesia_Compare\", dateStr, "\Anesthesia2Awake\");
    mkdir(FIGPATH);
    print(FigWave, strcat(FIGPATH, stimStrs(dIndex), "_S1"), "-djpeg", "-r200");
end
close all

%% CRI tuning
stimColors = ["#FF0000", "#FFAA00",  "#0000FF", "#000000"];
clear chPlot statesData
for dIndex = 1 : length(stimStrs)
    statesData = structfun(@(x) x.CRI(dIndex), data, "UniformOutput", false);
    for sIndex = 1 : length(states)
        chPlot(dIndex).chMean(:, sIndex) = statesData.(states(sIndex)).mean;
        %             chPlot(dIndex).chStd(:, sIndex) = statesData.(states(sIndex)).se;
    end
    chPlot(dIndex).color = stimColors(dIndex);
    chPlot(dIndex).width = 2;
end
FigWave = plotRawWaveMulti_SPR(chPlot, [1, 4], stimStrs(dIndex), [8, 8]);
scaleAxes(FigWave, "y", [0, 0.3]);
scaleAxes(FigWave, "x", [0.5, 4.5]);
addLegend2Fig(FigWave, strrep(stimStrs, "_", "-"));
    FIGPATH = strcat(rootPath, "\Anesthesia_Compare\", dateStr, "\Anesthesia2Awake\");
mkdir(FIGPATH);
print(FigWave, strcat(FIGPATH, "CRI_Tuning"), "-djpeg", "-r200");
close all