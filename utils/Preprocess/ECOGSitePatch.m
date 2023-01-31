function idx = ECOGSitePatch(Area)
    if strcmpi(Area, "AC")
        idx = [1:36, 52, 37:51, 53:64];
    elseif strcmpi(Area, "PFC")
        idx = [1:26, 28:36, 27, 37:64];
    end
end