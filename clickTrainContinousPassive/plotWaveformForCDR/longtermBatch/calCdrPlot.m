switch processType
    case "waveform"
        if  ismember(paradigmType, ["Others", "DiffICI_ind", "Species", "RegIrreg"])
            for ch = 1 : size(chMeanSel{pN}{stimCode, pos}, 1)
                if paradigmStr(pN) == "LowHigh4043444546" || paradigmStr(pN) == "ICIThr401234"
                    cdrPlot.(paradigmStr(pN)).(posStr(pos)).(strcat(chOrIca, num2str(ch))).(dateStr)(:, 2*(length(filterRes) - stimCode + 1) - 1) = t(tIndex);
                    cdrPlot.(paradigmStr(pN)).(posStr(pos)).(strcat(chOrIca, num2str(ch))).(dateStr)(:, 2*(length(filterRes) - stimCode + 1)) = chMeanSel{pN}{stimCode, pos}(ch , :)';
                elseif paradigmStr(pN) == "offset"
                    cdrPlot.(paradigmStr(pN)).(posStr(pos)).(strcat(chOrIca, num2str(ch))).(dateStr){1, 2 - mod(stimCode , 2)}(:, 2 * ceil(stimCode / 2) - 1) = t(tIndex);
                    cdrPlot.(paradigmStr(pN)).(posStr(pos)).(strcat(chOrIca, num2str(ch))).(dateStr){1, 2 - mod(stimCode , 2)}(:, 2* ceil(stimCode / 2)) = chMeanSel{pN}{stimCode, pos}(ch , :)';
                else
                    cdrPlot.(paradigmStr(pN)).(posStr(pos)).(strcat(chOrIca, num2str(ch))).(dateStr)(:, 2*stimCode - 1) = t(tIndex);
                    cdrPlot.(paradigmStr(pN)).(posStr(pos)).(strcat(chOrIca, num2str(ch))).(dateStr)(:, 2*stimCode) = chMeanSel{pN}{stimCode, pos}(ch , :)';
                end
            end
        elseif paradigmType == "DiffICI_merge"
            stimStr2 = ["RegOrd", "RegRev", "IrregOrd", "IrregRev"];
            for ch = 1 : size(chMeanSel{pN}{stimCode, pos}, 1)
                cdrPlot.(posStr(pos)).(strcat(chOrIca, num2str(ch))).(dateStr).(stimStr2(stimCode))(:, 2*pN - 1) = t(tIndex);
                cdrPlot.(posStr(pos)).(strcat(chOrIca, num2str(ch))).(dateStr).(stimStr2(stimCode))(:, 2*pN) = chMeanSel{pN}{stimCode, pos}(ch , :)';
            end
        end

    case "synchronization"
        if ismember(paradigmType, ["Others", "DiffICI_ind", "Species", "RegIrreg"])
            for ch = CH
                cdrPlot.(paradigmStr(pN)).(posStr(pos)).(strcat(chOrIca, num2str(ch))).(dateStr)(:, 2*stimCode - 1) = ff';
                cdrPlot.(paradigmStr(pN)).(posStr(pos)).(strcat(chOrIca, num2str(ch))).(dateStr)(:, 2*stimCode) = PP{pN}{stimCode, pos}(ch , :)';
            end
        end

    case "ampLatency"
        [sigIndex, h, p] = clickTrainContinuousSelectChannel;

        monkeyId = ["chouchou", "xiaoxiao"];
        posStr = ["LAuC", "LPFC"];
        ICIBasic = ["LongTerm4", "LongTerm8", "LongTerm20", "LongTerm40", "LongTerm80"];
        others = ["ICIThr401234", "Insert", "RegInIrreg4o32", "LowHigh4043444546", "Var3", "Tone"];

        for id = 1 : 2
            for pos = 1 : 2
                tempSel = sigIndex.(monkeyId(id)).(posStr(pos));
                for mN = 1 : length(ampMethods)
                    for stimCode = 1 : 4

                        for ICIN = 1 : length(ICIBasic)
                            cdrPlot.(monkeyId(id)).(posStr(pos)).diffICI(stimCode).ampRaw.(ampMethods(mN))(ICIN, :) = ampMean.(ampMethods(mN)).(monkeyId(id)).(posStr(pos))(stimCode).(ICIBasic(ICIN)).all(1, :);
                        end
                        cdrPlot.(monkeyId(id)).(posStr(pos)).diffICI(stimCode).ampSel.(ampMethods(mN)) = cdrPlot.(monkeyId(id)).(posStr(pos)).diffICI(stimCode).ampRaw.(ampMethods(mN))(:, tempSel);
                        cdrPlot.(monkeyId(id)).(posStr(pos)).diffICI(stimCode).ampEx.(ampMethods(mN)) = cell2mat(excludeTrials(array2VectorCell(cdrPlot.(monkeyId(id)).(posStr(pos)).diffICI(stimCode).ampRaw.(ampMethods(mN))'), 0.1))';

                    end

                    for otherN = 1 : length(others)
                        for stimCode = 1 : 4
                            cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampRaw.(ampMethods(mN))(stimCode, :) = ampMean.(ampMethods(mN)).(monkeyId(id)).(posStr(pos))(stimCode).(others(otherN)).all(1, :);
                        end
                        cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampSel.(ampMethods(mN)) = cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampRaw.(ampMethods(mN))(:, tempSel);
                        cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampEx.(ampMethods(mN)) = cell2mat(excludeTrials(array2VectorCell(cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampRaw.(ampMethods(mN))'), 0.1))';
                        if others(otherN) == "LowHigh43444546" || others(otherN) == "ICIThr401234"
                            cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampSel.(ampMethods(mN)) = flipud(cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampSel.(ampMethods(mN)));
                            cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampEx.(ampMethods(mN)) = flipud(cdrPlot.(monkeyId(id)).(posStr(pos)).(others(otherN)).ampEx.(ampMethods(mN)));
                        end
                    end
                end
            end
        end

end
