if  plotFigure
    if ~exist(savePath, 'dir')
        mkdir(savePath)
        for posN = 1 : 2 % 1:ac, 2:pfc
            stimType = size(chMeanSel{pN}, 1);
            switch stimType
                case 5
                    colors = ["#FF0000", "#FFA500", "#0000FF", "#000000", "#AAAAAA"];
                case 6
                    colors = ["#FF0000", "#B03060", "#FFA500", "#0000FF", "#000000", "#AAAAAA"];
            end

            if paradigmKeyword(pN) == "ICIBind"
                % min order colored red
                for stimN = 1 : stimType
                    if stimN == 1
                        Fig_MultiWave = plotRawWave(chMeanSel{pN}{stimN , posN}, [], selectWin, paradigmKeyword(pN), [8, 8], (1 : 64)', "on");
                    else
                        lineSetting.color = colors(stimN);
                        Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{stimN, posN}, [], selectWin, lineSetting);
                    end
                end

            else
                % max order colored red
                for stimN = 1 : stimType
                    if stimN == 1
                        Fig_MultiWave = plotRawWave(chMeanSel{pN}{stimType - stimN + 1 , posN}, [], selectWin, paradigmKeyword(pN), [8, 8], (1 : 64)', "on");
                    else
                        lineSetting.color = colors(stimN);
                        Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{stimType - stimN + 1, posN}, [], selectWin, lineSetting);
                    end
                end

            end
            % get all axes
            allAxes2 = findobj(Fig_MultiWave, "Type", "axes");

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
            %% save
            print(Fig_MultiWave, fullfile(savePath,  posStr(posN)), "-djpeg", "-r300");
            close all

        end
    end
end