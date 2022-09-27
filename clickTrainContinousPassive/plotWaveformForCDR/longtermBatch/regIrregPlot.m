if  plotFigure

        mkdir(savePath)
        for posN = 1 : 2 % pfc
            %         % reg vs irreg
            Fig_RegIrreg = plotRawWave(chMeanSel{pN}{1 , posN}, [], selectWin, "Reg vs Irreg", [8, 8], (1 : 64)', "off");
            lineSetting.color = 'k';
            Fig_RegIrreg = plotRawWave2(Fig_RegIrreg, chMeanSel{pN}{3, posN}, [], selectWin, lineSetting);
            % set axes

            scaleAxes(Fig_RegIrreg,'y', [-1 * yScale(posN) yScale(posN) ]);
            setAxes(Fig_RegIrreg, 'yticklabel', '');
            setAxes(Fig_RegIrreg, 'xticklabel', '');
            setAxes(Fig_RegIrreg, 'visible', 'off');
            % reset lineWidth, lineColor
            setLine(Fig_RegIrreg, "LineWidth", 1.5, "LineStyle", "-")
            %     setLine(Fig_MultiWave, "Color", "black" , "LineStyle", "-");
            setLine(Fig_RegIrreg, "YData", [-1 * yScale(posN) yScale(posN) ], "LineStyle", "--");
            setLine(Fig_RegIrreg, "LineWidth", 1, "LineStyle", "--");
            % reset figure size

            set(Fig_RegIrreg, "outerposition", [300, 100, 800, 670]);

            % plot layout
            if contains(matPath{recordCode}, 'cc')
                plotLayout(Fig_RegIrreg, posN, 0.3);
            else

                plotLayout(Fig_RegIrreg, posN + 2, 0.3);
            end

            % save
            mkdir(savePath)
            print(Fig_RegIrreg, fullfile(savePath, strcat("4ms_", posStr(posN), "S_", num2str(s1OnsetOrS2Onset))), "-djpeg", "-r300");
            close all


        end
end