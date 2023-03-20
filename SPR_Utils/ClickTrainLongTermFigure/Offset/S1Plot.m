%% 256/512ms click
FIGPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\Offset\Figure_Offset_256_512_10s\cc20221130_AC\Figures\";
load(strcat(FIGPATH, "cdrPlot_AC.mat"));
t = cdrPlot(13).CCWave(1).Data(:, 1);
S1Duration = [9984, 10240];
tAll = S1Duration + t;

%% 1-128 click
FIGPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\Offset\Pop_Figure1_Offseet_1_128\R_minus_S_devide_R_plus_S\CC\";
load(strcat(FIGPATH, "cdrPlot_AC.mat"));
t = cdrPlot(13).Wave(1).Data(:, 1);
S1Duration = [4014.1, 4014.1, 4004.1, 4004.1, 4001.5, 4000.2, 4032.2, 3968.2, 992];
tAll = S1Duration + t;
