function [trialAll, trialsECOG] = mergeCTLTrialsECOG(MATPATH, posIndex)

%% Parameter settings
params.posIndex = posIndex; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;

temp = string(split(MATPATH, '\'));
DateStr = temp(end - 1);
Protocol = temp(end - 2);

s1OnsetOrS2Onset = 1; % 1, s1onset; 2, s2Onset
segOption = ["trial onset", "dev onset"];

run("CTLconfig.m");

%% Processing
[trialAll, ECOGDataset] = ECOGPreprocess(MATPATH, params);
trialAll(1) = [];
devType = unique([trialAll.devOrdr]);
devTemp = {trialAll.devOnset}';
if contains(Protocol, "successive")
    ordTemp = {trialAll.ordrSeq}';
elseif contains(Protocol, "Basic")
    [~, ordTemp] = ismember([trialAll.ordrSeq]', devType);
    ordTemp = num2cell(ordTemp);
end
temp = cellfun(@(x, y) x + S1Duration(y), devTemp, ordTemp, "UniformOutput", false);
trialAll = addFieldToStruct(trialAll, temp, "devOnset");

trialsECOG = selectEcog(ECOGDataset, trialAll, segOption(s1OnsetOrS2Onset), Window);
