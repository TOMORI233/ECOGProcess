clc; clear; close all
%% load path
dateStr = "cc20230714";
% dateStr = "xx20230712";
rootPath = "E:\ECOG\corelDraw\ClickTrainLongTerm\Anesthesia";
Protocol = "Figure_Anesthesia_BaseICI_Ratio_Tone_Push";
awakePath = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-2_AC\Figures\");
ketamin_0o5_Path = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-3_AC\Figures\");
ketamin_1_Path = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-4_AC\Figures\");
ketamin_2_Path = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-5_AC\Figures\");
ketamin_4_Path = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-6_AC\Figures\");
ketamin_8_Path = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-8_AC\Figures\");
MATNAME = "cdrPlotFilter.mat";
data.Awake = load(strcat(awakePath, MATNAME));
if length(data.Awake) > 4
    data.Awake.RegRatio(5) = [];  data.Awake.RegRatioS1(5) = [];
end

data.Ket0o5 = load(strcat(ketamin_0o5_Path, MATNAME));
data.Ket1 = load(strcat(ketamin_1_Path, MATNAME));
data.Ket2 = load(strcat(ketamin_2_Path, MATNAME));
data.Ket4 = load(strcat(ketamin_4_Path, MATNAME));
data.Ket8 = load(strcat(ketamin_8_Path, MATNAME));

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
    FigWave = plotRawWaveMulti_SPR(chPlot, Window, states(sIndex), [8, 8]);
    scaleAxes(FigWave, "y", [-20, 20]);
    scaleAxes(FigWave, "x", [-100, 500]);
    addLegend2Fig(FigWave, strrep(stimStrs, "_", "-"));
    FIGPATH = strcat(rootPath, "\Anesthesia_Compare\",  dateStr,"\diffStimComparison\");
    mkdir(FIGPATH);
    print(FigWave, strcat(FIGPATH, states(sIndex)), "-djpeg", "-r200");
end
close all

%% waveform comparison
Window = data.Awake.Window;
stateColors = ["#FF0000", "#FFAA00", "#00FF00", "#0000FF", "#000000", "#888888"];
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
    addLegend2Fig(FigWave, states)
    FIGPATH = strcat(rootPath, "\Anesthesia_Compare\", dateStr, "\awake2Anesthesia\");
    mkdir(FIGPATH);
    print(FigWave, strcat(FIGPATH, stimStrs(dIndex)), "-djpeg", "-r200");
end
close all

%% waveform comparison S1
Window = data.Awake.Window;
stateColors = ["#FF0000", "#FFAA00", "#00FF00", "#0000FF", "#000000", "#888888"];
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
    FIGPATH = strcat(rootPath, "\Anesthesia_Compare\", dateStr, "\awake2Anesthesia\");
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
addLegend2Fig(FigWave, stimStrs)
FIGPATH = strcat(rootPath, "\Anesthesia_Compare\", dateStr, "\awake2Anesthesia\");
mkdir(FIGPATH);
print(FigWave, strcat(FIGPATH, "CRI_Tuning"), "-djpeg", "-r200");
close all