function Compare_ProcessFcn(params)
close all;
parseStruct(params);

tuningPE_AC  = load(DATAPATH{1});
tuningPE_PFC = load(DATAPATH{2});
tuningDM_AC  = load(DATAPATH{3});
tuningDM_PFC = load(DATAPATH{4});

mkdir(MONKEYPATH);

windowView = 500; % ms
timeLim = 400; % ms

fs = 500; % Hz
neighbours = mPrepareNeighbours;

windowPE = tuningPE_AC.windowMMN;
windowDM = tuningDM_AC.windowDM;
tPE = linspace(windowPE(1), windowPE(2), size(tuningPE_AC.V0_MMN, 2));
tDM = linspace(windowDM(1), windowDM(2), size(tuningDM_AC.V0, 2));

idxAC_PE  = tuningPE_AC.chIdxMMN;
idxAC_DM  = tuningDM_AC.chIdx;
maskAC_PE = -1 * (tuningPE_AC.PEI_MMN(idxAC_PE, :) < 0) + 1 * (tuningPE_AC.PEI_MMN(idxAC_PE, :) >= 0);
resultAC_PE_V = mMapminmax(tuningPE_AC.V0_MMN(idxAC_PE, :), 1) .* maskAC_PE;
resultAC_PEI  = mMapminmax(tuningPE_AC.PEI_MMN(idxAC_PE, :), 1);
resultAC_DM_V = mMapminmax(tuningDM_AC.V0(idxAC_DM, :), 1);
resultAC_DMI  = mMapminmax(tuningDM_AC.DMI(idxAC_DM, :), 1);

idxPFC_PE  = tuningPE_PFC.chIdxMMN;
idxPFC_DM  = tuningDM_PFC.chIdx;
maskPFC_PE = -1 * (tuningPE_PFC.PEI_MMN(idxPFC_PE, :) < 0) + 1 * (tuningPE_PFC.PEI_MMN(idxPFC_PE, :) >= 0);
resultPFC_PE_V = mMapminmax(tuningPE_PFC.V0_MMN(idxPFC_PE, :), 1) .* maskPFC_PE;
resultPFC_PEI  = mMapminmax(tuningPE_PFC.PEI_MMN(idxPFC_PE, :), 1);
resultPFC_DM_V = mMapminmax(tuningDM_PFC.V0(idxPFC_DM, :), 1);
resultPFC_DMI  = mMapminmax(tuningDM_PFC.DMI(idxPFC_DM, :), 1);

%% PE vs DM in AC
run("Compare_PlotImpl_PEvsDM_AC.m");

%% PE vs DM in PFC
run("Compare_PlotImpl_PEvsDM_PFC.m");

%% PE in AC vs in PFC
run("Compare_PlotImpl_ACvsPFC_PE.m");

%% DM in AC vs in PFC
run("Compare_PlotImpl_ACvsPFC_DM.m");

%% PE vs DM in AC Topo
run("Compare_PlotImpl_PEvsDM_AC_Topo.m");

%% PE vs DM in PFC Topo
run("Compare_PlotImpl_PEvsDM_PFC_Topo.m");