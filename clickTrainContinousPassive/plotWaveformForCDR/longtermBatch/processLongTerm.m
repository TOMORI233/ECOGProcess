function cdrPlot = processLongTerm(opts)
%% get opts params
optsNames = fieldnames(opts);
for index = 1:size(optsNames, 1)
    eval([optsNames{index}, '=opts.', optsNames{index}, ';']);
end

run("decideParadigm.m");

if dataType == "ica"
    load(fullfile(matSavePath, "mergeICAComp4ms.mat"));
    chOrIca = "ica";
elseif dataType == "raw"
    chOrIca = "ch";
end

switch processType
    case "waveform"
        if ismember(paradigmType, ["RegIrreg", "Others", "DiffICI_ind", "Species"])
            run("othersProcess.m");
        elseif paradigmType == "DiffICI_merge"
            run("diffICI_mergeProcess.m");
        end
    case "ampLatency"
        run("ampLatencyProcess.m");
    
    case "synchronization"
        if ismember(paradigmType, ["RegIrreg", "Others", "DiffICI_ind", "Species"])
            run("syncProcess.m");
        end
end




