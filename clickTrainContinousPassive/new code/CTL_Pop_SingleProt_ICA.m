function [trialAll_merge, trialsECOG_Merge, trialsECOG_MergeICA] = CTL_Pop_SingleProt_ICA(rootPathMat, ROOTPATH)
% rootPathMat = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\successive_0o1_0o2\';
% ROOTPATH = "E:\ECOG\ICAFigures\ClickTrainLongTerm\successive_0o1_0o2\";
% rootPathMat = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\successive_0o3_0o5\';
% ROOTPATH = "E:\ECOG\ICAFigures\ClickTrainLongTerm\successive_0o3_0o5\";
compPath = strcat(ROOTPATH, "Merge_ICA\");
mkdir(compPath);

temp = dir(rootPathMat);
MATPATHs = [];
temp(ismember(string({temp.name}'), [".", ".."])) = [];

trialAll = cell(length(temp), 1);
trialsECOG.AC = cell(length(temp), 1);
trialsECOG.PFC = cell(length(temp), 1);

for fIndex = 1:length(temp)

    MATFiles = what([rootPathMat, temp(fIndex).name]).mat;

    for mIndex = 1:length(MATFiles)
        [~, name] = fileparts(MATFiles{mIndex});
        splitName = split(name, '_');

        if strcmp(splitName{end}, 'AC')
           [trialAll{fIndex}, trialsECOG.AC{fIndex}] =  mergeCTLTrialsECOG([rootPathMat, temp(fIndex).name, '\', MATFiles{mIndex}], 1);
        elseif strcmp(splitName{end}, 'PFC')
           [trialAll{fIndex}, trialsECOG.PFC{fIndex}] =  mergeCTLTrialsECOG([rootPathMat, temp(fIndex).name, '\', MATFiles{mIndex}], 2);
        end
    end

end

trialAll_merge = mergeSameFieldStruct(trialAll);
trialsECOG_Merge.AC = mergeSameContentCell(trialsECOG.AC);
trialsECOG_Merge.PFC = mergeSameContentCell(trialsECOG.PFC);
sampleinfo = [zeros(length(trialAll_merge), 1) ones(length(trialAll_merge), 1)];
window = [0 10000];

%% AC 
ICAName = strcat(compPath, "comp_AC.mat");

if ~exist(ICAName, "file")
comp = mICA2(trialsECOG_ACMerge, sampleinfo, 1:64, window, 500);
comp = rmfield(comp, "trial");
save(ICAName, "comp", "-mat");
else
    load(ICAName);
end
trialsECOG_MergeICA.AC = cellfun(@(x) comp.unmixing * x, trialsECOG_Merge.AC, "UniformOutput", false);


%% PFC 
ICAName = strcat(compPath, "comp_PFC.mat");

if ~exist(ICAName, "file")
comp = mICA2(trialsECOG_PFCMerge, sampleinfo, 1:64, window, 500);
comp = rmfield(comp, "trial");
save(ICAName, "comp", "-mat");
else
    load(ICAName);
end
trialsECOG_MergeICA.PFC = cellfun(@(x) comp.unmixing * x, trialsECOG_Merge.PFC, "UniformOutput", false);



