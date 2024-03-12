function Exported = exportDataFcn(BLOCKPATHs, SAVEPATHs, params, Exported, skipIdx)
    fd = params.fd;
    fhp = params.fhp;
    flp = params.flp;

    patchOpt = getOr(params, "patch", "bankIssue");

    Exported(skipIdx) = true;
    idxAll = find(~Exported);

    AREANAMEs = ["AC", "PFC"];

    for index = 1:length(idxAll)

        try
            temp = string(split(BLOCKPATHs{idxAll(index)}, '\'));
            DateStr = temp(end - 1);
            mkdir(fullfile(SAVEPATHs{idxAll(index)}, DateStr));
            
            % AC
            disp("Loading AC Data...");
            params.posIndex = 1;
            tic
            [trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATHs{idxAll(index)}, params, "patch", patchOpt);
            ECOGDataset = ECOGResample(ECOGDataset, fd);
            ECOGDataset = ECOGFilter(ECOGDataset, fhp, flp, "Notch", "on");
            disp("Saving...");
            save(strcat(SAVEPATHs{idxAll(index)}, DateStr, "\", DateStr, "_", AREANAMEs(params.posIndex), ".mat"), "ECOGDataset", "trialAll", "-mat", "-v7.3");
            toc
            
            % PFC
            disp("Loading PFC Data...");
            params.posIndex = 2;
            tic
            [~, ECOGDataset] = ECOGPreprocess(BLOCKPATHs{idxAll(index)}, params, "patch", patchOpt);
            ECOGDataset = ECOGResample(ECOGDataset, fd);
            ECOGDataset = ECOGFilter(ECOGDataset, fhp, flp, "Notch", "on");
            disp("Saving...");
            save(strcat(SAVEPATHs{idxAll(index)}, DateStr, "\", DateStr, "_", AREANAMEs(params.posIndex), ".mat"), "ECOGDataset", "trialAll", "-mat", "-v7.3");
            toc
    
            Exported(idxAll(index)) = true;
        end

    end

    return;
end