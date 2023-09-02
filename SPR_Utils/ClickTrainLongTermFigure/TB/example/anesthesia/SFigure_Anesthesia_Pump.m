close all; clc; clear;

blocks = [2];
for bIndex = 1 : length(blocks)
    clearvars -except bIndex blocks
          MATPATH = ['D:\ECOG\xiaoxiao\xx20230703\Block-', num2str(blocks(bIndex))];
%     MATPATH = ['D:\ECOG\chouchou\cc20230630\Block-', num2str(blocks(bIndex))];
    if contains(MATPATH, "xx")
        mIndex = 2;
    elseif contains(MATPATH, "cc")
        mIndex = 1;
    end
    % MATPATH{2} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\Add_on_Basic_Oscillation_control_500_250_125_60_30\xx20221027\xx20221027_AC.mat';
    monkeyStr = ["CC", "XX"];
    ROOTPATH = "D:\ECoG\corelDraw\ClickTrainLongTerm\Anesthesia\";
    params.posIndex = 1; % 1-AC, 2-PFC
    params.processFcn = @PassiveProcess_clickTrainContinuous;

    % Synchronize response index
    SRIMethod = 2;
    SRIMethodStr = ["Resp_devided_by_Spon", "R_minus_S_devide_R_plus_S"];
    SRIScale = [0.8, 2; 0 0.2];
    SRITest = [1, 0];

    % FFT method
    FFTMethod = 2; %1: power(dB); 2: magnitude
    CRIMethod = 2;

    segOption = ["trial onset", "dev onset"];

    AREANAME = ["AC", "PFC"];
    AREANAME = AREANAME(params.posIndex);

    cdrPlotIdx = [1, 2, 3, 4, 5, 6];
    plotWin = [-300, 500];
    s1PlotWin = [0, 1200];
    badCh = {[], []};
    yScale = [20, 30];
    quantWin = [0 300];
    latencyWin = [80 200];
    sponWin = [-300 0];

    filtFlag = true;


    %% process
    temp = string(split(MATPATH, '\'));
    DateStr = strcat(temp(end - 1), "_", temp(end));
    % Protocol = temp(end - 2);
    Protocol = "SFigure_Anesthesia_BaseICI_Ratio_Tone_Pump";
    FIGPATH = strcat(ROOTPATH, "Figure_", Protocol,"\", DateStr, "_", AREANAME, "\Figures\");
    mkdir(FIGPATH)
    % if exist(FIGPATH, "dir")
    %     return
    % end

    tic
    [trialAll, trialsECOG_Merge, trialsECOG_S1_Merge, badCHs] =  mergeCTLTrialsECOG(MATPATH, params.posIndex);
    toc
    % change response
    temp = changeCellRowNum(trialsECOG_Merge);
    temp = temp(ECOGSitePatch("AC"));
    
    trialsECOG_Merge = changeCellRowNum(temp);
    % onset response
    temp = changeCellRowNum(trialsECOG_S1_Merge);
    temp = temp(ECOGSitePatch("AC"));
    trialsECOG_S1_Merge = changeCellRowNum(temp);
        %% ICA
    run("CTLconfig.m");
    % run("tb_ICA.m");
    % run("tb_chPatch.m");
    % run("tb_interpolateBadChs");
    if exist("trialsECOG_Merge_Backup", "var")
        trialsECOG_Merge = trialsECOG_Merge_Backup;
    end

    if exist("trialsECOG_S1_Merge_Backup", "var")
        trialsECOG_S1_Merge = trialsECOG_S1_Merge_Backup;
    end

    devType = unique([trialAll.devOrdr]);
    t = linspace(Window(1), Window(2), size(trialsECOG_Merge{1}, 2))';
    fs  = length(t) * 1000/ diff(Window);

    dataSelect = "whole"; % Whole, Prior, Last
    run("tb_cdrPlot.m");
    run("tb_Anesthesia_plot_multiWave.m");
    run("tb_Anesthesia_plot_multiWave_S1.m");
    run("tb_compute_plot_CRI_ORI.m");

    save(strcat(FIGPATH, "cdrPlot.mat"), "cdrPlot", "RegRatioS1", "RegRatio", "Window", "fs", "CRI", "ORI");
    clear cdrPlot;
    if filtFlag
        devType = unique([trialAll.devOrdr]);
        t = linspace(Window(1), Window(2), size(trialsECOG_Merge{1}, 2))';
        fs  = length(t) * 1000/ diff(Window);
        trialsECOG_Merge_Backup = trialsECOG_Merge;
        trialsECOG_Merge = ECOGFilter(trialsECOG_Merge_Backup, 1,40, fs);
        trialsECOG_S1_Merge_Backup = trialsECOG_S1_Merge;
        trialsECOG_S1_Merge = ECOGFilter(trialsECOG_S1_Merge_Backup, 1,40, fs);
        run("tb_cdrPlot.m");
        run("tb_Anesthesia_plot_multiWave.m");
        run("tb_Anesthesia_plot_multiWave_S1.m");
        run("tb_compute_plot_CRI_ORI.m");
        save(strcat(FIGPATH, "cdrPlotFilter.mat"), "cdrPlot", "RegRatioS1", "RegRatio", "Window", "fs", "CRI", "ORI");

    end

    close all
end
