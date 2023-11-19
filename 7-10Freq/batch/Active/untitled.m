ccc;

dataAC = load("XX\Population\PE\AC_PE_Data.mat");
dataPFC = load("XX\Population\PE\PFC_PE_Data.mat");

trialsECOG_AC = dataAC.trialsECOG;
trialsECOG_PFC = dataPFC.trialsECOG;
window = dataAC.windowPE;
fs = dataAC.fs;

%% 
for cIndex = 1:size(trialsECOG_AC{1}, 1)
    temp1 = cellfun(@(x) x(cIndex, :), trialsECOG_AC, "UniformOutput", false);
    temp2 = cellfun(@(x) x(1, :), trialsECOG_PFC, "UniformOutput", false);
    res = mGrangerWavelet(temp1, temp2, fs);
end
