function mCompareCorrCh(objectHandle, event, Fig)
info = get(Fig, "UserData");
lastClick = getOr(info, "lastClick");

if event.Button == 1
    if ~isempty(lastClick) && (now - lastClick) * 24 * 3600 <= 0.5
        axesHandle  = get(objectHandle, "Parent");
        UserData = get(Fig, "UserData");
        trialsECOGSel = UserData.trialsECOGSel;
        devSel = getOr(UserData, "devSel", 0);
        stimDlg = UserData.params.stimDlg;
        trialType = unique(UserData.trialType);

        %% parse selected channel
        coordinates = get(axesHandle, "CurrentPoint");
        coordinates = round(coordinates(1,1:2));
        xChannel = cellfun(@str2num, get(axesHandle,"XTickLabel"));
        yChannel = cellfun(@str2num, get(axesHandle,"YTickLabel"));
        rowCh = xChannel(coordinates(1));
        colCh = yChannel(coordinates(2));

        %% process data
        if devSel == 0
            selectStr = "trialType: all trials";
        else
            if length(unique(trialType)) ~= length(stimDlg)
                selectStr = strcat("trialType: ", strjoin(string(devSel), ", "));
            else
                selectStr = strcat("trialType: ", strjoin(stimDlg(devSel), ", "));
            end
        end

        if isequal(rowCh, colCh)
            trialsSel = cellfun(@(x) x(rowCh, :), trialsECOGSel, "UniformOutput", false);
            titleStr = strcat(selectStr, ", CH", num2str(rowCh));
        else
            trialsSel = cellfun(@(x) x([rowCh, colCh], :), trialsECOGSel, "UniformOutput", false);
            titleStr(1) = strcat(selectStr, ", CH", num2str(rowCh));
            titleStr(2) = strcat(selectStr, ", CH", num2str(colCh));
        end

        trialMean = cell2mat(cellfun(@mean , changeCellRowNum(trialsSel), 'UniformOutput', false));
        trialStd = cell2mat(cellfun(@(x) std(x)/sqrt(length(trialsECOGSel)), changeCellRowNum(trialsSel), 'UniformOutput', false));


        %% plot
        FigPlot = plotRawWave(trialMean, trialStd, UserData.Window, [], autoPlotSize(size(trialsSel{1}, 1)));
        XLim = getOr(UserData, "XLim", UserData.Window);
        UserData.XLim = XLim;
        scaleAxes(FigPlot, "x", XLim);
        YLim = getOr(UserData, "YLim", scaleAxes(FigPlot));
        scaleAxes(FigPlot, "y", YLim);
        UserData.YLim = YLim;
        setTitle(FigPlot, titleStr);
        Fig.UserData = UserData;
    else
        lastClick = now;
    end
end

info.lastClick = lastClick;
set(Fig, "UserData", info);

end


