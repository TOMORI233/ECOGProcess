if ismember(processType, ["waveform", "synchronization"])
switch paradigmType
    case "RegIrreg"
        paradigmKeyword = ["LongTerm4[^0]", "NormSqrtLongTerm4[^0]", "NormLongTerm4[^0]", "LongTermNew4[^0]"];      
    case "Species"
        paradigmKeyword = ["ratioDetectCommon", "ratioDetectSmall", "ratioDetectLarge", "ICIBind"];
    case "Others"
        paradigmKeyword = ["ICIThr401234", "Insert", "RegInIrreg4o32", "LowHigh43444546", "Var3", "Tone"]; %Insert, RegInIrreg4o32, LowHigh43444546, ICIThr401234, Var3, offset, Tone
    case "DiffICI_ind"
        paradigmKeyword = ["LongTerm4[^0]", "LongTerm8[^0]", "LongTerm20", "LongTerm40", "LongTerm80"];
    case "DiffICI_merge"
        paradigmKeyword = ["LongTerm4[^0]", "LongTerm8[^0]", "LongTerm20", "LongTerm40", "LongTerm80"];
    otherwise 
        error("illegal paradigmType !");
end 
elseif processType == "ampLatency"
    paradigmKeyword = ["LongTerm4[^0]", "LongTerm8[^0]", "LongTerm20", "LongTerm40", "LongTerm80", "ICIThr401234", "Insert", "RegInIrreg4o32", "LowHigh4043444546", "Var3", "Tone"];
end
paradigmStr = strrep(paradigmKeyword, '[^0]', '');