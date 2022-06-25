
clear all; clc
monkeyId = ["chouchou", "xiaoxiao"];
posStr = ["LAuC", "LPFC"];
plotFigure = 1;
idIdx = 2;
posIndex = 2;
rootPath = fullfile('E:\ECoG\matData', monkeyId(idIdx));
% rawResDataPath = getSubfoldPath('E:\ECoG','Res.mat','^(?!.*Merge)');

basicRegIrreg = ["LongTerm4[^0]", "LongTerm8[^0]", "LongTerm20", "LongTerm40", "LongTerm80"];
basicStr = strrep(basicRegIrreg, '[^0]', '');
% % display recording tabel
% recordTable = cell2table([num2cell((1 : length(matPath))'), matPath], "VariableNames", {'recordingCode', 'matPath'});
% fig = uifigure('Position', [500 300 800 600]);
% uit = uitable(fig, 'Data', recordTable, 'Position', [0 0 800 600] , 'ColumnWidth', {200,600});

selectRecord = input('selected record ID:');

% close(fig);
for pN = 1 
% for pN = 1 : length(basicRegIrreg)
    matPath = getSubfoldPath(rootPath,'RawRes.mat', [basicRegIrreg(pN), posStr(posIndex)]);

    for recordCode = selectRecord

        load(matPath{recordCode});

        for stimCode = 1 : length(RawRes)
            clearvars -except recordCode matPath selectRecord posStr posIndex stimCode basicRegIrreg basicStr pN RawRes rootPath cdrRes plotFigure
            % get data
            chMean = RawRes(stimCode).chMean;
            t = RawRes(stimCode).t;
            stimStr = RawRes(stimCode).stimStr;
            window = [0 11000] - RawRes(stimCode).S1Duration;
            selectWin = [-200 500];


            tIndex = t > selectWin(1) & t < selectWin(2);
            chMeanSel= chMean(:, tIndex);



            if plotFigure
                % preview result in selected window
                Fig_wave = plotRawWave(chMeanSel, [], selectWin, strcat(basicStr(pN) , "ms " , RawRes(stimCode).stimStr));

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
                    if contains(matPath{recordCode}, {'20220622', '20220623'})
                        plotLayout(Fig_wave, 5 - posIndex);
                    else
                        plotLayout(Fig_wave, posIndex + 2);
                    end
                end
            end


            % data for corelDraw
            RawRes(stimCode).tCDR = tIndex;
            RawRes(stimCode).chMeanCDR = chMeanSel;

            cdrRes.(basicStr(pN))(stimCode).tCDR = tIndex;
            cdrRes.(basicStr(pN))(stimCode).chMeanCDR = chMeanSel;
            cdrRes.(basicStr(pN))(stimCode).stimStr = RawRes(stimCode).stimStr;
            %             save(matPath{recordCode}, "RawRes");

        end
    end
end
%% save
% saveas(Fig_wave, 'result.pdf');

