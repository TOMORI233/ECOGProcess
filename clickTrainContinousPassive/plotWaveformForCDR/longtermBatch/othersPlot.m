            if  plotFigure
                if ~exist(savePath, 'dir')
                    mkdir(savePath)
                    % 4,8,20,40,80
                    for posN = 1 : 2 % pfc

                        if paradigmKeyword(pN) == "LowHigh4043444546" || paradigmKeyword(pN) == "ICIThr401234"
                            Fig_MultiWave = plotRawWave(chMeanSel{pN}{1 , posN}, [], selectWin, paradigmKeyword(pN), [8, 8], (1 : 64)', "off");
                            lineSetting.color = "#000000";
                            Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{1, posN}, [], selectWin, lineSetting);
                            lineSetting.color = "#0000FF";
                            Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{2, posN}, [], selectWin, lineSetting);
                            lineSetting.color = "#FFA500";
                            Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{3, posN}, [], selectWin, lineSetting);
                            lineSetting.color = "#FF0000";
                            Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{4, posN}, [], selectWin, lineSetting);
                        else
                            Fig_MultiWave = plotRawWave(chMeanSel{pN}{1 , posN}, [], selectWin, paradigmKeyword(pN), [8, 8], (1 : 64)', "off");
                            lineSetting.color = "#000000";
                            Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{4, posN}, [], selectWin, lineSetting);
                            lineSetting.color = "#0000FF";
                            Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{3, posN}, [], selectWin, lineSetting);
                            lineSetting.color = "#FFA500";
                            Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{2, posN}, [], selectWin, lineSetting);
                            lineSetting.color = "#FF0000";
                            Fig_MultiWave = plotRawWave2(Fig_MultiWave, chMeanSel{pN}{1, posN}, [], selectWin, lineSetting);
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