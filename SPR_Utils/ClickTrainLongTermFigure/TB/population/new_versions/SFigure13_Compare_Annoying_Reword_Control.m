dateStr = ["cc20230504", "xx20230504", "cc20230505"];
% for mIndex = 1 : length(monkeyName)
for mIndex = 1:length(dateStr)
    clearvars -except dateStr mIndex
    % annoying
    dataPath = strcat("E:\ECoG\corelDraw\ClickTrainLongTerm\Basic\Ex_Sfigure13_Add_on_Annoying_BaseICI_12-16\", dateStr(mIndex), "\cdrPlot_AC.mat");
    annoyData = load(dataPath);

    % reword
    dataPath = strcat("E:\ECoG\corelDraw\ClickTrainLongTerm\Basic\Ex_Sfigure14_Add_on_Reword_BaseICI_12-16\", dateStr(mIndex), "\cdrPlot_AC.mat");
    rewordData = load(dataPath);

    % control
    dataPath = strcat("E:\ECoG\corelDraw\ClickTrainLongTerm\Basic\Ex_Sfigure15_Add_on_Control_BaseICI_12-16\", dateStr(mIndex), "\cdrPlot_AC.mat");
    controlData = load(dataPath);

    Window = [-3500 1500];
    % 12ms
    compare(1).chMean = annoyData.chMean{1}; compare(1).color = "#0000FF";
    compare(2).chMean = rewordData.chMean{1}; compare(2).color = "#FF0000";
    compare(3).chMean = controlData.chMean{1}; compare(3).color = "#000000";
    FigWave_12 = plotRawWaveMulti_SPR(compare, Window, "12ms", [8, 8]);
    addLegend2Fig(FigWave_12, ["12ms-annoying", "12ms-reword", "12ms-control"]);
    % 16ms
    compare = [];
    compare(1).chMean = annoyData.chMean{2}; compare(1).color = "#0000FF";
    compare(2).chMean = rewordData.chMean{2}; compare(2).color = "#FF0000";
    compare(3).chMean = controlData.chMean{2}; compare(3).color = "#000000";
    FigWave_16 = plotRawWaveMulti_SPR(compare, Window, "12ms", [8, 8]);
    addLegend2Fig(FigWave_16, ["16ms-annoying", "16ms-reword", "16ms-control"]);

    % scaling
    scaleAxes([FigWave_12, FigWave_16], "y", [-15,15]);
    setAxes([FigWave_12, FigWave_16], 'yticklabel', '');
    setAxes([FigWave_12, FigWave_16], 'xticklabel', '');
    setAxes([FigWave_12, FigWave_16], 'visible', 'off');
    setLine([FigWave_12, FigWave_16], "YData", [-20 20], "LineStyle", "--");
    scaleAxes([FigWave_12, FigWave_16], "x", [0, 300]);
    
    

    FIGPATH = strcat("E:\ECoG\corelDraw\ClickTrainLongTerm\Basic\Ex_Sfigure16_Compare_Annoying_Reword_Control_BaseICI_12_16\", dateStr(mIndex));
    mkdir(FIGPATH);
    print(FigWave_12, strcat(FIGPATH, "\12ms_Wave_Compare"), "-djpeg", "-r200");
    print(FigWave_16, strcat(FIGPATH, "\16ms_Wave_Compare"), "-djpeg", "-r200");
close all;
end