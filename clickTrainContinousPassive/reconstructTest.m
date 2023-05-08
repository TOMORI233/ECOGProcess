topo = comp.topo;
topo(:, ~ismember(1:size(topo,2),6)) = 0;

restruct = topo * (ICARes(1).chMean);

fig = plotRawWave(restruct,[],[0 11000]);
setAxes(fig,'xlim',[4000 6000]);