run("tb_general_settings.m");
if strcmpi(Protocol, "Basic_ICIThr")
    icaOpt = "off";
    plotWhole = false;
    colors = ["#000000", "#FFA500", "#0000FF", "#FF0000"];
    stimStrs = ["4_4o01", "4_4o03", "4_4o02", "4_4o04"];
    cdrPlotIdx = [4,2,3,1];

    CR_Ref = 4; %4-4.04
    fs = 500;
    yScale = [50, 50];
    CRIScale = {[0.8, 2; -0.1 0.7], [0.8, 2; -0.1 0.3]};
    FIGPATH = strcat(ROOTPATH, "Pop_Figure4_ICIThr\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");
elseif strcmpi(Protocol, "Basic_IrregVar")
    icaOpt = "off";
    plotWhole = false;
    colors = ["#FF0000", "#FFA500", "#0000FF", "#000000"];
    stimStrs = ["u_400", "u_200", "u_100", "u_50"];
    cdrPlotIdx = [1,2,3,4];
    CR_Ref = 1; %u/400
    fs = 500;
    yScale = [50, 60];
    CRIScale = {[0.8, 2; -0.1 0.7], [0.8, 2; -0.1 0.3]};
    FIGPATH = strcat(ROOTPATH, "Pop_Figure5_IrregVar\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");



elseif strcmpi(Protocol, "Add_on_Basic_Duration_0o5_5")
    badCH_self = [{48,49,63, 64}, {25, 41, 46, 48,49, 57,62, 64}];
    icaOpt = "off";
    plotWhole = false;
    colors = ["#AAAAAA", "#000000", "#0000FF", "#00FF00", "#FFA500", "#FF0000"];
    stimStrs = ["0o5s_1s", "1s_1s", "2s_1s", "3s_1s", "4s_1s", "5s_1s"];
    cdrPlotIdx = [6,5,4,3,2,1];
    CR_Ref = 6;% 5s
    fs = 500;
    yScale = [40, 40];
    CRIScale = {[0.8, 2; -0.1 0.7], [0.8, 2; -0.1 0.3]};
    FIGPATH = strcat(ROOTPATH, "Pop_Figure7_Duration_0.5_5\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");



elseif contains(Protocol, ["Add_on_Basic_ICI4", "Add_on_Basic_NormSqrt_ICI4", "Basic_ICI4"])
    icaOpt = "off";
    plotWhole = false;
    colors = ["#FF0000", "#FF0000", "#0000FF", "#0000FF"];
    stimStrs = ["Reg4-4o06", "Reg4o06-4", "Irreg4-4o06", "Irreg4o06-4"];
    cdrPlotIdx = [1,2,3,4];
    CR_Ref = 1;% Reg4-4.06
    fs = 500;
    CRIScale = {[0.8, 2; -0.1 1], [0.8, 2; -0.1 0.4]};
    switch Protocol
        case "Basic_ICI4"
            yScale = [40, 60];
            FIGPATH = strcat(ROOTPATH, "Pop_Figure2_RegIrreg\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");
        case "Add_on_Basic_ICI4"
            badCH_self = {[48,49,63, 64], [25, 41, 46, 48,49, 57,62, 64]};
            yScale = [40, 50];
            FIGPATH = strcat(ROOTPATH, "Pop_Sfigure2_No_Reg_In_Irreg\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");
        case "Add_on_Basic_NormSqrt_ICI4"
            badCH_self = {[48,49,63, 64], [25, 41, 46, 48,49, 57,62, 64]};
            yScale = [50, 90];
            FIGPATH = strcat(ROOTPATH, "Pop_Sfigure2_Norm_Sqrt\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");
    end

elseif strcmpi(Protocol, "Add_on_Basic_Tone")
    badCH_self = {[48,49,63, 64], [25, 41, 46, 48,49, 57,62, 64]};
    icaOpt = "off";
    plotWhole = false;
    colors = ["#0000FF", "#0000FF", "#0000FF", "#0000FF"];
    stimStrs = ["250_246Hz", "246_250Hz", "250_200Hz", "200_250Hz"];
    cdrPlotIdx = [3,4,1,2];
    CR_Ref = 3;% 250-200
    fs = 500;
    yScale = [40, 90];
    CRIScale = {[0.8, 2; -0.1 0.7], [0.8, 2; -0.1 0.3]};
    FIGPATH = strcat(ROOTPATH, "Pop_Sfigure2_Tone\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");

elseif strcmpi(Protocol, "Add_on_Reg_Insert_Rep1_mix")
    badCH_self = {[48,49,63, 64], []};
    icaOpt = "off";
    plotWhole = false;
    colors = ["#FF0000", "#0000FF", "#FF0000", "#0000FF"];
    stimStrs = ["Reg4_4o06-2s", "Reg4_4o06_4-2s", "Reg4_4o06-5s", "Reg4_4o06_4-5s"];
    cdrPlotIdx = [3,4,1,2];
    CR_Ref = 3;% Reg4-4.06 5s
    fs = 600;
    yScale = [40, 50];
    CRIScale = {[0.8, 2; -0.1 0.7], [0.8, 2; -0.1 0.3]};
    FIGPATH = strcat(ROOTPATH, "Pop_Sfigure2_Reg_Insert_Rep1\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");
elseif strcmpi(Protocol, "DiffICI_Merge")
    badCH_self = {[49], [48,49,57,64]};
    icaOpt = "off";
    plotWhole = false;
    colors = ["#FF0000", "#FFA500", "#0000FF", "#000000", "#000000"];
    stimStrs = ["4ms", "8ms", "20ms", "40ms", "80ms"];
    cdrPlotIdx = [1, 2, 3, 4, 5];
    CR_Ref = 2;% Reg8-8.12
    fs = 500;
    yScale = [50, 60];
    CRIScale = {[0.8, 2; -0.1 0.7], [0.8, 2; -0.1 0.3]};
    FIGPATH = strcat(ROOTPATH, "Pop_Figure3_DiffICI_Merge\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");

elseif strcmpi(Protocol, "Add_on_Reg_Rep1_Dur")
    badCH_self = {[48,49,63, 64], []};
    icaOpt = "off";
    plotWhole = false;
    colors = ["#000000", "#0000FF", "#FFA500", "#FF0000"];
    stimStrs = ["0o5s", "1s", "3s", "5s"];
    cdrPlotIdx = [4,3,2,1];
    CR_Ref = 4;% 
    fs = 600;
    yScale = [20, 20];
    CRIScale = {[0.8, 2; -0.1 0.7], [0.8, 2; -0.1 0.3]};
    FIGPATH = strcat(ROOTPATH, "Pop_Sfigure5_Reg_localChange_Dur\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");

elseif strcmpi(Protocol, "Add_on_Reg_Rep1_TimeCourse")
    badCH_self = {[48,49,63, 64], []};
    icaOpt = "off";
    plotWhole = false;
    colors = "#FF0000";
    stimStrs = "local time course";
    cdrPlotIdx = 1;
    CR_Ref = 1;% 
    fs = 600;
    yScale = [20, 20];
    CRIScale = {[0.8, 2; -0.1 0.7], [0.8, 2; -0.1 0.3]};
    FIGPATH = strcat(ROOTPATH, "Pop_Sfigure6_Reg_localChange_TimeCourse\", CRIMethodStr(CRIMethod), "\", monkeyStr(mIndex), "\");
end



compareIdx = flip(cdrPlotIdx);
