function [trialAll, trialsECOG, trialsECOG_S1] = selectCTLTrialsECOG(MATPATH, posIndex, CTLParams)
narginchk(2, 3);
if nargin < 3
    Protocol = evalin("base", "Protocol");
    run("CTLconfig.m");
else
    parseStruct(CTLParams);
end
%% Parameter settings
params.posIndex = posIndex; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;

temp = string(split(MATPATH, '\'));
Protocol = temp(end - 2);

segOption = ["trial onset", "dev onset"];
%% Processing
[trialAll, ECOGDataset] = ECOGPreprocess(MATPATH, params);
trialAll(1) = [];
trialAll([trialAll.devOrdr] == 0) = [];
trialAll(end) = [];
devType = unique([trialAll.devOrdr]);
devTemp = {trialAll.devOnset}';
if contains(Protocol, "Successive")
    ordTemp = {trialAll.ordrSeq}';
elseif contains(Protocol, "Basic")
    [~, ordTemp] = ismember([trialAll.ordrSeq]', devType);
    ordTemp = num2cell(ordTemp);
elseif contains(Protocol, "Duration")
    [~, ordTemp] = ismember([trialAll.ordrSeq]', devType);
    ordTemp = num2cell(ordTemp);
elseif contains(Protocol, "Species")
    [~, ordTemp] = ismember([trialAll.ordrSeq]', devType);
    ordTemp = num2cell(ordTemp);
elseif contains(Protocol, "Rhythm")
    [~, ordTemp] = ismember([trialAll.ordrSeq]', devType);
    ordTemp = num2cell(ordTemp);
end
if max(devType) > 100
    temp = cellfun(@(x, y) x + S1Duration(y), devTemp, ordTemp, "UniformOutput", false);
else
    temp = cellfun(@(x, y) x + S1Duration(y), devTemp, {trialAll.ordrSeq}', "UniformOutput", false);
end
trialAll = addFieldToStruct(trialAll, temp, "devOnset");


% filter
trialsECOG = selectEcog(ECOGDataset, trialAll, segOption(2), Window);
trialsECOG_S1 = selectEcog(ECOGDataset, trialAll, segOption(1), Window);

