clear all; clc
monkeyId = ["chouchou", "xiaoxiao"];
posStr = ["LAuC", "LPFC"];
plotFigure = 11;
selectWin = [-200 600];
idIdx = input('Monkey ID: 1-chouchou, 2-xiaoxiao \n');
posIndex = input('recording area : 1-AC, 2-PFC \n');
rootPath = fullfile('E:\ECoG\matData', monkeyId(idIdx));
% rawResDataPath = getSubfoldPath('E:\ECoG','Res.mat','^(?!.*Merge)');

paradigmKeyword = "Tone"; %insert, RegInIrreg4o32, LowHigh43444546, ICIThr401234, Var3, offset, Tone
paradigmStr = strrep(paradigmKeyword, '[^0]', '');
% display recording tabel
matPath = getSubfoldPath(rootPath,'RawRes.mat', [paradigmKeyword(1), posStr(posIndex)]);
recordTable = cell2table([num2cell((1 : length(matPath))'), matPath], "VariableNames", {'recordingCode', 'matPath'});
fig = uifigure('Position', [500 100 800 600]);
uit = uitable(fig, 'Data', recordTable, 'Position', [0 0 800 600] , 'ColumnWidth', {200,600});
selectRecord = input('selected record ID: \n');
close(fig);

% for pN = 1
for pN = 1 : length(paradigmKeyword)
    matPath = getSubfoldPath(rootPath,'RawRes.mat', [paradigmKeyword(pN), posStr(posIndex)]);

    for recordCode = selectRecord
        load(matPath{recordCode});
        temp = strsplit(matPath{recordCode}, '\');
        dateStr = temp{5};
        for stimCode = 1 : length(RawRes)
            clearvars -except recordCode matPath selectWin selectRecord posStr posIndex stimCode paradigmKeyword paradigmStr pN RawRes rootPath cdrRes cdrPlot plotFigure dateStr plotCh
            % get data
            chMean = RawRes(stimCode).chMean;
            t = RawRes(stimCode).t;
            stimStr = RawRes(stimCode).stimStr;
            window = [0 11000] - RawRes(stimCode).S1Duration;


            tIndex = find(t > selectWin(1) & t < selectWin(2));
            tIndex = tIndex(1 : floor(length(tIndex) / 10) * 10);
            chMeanSel= chMean(:, tIndex);

            if plotFigure
                % preview result in selected window
                Fig_wave = plotRawWave(chMeanSel, [], selectWin, strcat(paradigmStr, RawRes(stimCode).stimStr));

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


            % data for corelDraw
            RawRes(stimCode).tCDR = t(tIndex);
            RawRes(stimCode).chMeanCDR = chMeanSel;

            cdrRes.(paradigmStr(pN)).(dateStr)(stimCode).tCDR = t(tIndex);
            cdrRes.(paradigmStr(pN)).(dateStr)(stimCode).chMeanCDR = chMeanSel;
            cdrRes.(paradigmStr(pN)).(dateStr)(stimCode).stimStr = RawRes(stimCode).stimStr;
            % save(matPath{recordCode}, "RawRes");

            for ch = 1 : size(chMeanSel, 1)
                if paradigmKeyword == "LowHigh43444546" || paradigmKeyword == "ICIThr401234"
                    cdrPlot.(strcat('ch', num2str(ch))){recordCode}(:, 2*(length(RawRes) - stimCode + 1) - 1) = t(tIndex);
                    cdrPlot.(strcat('ch', num2str(ch))){recordCode}(:, 2*(length(RawRes) - stimCode + 1)) = chMeanSel(ch , :)';
                elseif paradigmKeyword == "offset"
                    cdrPlot.(strcat('ch', num2str(ch))){recordCode, 2 - mod(stimCode , 2)}(:, 2 * ceil(stimCode / 2) - 1) = t(tIndex);
                    cdrPlot.(strcat('ch', num2str(ch))){recordCode, 2 - mod(stimCode , 2)}(:, 2* ceil(stimCode / 2)) = chMeanSel(ch , :)';
                else
                    cdrPlot.(strcat('ch', num2str(ch))){recordCode}(:, 2*stimCode - 1) = t(tIndex);
                    cdrPlot.(strcat('ch', num2str(ch))){recordCode}(:, 2*stimCode) = chMeanSel(ch , :)';
                end
            end
        end
    end
end
%% save
% saveas(Fig_wave, 'result.pdf');

