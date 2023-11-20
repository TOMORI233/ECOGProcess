ccc;

dataAC = load("..\..\7-10Freq\batch\Active\CC\Population\PE\AC_PE_Data.mat");
dataPFC = load("..\..\7-10Freq\batch\Active\CC\Population\PE\PFC_PE_Data.mat");

trialsECOG_AC = dataAC.trialsECOG;
trialsECOG_PFC = dataPFC.trialsECOG;
window = dataAC.windowPE;
fs = dataAC.fs;

nChsAC = size(trialsECOG_AC{1}, 1);
nChsPFC = size(trialsECOG_PFC{1}, 1);

%% 
for cIndexAC = 1:nChsAC
    for cIndexPFC = 1:nChsPFC
        tempAC = cellfun(@(x) x(cIndexAC, :), trialsECOG_AC, "UniformOutput", false);
        tempPFC = cellfun(@(x) x(cIndexPFC, :), trialsECOG_PFC, "UniformOutput", false);
        res = mGrangerWavelet(tempAC, tempPFC, fs);
    end
end

