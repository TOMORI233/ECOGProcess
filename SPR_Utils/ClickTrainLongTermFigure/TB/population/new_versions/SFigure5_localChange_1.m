close all; clc; clear;
MATPATH{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\TB\Add_on_Reg_Insert_Rep1_mix\';
MATPATH{2} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\TB\Add_on_Reg_Insert_Rep1_mix\';
for mIndex = 2 : length(MATPATH)
    temp = string(split(MATPATH{mIndex}, '\'));
    Protocol = temp(end - 1);
    run("tb_configuration_on_protocols.m");
    mkdir(FIGPATH);
    run("tb_loadData.m");
    run("CTLconfig.m");
    run("tb_ICA.m");
    run("tb_chPatch.m");
    run("tb_interpolateBadChs");
    run("tb_cdrPlot.m");
    run("tb_plot_multiWave.m");
    run("tb_plot_singleWave.m");
    run("tb_compute_plot_CRI_ORI.m");
    latency = [];
%     run("tb_compute_latency.m");
    run("tb_CRI_significance.m");
    run("tb_onset_significance.m");
    run("tb_CRI_tuning.m");
%     run("tb_latency_tuning.m");
    run("tb_saveRes.m");
    clearvars -except mIndex MATPATH
end
close all
