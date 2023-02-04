function idx = ECOGSitePatch(Area, patchType)

if strcmpi(patchType, "matchIssue")
    if strcmpi(Area, "AC") || strcmpi(Area, "LAuC")
        idx = [1:36, 52, 37:51, 53:64];
    elseif strcmpi(Area, "PFC") || strcmpi(Area, "LPFC")
        idx = [1:26, 28:36, 27, 37:64]; 
    end

elseif strcmpi(patchType, "bankIssue") %20230204, to solve artifacts in top bank
    if strcmpi(Area, "AC") || strcmpi(Area, "LAuC")
        idx = [1:36, 52, 37:51, 53:64];
    elseif strcmpi(Area, "PFC") || strcmpi(Area, "LPFC")
        idx = [1:26, 28:36, 27, 37:64];
    end
end

end