clc; clear; close all
%% load path
dateStr = "cc20230714";
% dateStr = "xx20230712";
rootPath = "E:\ECOG\corelDraw\ClickTrainLongTerm\Anesthesia";
Protocol = "Figure_Anesthesia_BaseICI_Ratio_Tone_Push_Spon";
awakePath = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-2_AC\Figures\");
ketamin_0o5_Path = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-3_AC\Figures\");
ketamin_1_Path = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-4_AC\Figures\");
ketamin_2_Path = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-5_AC\Figures\");
ketamin_4_Path = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-6_AC\Figures\");
ketamin_8_Path = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-7_AC\Figures\");
MATNAME = "cdrPlot.mat";
data.Awake = load(strcat(awakePath, MATNAME));
data.Ket0o5 = load(strcat(ketamin_0o5_Path, MATNAME));
data.Ket1 = load(strcat(ketamin_1_Path, MATNAME));
data.Ket2 = load(strcat(ketamin_2_Path, MATNAME));
data.Ket4 = load(strcat(ketamin_4_Path, MATNAME));
data.Ket8 = load(strcat(ketamin_8_Path, MATNAME));



%% 同一刺激不同深度
states = string(fields(data));
for CH = 1 : 64
    for sIndex = 1 : length(states)
        ff = data.(states(sIndex)).ff;
        toPlot(CH).diffDepth(:, 2*sIndex - 1) = ff';
        toPlot(CH).diffDepth(:, 2*sIndex) = data.(states(sIndex)).PMean(CH, :)';
    end
end



%% diff stim under same level
Window = data.Awake.Window;
ff = data.Awake.ff;
states = fields(data);
color = cellstr(["#FF0000", "#FFAA00", "#00FF00", "#0000FF", "#000000", "#888888"]');
statesData = struct2cell(structfun(@(x) x.PMean, data, "UniformOutput", false));
chPlot = cell2struct([statesData, color], ["chMean", "color"], 2);

FigWave = plotRawWaveMulti_SPR(chPlot, [ff(1), ff(end)], "diff anesthesia", [8, 8]);
scaleAxes(FigWave, "x", [0, 100]);
scaleAxes(FigWave, "y", [0, 5]);
addLegend2Fig(FigWave, strrep(states, "_", "-"));
FIGPATH = strcat(rootPath, "\Anesthesia_Compare\",  dateStr);
mkdir(FIGPATH);
print(FigWave, strcat(FIGPATH, "\diffStateSponComparison"), "-djpeg", "-r200");
