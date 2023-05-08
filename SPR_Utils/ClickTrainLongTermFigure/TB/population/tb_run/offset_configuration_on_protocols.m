run("offset_general_settings.m");
if matches(Protocol, "Offset_2_128_4s_New")
    icaOpt = "off";
    plotWhole = false;
    fs = 600;
    correspFreq = 1000./[1, 2, 4, 8, 16, 32, 64, 128, 8];
    baseWin = [-1500, 0];
    FIGPATH = strcat(ROOTPATH, "Pop_Figure1_Offseet_1_128_New\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");
elseif matches(Protocol, "Offset_2_128_4s")
    icaOpt = "off";
    plotWhole = false;
    fs = 600;
    badCH_self = {[17, 39, 49, 50, 57], [2, 48,49,57,64]};
    correspFreq = 1000./[1, 2, 4, 8, 16, 32, 64, 128, 8, 1, 1];
    baseWin = [-1500, 0];
    FIGPATH = strcat(ROOTPATH, "Pop_Figure1_Offseet_1_128\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");


end
