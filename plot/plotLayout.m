function Fig = plotLayout(Fig, posIndex)
layAx = mSubplot(Fig, 1, 1, 1, [1 1], zeros(4,1));
addpath(genpath(mfilename("fullpath"))) 
load('layout.mat');
switch posIndex
    case 1 %AC
        image(layAx,AC_sulcus); hold on
    case 2 %PFC
        image(layAx,PFC_sulcus); hold on
end
set(layAx,'XTickLabel',[]);
set(layAx,'YTickLabel',[]);
set(layAx,'Box','off');
set(layAx,'visible','off');
allAxes = findobj(Fig, "Type", "axes");
set(Fig,'child',[allAxes ; layAx]);
end