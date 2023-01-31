function [trialAll, trialsECOG, trialsECOG_S1] = mergeCTLTrialsECOG(MATPATH, posIndex, CTLParams)
narginchk(2, 3);
if nargin < 3
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
flp = 500;
fhp = 0.1;


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
ECOGFDZ = mFTHP(ECOGDataset, fhp, flp);% filtered, dowmsampled, zoomed
ECOGFDZ = ECOGResample(ECOGFDZ, fs);
trialsECOG = selectEcog(ECOGFDZ, trialAll, segOption(2), Window);
trialsECOG_S1 = selectEcog(ECOGFDZ, trialAll, segOption(1), Window);

[trialsECOG, ~, idx] = excludeTrialsChs(trialsECOG, 0.1);

trialsECOG_S1 = trialsECOG_S1(idx);
trialAll = trialAll(idx);
