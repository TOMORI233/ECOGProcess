close all; clc; clear;
close all; clc;
clearvars -except bIndex blocks
blocks = [19];
for bIndex = 1 : length(blocks)
    MATPATH = ['D:\ECOG\chouchou\cc20230625\Block-', num2str(blocks(bIndex))];
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

    segOption = ["trial onset", "dev onset"];
    colors = ["#FF0000", "#0000FF", "#000000", "#AAAAAA"];
    stimStrs = ["4-4o06", "8-8o12", "16-16o24", "32-32o48"];

    AREANAME = ["AC", "PFC"];
    AREANAME = AREANAME(params.posIndex);

    cdrPlotIdx = [1, 2, 3, 4];
    plotWin = [-1200, 800];
    badCh = {[], []};
    yScale = [30, 30];
    quantWin = [0 300];
    latencyWin = [80 200];
    sponWin = [-300 0];

    filtFlag = true;

    %% process
    temp = string(split(MATPATH, '\'));
    DateStr = strcat(temp(end - 1), "_", temp(end));
    % Protocol = temp(end - 2);
    Protocol = "TB_Anesthesia_BaseICI_Awake";
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
    t = linspace(Window(1), Window(2), size(trialsECOG_Merge{1}, 2))';
    fs  = length(t) * 1000/ diff(Window);

    trialsECOG_Merge = ECOGFilter(trialsECOG_Merge, 1, 20, fs);
    trialsECOG_S1_Merge = ECOGFilter(trialsECOG_S1_Merge, 1, 20, fs);
    % run("tb_ICA.m");
    % run("tb_chPatch.m");
    % run("tb_interpolateBadChs");
    run("tb_cdrPlot.m");
    run("tb_plot_multiWave.m");
    run("tb_plot_multiWave_S1.m");
    % run("tb_plot_singleWave.m");
    % run("tb_compute_plot_CRI_ORI.m");

    close all
end
