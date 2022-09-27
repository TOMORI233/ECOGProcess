if  plotFigure
    if ~exist(savePath, 'dir')
        regIrreg = ["RegOrd", "RegRev", "IrregOrd", "IrregRev"];
        for posN = 1 : 2


            for stimPlot = 1:4


                Fig_MultiWave = plotRawWave(chMeanSel{1}{stimPlot , posN}, [], selectWin, "diffICI", [8, 8], (1 : 64)', "off");
                lineSetting.color = "#AAAAAA";
                Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{5}{stimPlot, posN}, [], selectWin, lineSetting);
                lineSetting.color = "#000000";
                Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{4}{stimPlot, posN}, [], selectWin, lineSetting);
                lineSetting.color = "#0000FF";
                Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{3}{stimPlot, posN}, [], selectWin, lineSetting);
                lineSetting.color = "#FFA500";
                Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{2}{stimPlot, posN}, [], selectWin, lineSetting);
                lineSetting.color = "#FF0000";
                Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{1}{stimPlot, posN}, [], selectWin, lineSetting);

                % set axes

                scaleAxes(Fig_MultiWave,'y', [-1 * yScale(posN) yScale(posN) ]);
                setAxes(Fig_MultiWave, 'yticklabel', '');
                setAxes(Fig_MultiWave, 'xticklabel', '');
                setAxes(Fig_MultiWave, 'visible', 'off');
                % reset lineWidth, lineColor
                setLine(Fig_MultiWave, "LineWidth", 1.5, "LineStyle", "-")
                %     setLine(Fig_MultiWave, "Color", "black" , "LineStyle", "-");
                setLine(Fig_MultiWave, "YData", [-1 * yScale(posN) yScale(posN) ], "LineStyle", "--");
                setLine(Fig_MultiWave, "LineWidth", 1, "LineStyle", "--");
                % reset figure size

                set(Fig_MultiWave, "outerposition", [300, 100, 800, 670]);

                % plot layout
                if contains(matPath{recordCode}, 'cc')
                    plotLayout(Fig_MultiWave, posN, 0.3);
                else

                    plotLayout(Fig_MultiWave, posN + 2, 0.3);
                end

                % save
                mkdir(savePath)
                print(Fig_MultiWave, fullfile(savePath,strcat(regIrreg(stimPlot) ,posStr(posN))), "-djpeg", "-r300");
                close all

            end


        end
    end
end