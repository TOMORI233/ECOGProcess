function idx = ECOGSitePatch(Area, patchType)
narginchk(1, 2);
if nargin < 2
    patchType = "matchIssue";
end

if strcmpi(patchType, "matchIssue")
    if strcmpi(Area, "AC") || strcmpi(Area, "LAuC")
        idx = [1:36, 52, 37:51, 53:64];
    elseif strcmpi(Area, "PFC") || strcmpi(Area, "LPFC")
        idx = [1:26, 28:36, 27, 37:64]; 
    end

elseif strcmpi(patchType, "bankIssue") %20230204, to remove artifacts in top bank, only for PFC
    if strcmpi(Area, "AC") || strcmpi(Area, "LAuC")
        idx = [1:36, 52, 37:51, 53:64];  % same as matchIssue
    elseif strcmpi(Area, "PFC") || strcmpi(Area, "LPFC")
        idx = [1:26, 28:36, 27, 37:64];  % to rewrite
        idx = idx([1:31, 49:64, 32:48]);
    end
end

end