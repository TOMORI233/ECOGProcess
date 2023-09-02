close all; clc; clear;
matRootpath = {
%     'G:\ECOG\xiaoxiao\xx20230703\Block-'...
%     'G:\ECOG\xiaoxiao\xx20230707\Block-'...
%     'G:\ECOG\xiaoxiao\xx20230712\Block-'...
%     'G:\ECOG\chouchou\cc20230710\Block-'...
%     'G:\ECOG\chouchou\cc20230714\Block-'...
      'G:\ECOG\chouchou\cc20230719\Block-'...
    };
blocks = [1, 3:14];
for dateIdx = 1 : length(matRootpath)

    for bIndex = 1 : length(blocks)
        try
            clearvars -except bIndex blocks matRootpath dateIdx
            MATPATH = [matRootpath{dateIdx}, num2str(blocks(bIndex))];
            %     MATPATH = ['G:\ECOG\chouchou\cc20230710\Block-', num2str(blocks(bIndex))];
            if contains(MATPATH, "xx")
                mIndex = 2;
            elseif contains(MATPATH, "cc")
                mIndex = 1;
            end
            % MATPATH{2} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\Add_on_Basic_Oscillation_control_500_250_125_60_30\xx20221027\xx20221027_AC.mat';
            monkeyStr = ["CC", "XX"];
            ROOTPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\Anesthesia\";
            params.posIndex = 1; % 1-AC, 2-PFC
            params.processFcn = @PassiveProcess_clickTrainContinuous;

            % Synchronize response index
            SRIMethod = 2;
            SRIMethodStr = ["Resp_devided_by_Spon", "R_minus_S_devide_R_plus_S"];
            SRIScale = [0.8, 2; 0 0.2];
            SRITest = [1, 0];
            CRIMethod = 2;

            % FFT method
            FFTMethod = 2; %1: power(dB); 2: magnitude

            segOption = ["trial onset", "dev onset"];

            AREANAME = ["AC", "PFC"];
            AREANAME = AREANAME(params.posIndex);

            cdrPlotIdx = [1, 2, 3, 4, 5, 6];
            plotWin = [-300, 500];
            s1PlotWin = [0, 600];
            badCh = {[], []};
            yScale = [20, 20];
            quantWin = [0 200];
            latencyWin = [80 200];
            sponWin = [-200 0];

            filtFlag = false;


            %% process
            temp = string(split(MATPATH, '\'));
            DateStr = strcat(temp(end - 1), "_", temp(end));
            % Protocol = temp(end - 2);
            Protocol = "Anesthesia_BaseICI_Ratio_Tone_Push";
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


            boostrapFlag = false;
            filtFlag = false;
            devType = unique([trialAll.devOrdr]);
            t = linspace(Window(1), Window(2), size(trialsECOG_Merge{1}, 2))';
            fs  = length(t) * 1000/ diff(Window);
            run("tb_cdrPlot.m");
            run("tb_Anesthesia_plot_multiWave.m");
            run("tb_Anesthesia_plot_multiWave_S1.m");
            run("tb_compute_plot_CRI_ORI.m");
            save(strcat(FIGPATH, "cdrPlot.mat"), "cdrPlot", "RegRatioS1", "RegRatio", "Window", "fs", "CRI", "ORI");
            clear cdrPlot;

            boostrapFlag = false;
            filtFlag = true;
            if filtFlag
                trialsECOG_Merge_Backup = trialsECOG_Merge;
                trialsECOG_Merge = ECOGFilter(trialsECOG_Merge_Backup, 5,40, fs);
                trialsECOG_S1_Merge_Backup = trialsECOG_S1_Merge;
                trialsECOG_S1_Merge = ECOGFilter(trialsECOG_S1_Merge_Backup, 5,40, fs);
                run("tb_cdrPlot.m");
                run("tb_Anesthesia_plot_multiWave.m");
                run("tb_Anesthesia_plot_multiWave_S1.m");
                run("tb_compute_plot_CRI_ORI.m");
                save(strcat(FIGPATH, "cdrPlotFilter.mat"), "cdrPlot", "RegRatioS1", "RegRatio", "Window", "fs", "CRI", "ORI");
            end

            clear cdrPlot;
            boostrapFlag = true;
            filtFlag = false;
            if boostrapFlag
                run("tb_cdrPlotBoostrap.m");
                run("tb_Anesthesia_plot_multiWave.m");
                run("tb_Anesthesia_plot_multiWave_S1.m");
                run("tb_compute_plot_CRI_ORI.m");
                save(strcat(FIGPATH, "cdrPlotBoostrap.mat"), "cdrPlot", "RegRatioS1", "RegRatio", "Window", "fs", "CRI", "ORI");
            end


            close all
        end
    end
end
