close all; clc; clear;
MATPATH{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\TB\Add_on_Annoying_BaseICI_12_16\cc20230505\';

for mIndex = 1 : length(MATPATH)
    temp = string(split(MATPATH{mIndex}, '\'));
    Protocol = temp(end - 2);
    dateStr = temp(end - 1);
    run("tb_configuration_on_protocols.m");
    FIGPATH = strcat(ROOTPATH, "Ex_Sfigure13_Add_on_Annoying_BaseICI_12-16\", dateStr, "\");
    mkdir(FIGPATH);
    run("tb_loadData_Ex.m");
    run("CTLconfig.m");
    %     run("tb_ICA.m");
    run("tb_chPatch.m");
    run("tb_interpolateBadChs");
    run("tb_cdrPlot.m");
    run("tb_plot_multiWave.m");
    run("tb_plot_singleWave.m");
        run("tb_compute_plot_CRI_ORI.m");
    %     run("tb_compute_Bootstrap_CRI_ORI.m");
    %     run("tb_compute_latency.m");
    %     run("tb_CRI_significance.m");
    run("tb_onset_significance.m");
    %     run("tb_CRI_tuning.m");
    %     run("tb_CRI_Boot_tuning.m");
    % run("tb_latency_tuning.m");
    if ~exist("compare", "var")
        compare = [];
    end
    run("tb_saveRes.m");

    clearvars -except mIndex MATPATH
end
close all
