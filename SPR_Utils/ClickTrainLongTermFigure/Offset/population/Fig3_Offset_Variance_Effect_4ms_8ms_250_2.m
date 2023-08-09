close all; clc; clear;
MATPATH{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Offset\Offset_Variance_Effect_4ms_8ms_sigma250_2_Reg_500ms\';
MATPATH{2} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\Offset\Offset_Variance_Effect_4ms_8ms_sigma250_2_Reg_500ms\';
for mIndex = 1 : length(MATPATH)
    temp = string(split(MATPATH{mIndex}, '\'));
    Protocol = temp(end - 1);
    OffsetParams = ME_ParseOffsetParams(Protocol);
    parseStruct(OffsetParams)
    run("offset_configuration_on_protocols.m");
    mkdir(FIGPATH);
    run("offset_loadData.m");
    run("tb_ICA.m");
    run("tb_chPatch.m");
    run("tb_interpolateBadChs");
    run("offset_cdrPlot_FFT.m");
    run("offset_Comparison.m");
%     run("tb_plot_singleWave.m");
%     run("tb_compute_plot_CRI_ORI.m");
    run("offset_saveRes.m");
    clearvars -except mIndex MATPATH
end
close all
