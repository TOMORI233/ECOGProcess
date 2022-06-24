
clear all; clc
monkeyId = ["chouchou", "xiaoxiao"];
posStr = ["LAuC", "LPFC"];

idIdx = 1;
posIndex = 2;

rootPath = fullfile('E:\ECoG\matData', monkeyId(idIdx));
matPath = getSubfoldPath(rootPath,'RawRes.mat', {"LongTerm4[^0]", posStr(posIndex)});

% display recording tabel
recordTable = cell2table([num2cell((1 : length(matPath))'), matPath], "VariableNames", {'recordingCode', 'matPath'});
fig = uifigure('Position', [500 300 800 600]);
uit = uitable(fig, 'Data', recordTable, 'Position', [0 0 800 600] , 'ColumnWidth', {200,600});

selectRecord = input('selected record ID:');
close(fig);
for recordCode = selectRecord
    
    clearvars -except recordCode matPath posStr posIndex
    stimCode = 1;
    load(matPath{recordCode});

    % get data
    chMean = RawRes(stimCode).chMean;
    t = RawRes(stimCode).t;
    stimStr = RawRes(stimCode).stimStr;
    window = [0 11000] - RawRes(stimCode).S1Duration;
    selectWin = [-200 500];

    % preview selected window
    tIndex = t > selectWin(1) & t < selectWin(2);
    chMeanSel= chMean(:, tIndex);
    Fig_wave = plotRawWave(chMeanSel, [], selectWin);

    % get all axes
    allAxes = findobj(Fig_wave, "Type", "axes");

    % set axes
    scaleAxes(Fig_wave,'y', [-80 80]);
    setAxes(Fig_wave, 'yticklabel', '');
    setAxes(Fig_wave, 'xticklabel', '');

    % reset lineWidth
    for axesN = 1 : length(allAxes)
        allAxes(axesN).Children(2).LineWidth = 3;
    end

    % reset figure size
    Fig_wave.Position = [300, 100, 800, 670];

    % plot layout
    if contains(matPath{recordCode}, 'cc')
        plotLayout(Fig_wave, posIndex);
    else
        plotLayout(Fig_wave, posIndex + 2);
    end

end
%% save
% saveas(Fig_wave, 'result.pdf');

