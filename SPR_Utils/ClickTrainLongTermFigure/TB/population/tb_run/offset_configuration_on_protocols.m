run("offset_general_settings.m");
if matches(Protocol, "Offset_2_128_4s_New")
    icaOpt = "off";
    plotWhole = false;
    fs = 600;
    badCH_self = {[], [46,48]};
    correspFreq = 1000./[1, 2, 4, 8, 16, 32, 64, 128, 8];
    baseWin = [-1500, 0];
    FIGPATH = strcat(ROOTPATH, "Pop_Figure1_Offset_1_128_New\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");

elseif matches(Protocol, "Offset_2_128_4s")
    icaOpt = "off";
    plotWhole = false;
    fs = 600;
    badCH_self = {[17, 39, 49, 50, 57], [2, 48,49,57,64]};
    correspFreq = 1000./[1, 2, 4, 8, 16, 32, 64, 128, 8, 1, 1];
    baseWin = [-1500, 0];
    FIGPATH = strcat(ROOTPATH, "Pop_Figure1_Offset_1_128\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");
elseif matches(Protocol, ["Offset_Duration_Effect_4ms_Reg_New", "Offset_Duration_Effect_8ms_Reg_New", "Offset_Variance_Effect_4ms_8ms_sigma250_2_Reg_500ms"])
    quantWin = [50 200];
    sponWin = [-100 0];
    icaOpt = "off";
    plotWhole = false;
    fs = 600;
    badCH_self = {[40], [2, 48,49,57,64]};
    OffsetParams.fs = fs;
    correspFreq = 1000./ICI2;
    baseWin = [-1500, 0];
    if matches(Protocol, "Offset_Duration_Effect_4ms_Reg_New")
        FIGPATH = strcat(ROOTPATH, "Pop_Figure2_Offset_Duration_4ms\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");
    elseif matches(Protocol, "Offset_Duration_Effect_8ms_Reg_New")
        FIGPATH = strcat(ROOTPATH, "Pop_SFigure2_Offset_Duration_8ms\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");
    elseif matches(Protocol, "Offset_Variance_Effect_4ms_8ms_sigma250_2_Reg_500ms")
        FIGPATH = strcat(ROOTPATH, "Pop_Figure3_Offset_Variance\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");
    end

end
