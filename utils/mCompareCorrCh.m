function mCompareCorrCh(objectHandle, event, Fig)
if event.Button == 1
    axesHandle  = get(objectHandle, "Parent");
    UserData = get(Fig, "UserData");
    trialsECOG = UserData.trialsECOG;
    trialAll = UserData.params.trialAll;
    if ~isequal(length(trialAll), length(trialsECOG))
        error("trialAll and trialsECOG do not match!");
    end
    %% select devType
    devSel = getOr(UserData, "devSel", 0);

    if isfield(trialAll, "devOrdr")
        trialType = [trialAll.devOrdr];
    end
    if ~isequal(devSel, 0)
        tIndex = find(ismember(trialType, devSel))';
    else
        tIndex = 1 : length(trialAll);
    end

    %% parse selected channel
    coordinates = get(axesHandle, "CurrentPoint");
    coordinates = round(coordinates(1,1:2));
    xChannel = cellfun(@str2num, get(axesHandle,"XTickLabel"));
    yChannel = cellfun(@str2num, get(axesHandle,"YTickLabel"));
    rowCh = xChannel(coordinates(1));
    colCh = yChannel(coordinates(2));



    %% process data
    trialsECOG = trialsECOG(tIndex);

    if isequal(rowCh, colCh)
        trialsSel = cellfun(@(x) x(rowCh, :), trialsECOG, "UniformOutput", false);
        titleStr = strcat("trialType: ", strjoin(string(devSel), ", "), ", CH", num2str(rowCh));
    else
        trialsSel = cellfun(@(x) x([rowCh, colCh], :), trialsECOG, "UniformOutput", false);
        titleStr(1) = strcat("trialType: ", strjoin(string(devSel), " , "), ", CH", num2str(rowCh));
        titleStr(2) = strcat("trialType: ", strjoin(string(devSel), " , "), ", CH", num2str(colCh));
    end

    trialMean = cell2mat(cellfun(@mean , changeCellRowNum(trialsSel), 'UniformOutput', false));
    trialStd = cell2mat(cellfun(@(x) std(x)/sqrt(length(trialsECOG)), changeCellRowNum(trialsSel), 'UniformOutput', false));


    %% plot
    FigPlot = plotRawWave(trialMean, trialStd, UserData.Window, [], autoPlotSize(size(trialsSel{1}, 1)));
    titleStr = strrep(titleStr, "trialType: 0", "trialType: all trials");
    setTitle(FigPlot, titleStr);
end
end

