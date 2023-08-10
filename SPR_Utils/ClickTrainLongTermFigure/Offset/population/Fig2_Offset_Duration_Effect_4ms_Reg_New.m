close all; clc; clear;
MATPATH{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Offset\Offset_Duration_Effect_4ms_Reg_New\';
MATPATH{2} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\Offset\Offset_Duration_Effect_4ms_Reg_New\';
for mIndex = 2 : length(MATPATH)
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
    run("tb_onset_significance.m");
    run("offset_compute_CRI.m");
    run("offset_CRI_tuning.m");

    run("offset_saveRes.m");
    clearvars -except mIndex MATPATH
end
close all
