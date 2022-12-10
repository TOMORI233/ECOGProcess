function [LAuC_comp, LPFC_comp] = longTermICAByFilterRes(LAuC_matPath, LPFC_matPath, stimCode)
% ICA analysis with filterRes.mat

rootStr = strsplit(LAuC_matPath, "\");
LAuC_ICAPath = strjoin([rootStr(1:end-1), "LAuC_ICAComp.mat"], "\");
LPFC_ICAPath = strjoin([rootStr(1:end-1), "LPFC_ICAComp.mat"], "\");

LAuC_ICAWave = strjoin([rootStr(1:end-1), "LAuC_ICAWave"], "\");
LPFC_ICAWave = strjoin([rootStr(1:end-1), "LPFC_ICAWave"], "\");
LAuC_ICATopo = strjoin([rootStr(1:end-1), "LAuC_ICATopo"], "\");
LPFC_ICATopo = strjoin([rootStr(1:end-1), "LPFC_ICATopo"], "\");

if exist(LAuC_ICAPath, 'file') && exist(LPFC_ICAPath, 'file')

    load(LAuC_ICAPath);
    load(LPFC_ICAPath);

else


    load(LAuC_matPath);
    LAuC_FilterRes = filterRes;
    load(LPFC_matPath);
    LPFC_FilterRes = filterRes;

    t = LAuC_FilterRes(stimCode).t;
    S1Duration = LAuC_FilterRes(stimCode).S1Duration;

    window = [t(1) t(end)];
    t1 = [-S1Duration 0];
    t2 = t1 + 500;

    % ac
    [LAuC_comp, LAuC_Ch] = mICAByFiltRes(LAuC_FilterRes, stimCode);
    LAuC_comp = realignIC(LAuC_comp, window, t1, t2);
    LAuC_ICARes = cellfun(@(x) LAuC_comp.unmixing * x(LAuC_Ch, :), LAuC_FilterRes(stimCode).FDZData, "UniformOutput", false);
    meanICA = cell2mat(cellfun(@mean , changeCellRowNum(LAuC_ICARes), 'UniformOutput', false));
    Fig_AC_Wave = plotRawWave(meanICA, [], [t(1) t(end)], "ICA", [8, 8], 1:64, "off");
    topoTemp = zeros(64, size(LAuC_comp.topo, 2));
    topoTemp(LAuC_Ch, :) = LAuC_comp.topo;
    LAuC_compTemp = LAuC_comp;
    LAuC_compTemp.topo = topoTemp;
    Fig_AC_Topo = plotTopoICA(LAuC_compTemp, [8, 8], [8, 8]);
    LAuC_comp = rmfield(LAuC_compTemp, "trial");
    clear topoTemp


    % pfc
    [LPFC_comp, LPFC_Ch] = mICAByFiltRes(LPFC_FilterRes, stimCode);
    LPFC_comp = realignIC(LPFC_comp, window, t1, t2);
    LPFC_ICARes = cellfun(@(x) LPFC_comp.unmixing * x(LPFC_Ch, :), LPFC_FilterRes(stimCode).FDZData, "UniformOutput", false);
    meanICA = cell2mat(cellfun(@mean , changeCellRowNum(LPFC_ICARes), 'UniformOutput', false));
    Fig_PFC_Wave = plotRawWave(meanICA, [], [t(1) t(end)], "ICA", [8, 8], 1:64, "off");
    topoTemp = zeros(64, size(LPFC_comp.topo, 2));
    topoTemp(LPFC_Ch, :) = LPFC_comp.topo;
    LPFC_compTemp = LPFC_comp;
    LPFC_compTemp.topo = topoTemp;
    Fig_PFC_Topo = plotTopoICA(LPFC_compTemp, [8, 8], [8, 8]);
    LPFC_comp = rmfield(LPFC_compTemp, "trial");
    clear topoTemp

    % save ica result
    print(Fig_AC_Wave, LAuC_ICAWave, "-djpeg", "-r300");
    print(Fig_AC_Topo, LAuC_ICATopo, "-djpeg", "-r300");
    print(Fig_PFC_Wave, LPFC_ICAWave, "-djpeg", "-r300");
    print(Fig_PFC_Topo, LPFC_ICATopo, "-djpeg", "-r300");
    close all;


    save(LAuC_ICAPath, "LAuC_comp", "-mat");
    save(LPFC_ICAPath, "LPFC_comp", "-mat");
    

end
