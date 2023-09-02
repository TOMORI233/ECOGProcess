close all; clc; clear;
blocks = 2:14;
for bIndex = 1 : length(blocks)
    clearvars -except bIndex blocks
%         MATPATH = ['G:\ECOG\xiaoxiao\xx20230712\Block-', num2str(blocks(bIndex))];
    MATPATH = ['G:\ECOG\chouchou\cc20230714\Block-', num2str(blocks(bIndex))];
    if contains(MATPATH, "xx")
        mIndex = 2;
    elseif contains(MATPATH, "cc")
        mIndex = 1;
    end
    ROOTPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\Anesthesia\";
    params.posIndex = 1; % 1-AC, 2-PFC
    params.processFcn = @PassiveProcess_clickTrainContinuous;

    % FFT method
    segOption = ["trial onset", "dev onset"];
    AREANAME = ["AC", "PFC"];
    AREANAME = AREANAME(params.posIndex);
    quantWin = [0 300];
    sponWin = [-300 0];



    %% process
    temp = string(split(MATPATH, '\'));
    DateStr = strcat(temp(end - 1), "_", temp(end));
    % Protocol = temp(end - 2);
    Protocol = "Anesthesia_BaseICI_Ratio_Tone_Push_Spon";
    FIGPATH = strcat(ROOTPATH, "Figure_", Protocol,"\", DateStr, "_", AREANAME, "\Figures\");
    mkdir(FIGPATH)


    tic
    [trialAll, trialsECOG_Merge, trialsECOG_S1_Merge, badCHs] =  mergeCTLTrialsECOG(MATPATH, params.posIndex);
    toc
    % change response
    temp = changeCellRowNum(trialsECOG_Merge);
    temp = temp(ECOGSitePatch("AC"));
    trialsECOG_Merge = changeCellRowNum(temp);

    %% ICA
    run("CTLconfig.m");
    devType = unique([trialAll.devOrdr]);
    t = linspace(Window(1), Window(2), size(trialsECOG_Merge{1}, 2))';
    fs  = length(t) * 1000/ diff(Window);
    % FFT
    tIdx = find(t > FFTWin(1) & t < FFTWin(2));
    [ff, PMean, trialsFFT]  = trialsECOGFFT(trialsECOG_Merge, fs, tIdx, [], 2);
    Fig = plotRawWave(PMean, [], [ff(1), ff(end)], "FFT");
    scaleAxes(Fig, "x", [0, 50]);
    scaleAxes(Fig, "y", [0, 20]);
    print(Fig, strcat(FIGPATH, "FFT_Spontaneous"), "-djpeg", "-r200");
    save(strcat(FIGPATH, "cdrPlot.mat"), "ff", "PMean", "Window", "fs");
    close all
end
