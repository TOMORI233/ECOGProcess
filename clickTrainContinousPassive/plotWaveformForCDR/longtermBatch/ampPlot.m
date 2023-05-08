
%% population data
temp = cdrPlot.chouchou.LAuC;
opts.protocol = string(fields(temp));
opts.ampType = ["ampRMS", "ampAREA", "ampPeak", "ampTrough"];
opts.savePath = strcat(figSavePath, "amp");

for pN = 1 : length(opts.protocol) % protocol
    cdrPlot_amp.(opts.protocol(pN)) = plotPopAmpFigure(cdrPlot, opts, pN);
end





function cdrPlot_amp = plotPopAmpFigure(cdrPlot, opts, pN)
run("ampStrConfig.m");
optsNames = fieldnames(opts);
mkdir(opts.savePath);
for index = 1:size(optsNames, 1)
    eval([optsNames{index}, '=opts.', optsNames{index}, ';']);
end
curProt = protocol(pN);


Fig = figure;
margins = [0.05, 0.05, 0.1, 0.1];
paddings = [0.01, 0.03, 0.01, 0.01];
maximizeFig(Fig);
plotSize = [length(monkeyId), length(ampType)];
for id = 1 : length(monkeyId)
    for typeN = 1 : length(ampType)
        mSubplot(Fig, plotSize(1), plotSize(2), (id - 1) * plotSize(2) + typeN, [1, 1], margins, paddings);
        if curProt == "Insert"
            tempInsert = cdrPlot.(monkeyId(id)).LAuC.(curProt)(1).ampSel.(ampType(typeN))(1, :);
            tempReg = cdrPlot.(monkeyId(id)).LAuC.diffICI(1).ampSel.(ampType(typeN))(1, :);
            tempIrreg = cdrPlot.(monkeyId(id)).LAuC.diffICI(2).ampSel.(ampType(typeN))(1, :);
            temp = [tempReg; tempInsert; tempIrreg];
            h1 = plot(1 : size(temp, 1), temp', "r-", "DisplayName", "AC"); hold on;
            cdrPlot_amp.(monkeyId(id)).(ampType(typeN)).LAuC = temp;
            
            tempInsert = cdrPlot.(monkeyId(id)).LPFC.(curProt)(1).ampRaw.(ampType(typeN))(1, :);
            tempReg = cdrPlot.(monkeyId(id)).LPFC.diffICI(1).ampRaw.(ampType(typeN))(1, :);
            tempIrreg = cdrPlot.(monkeyId(id)).LPFC.diffICI(2).ampRaw.(ampType(typeN))(1, :);
            temp = [tempReg; tempInsert; tempIrreg];            
            h3 = plot(1 : size(temp, 1), temp', "b-", "DisplayName", "PFC"); hold on;
            cdrPlot_amp.(monkeyId(id)).(ampType(typeN)).LPFC = temp;
        else
            temp = cdrPlot.(monkeyId(id)).LAuC.(curProt)(1).ampSel.(ampType(typeN));
            h1 = plot(1 : size(temp, 1), temp', "r-", "DisplayName", "AC"); hold on;
            cdrPlot_amp.(monkeyId(id)).(ampType(typeN)).LAuC = temp;

            temp = cdrPlot.(monkeyId(id)).LPFC.(curProt)(1).ampEx.(ampType(typeN));
            h3 = plot(1 : size(temp, 1), temp', "b-", "DisplayName", "PFC"); hold on;
            cdrPlot_amp.(monkeyId(id)).(ampType(typeN)).LPFC = temp;
        end

        set(gca, "xtick", 1 : 5);
        set(gca, "xticklabel", xticklabel.(curProt));
        title(strjoin([monkeyId(id), curProt, ampType(typeN)], " "));
        legend([h1(1), h3(1)], ["AC", "PFC"]);
    end
end

% print(Fig, fullfile(savePath, curProt), "-djpeg", "-r300");
close(Fig);
end


