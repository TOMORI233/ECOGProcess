clear; close all; clc
colors = ["#FF0000", "#FFA500", "#0000FF", "#000000"];
sigmas = 4./[400, 200, 100, 50];
u = 4;
ROOTPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\";
FIGPATH = strcat(ROOTPATH, "\Protocol Figure\Vars\");
Fig = figure;
maximizeFig(Fig);
for varN = 1 : length(sigmas)
    sigma = sigmas(varN);
    x = (0.9 * u : 0.0001 : 1.1 * u)';
    y{varN} = ((1 / (sqrt(2*pi) * sigma)) * exp(-((x-u).^2)/(2*sigma.^2)));
    plot(x, y{varN}, "Color", colors(varN), "LineWidth", 6); hold on
end
setAxes(Fig, "visible", "off");
lines(1).X = 4; lines(1).color = "#AAAAAA"; 
lines(1).lineStyle = "--"; lines(1).lineWidth = 5;
addLines2Axes(Fig, lines);
toPlot = [x, y{4}, x, y{3}, x, y{2}, x, y{1}];
mkdir(FIGPATH);
print(Fig, strcat(FIGPATH,  "Irreg Var"), "-djpeg", "-r200");
close(Fig);