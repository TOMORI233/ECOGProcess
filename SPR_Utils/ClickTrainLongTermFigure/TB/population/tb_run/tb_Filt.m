if exist("trialsECOG_Merge_Backup", "var")
    trialsECOG_Merge = trialsECOG_Merge_Backup;
end

if exist("trialsECOG_S1_Merge_Backup", "var")
    trialsECOG_S1_Merge = trialsECOG_S1_Merge_Backup;
end
if filtFlag
    trialsECOG_Merge_Backup = trialsECOG_Merge;
    trialsECOG_Merge = ECOGFilter(trialsECOG_Merge_Backup, fhp, flp, fs);

    trialsECOG_S1_Merge_Backup = trialsECOG_S1_Merge;
    trialsECOG_S1_Merge = ECOGFilter(trialsECOG_S1_Merge_Backup, fhp, flp, fs);
end