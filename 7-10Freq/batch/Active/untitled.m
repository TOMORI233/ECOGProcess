ccc;

dataAC = load("XX\Population\PE\AC_PE_Data.mat");
dataPFC = load("XX\Population\PE\PFC_PE_Data.mat");

trialsECOG_AC = dataAC.trialsECOG;
trialsECOG_PFC = dataPFC.trialsECOG;
window = dataAC.windowPE;
fs = dataAC.fs;

%% 
for cIndex = 1:size(trialsECOG_AC{1}, 1)
    temp = cellfun(@(x) x(cIndex, :), trialsECOG_AC, "UniformOutput", false);
    res = mGrangerWavelet(temp, trialsECOG_PFC, fs);
end
