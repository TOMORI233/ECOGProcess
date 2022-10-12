clc; clear; close all force;


rootPathMat{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Basic_ICI4\';
rootPathMat{2} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Basic_ICI8\';
rootPathMat{3} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Basic_ICI20\';
rootPathMat{4} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Basic_ICI40\';
rootPathMat{5} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Basic_ICI80\';

ROOTPATH = "E:\ECOG\ICAFigures\ClickTrainLongTerm\Basic_DiffICI\";
compPath = strcat(ROOTPATH, "Merge_ICA\");
mkdir(compPath);



for rIndex = 1 : length(rootPathMat)
    tempStr = strsplit(rootPathMat{rIndex}, "\");
    Protocol = tempStr{end};

    temp = dir(rootPathMat{rIndex});
    temp(ismember(string({temp.name}'), [".", ".."])) = [];

    trialAll = cell(length(temp), 1);
    trialsECOG.AC = cell(length(temp), 1);
    trialsECOG.PFC = cell(length(temp), 1);

    for fIndex = 1:length(temp)

        MATFiles = what([rootPathMat{rIndex}, temp(fIndex).name]).mat;

        for mIndex = 1:length(MATFiles)
            [~, name] = fileparts(MATFiles{mIndex});
            splitName = split(name, '_');

            if strcmp(splitName{end}, 'AC')
                [trialAll{fIndex}, trialsECOG.AC{fIndex}] =  mergeCTLTrialsECOG([rootPathMat{rIndex}, temp(fIndex).name, '\', MATFiles{mIndex}], 1);
            elseif strcmp(splitName{end}, 'PFC')
                [trialAll{fIndex}, trialsECOG.PFC{fIndex}] =  mergeCTLTrialsECOG([rootPathMat{rIndex}, temp(fIndex).name, '\', MATFiles{mIndex}], 2);
            end
        end

    end


trialAll_merge.(Protocol) = mergeSameFieldStruct(trialAll);
trialsECOG_ACMerge.(Protocol) = mergeSameContentCell(trialsECOG.AC);
trialsECOG_PFCMerge.(Protocol) = mergeSameContentCell(trialsECOG.PFC);
sampleinfo = [zeros(length(trialAll_merge.(Protocol)), 1) ones(length(trialAll_merge.(Protocol)), 1)];
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
trialsECOG_ACMergeICA = cellfun(@(x) comp.unmixing * x, trialsECOG_ACMerge, "UniformOutput", false);


%% PFC
ICAName = strcat(compPath, "comp_PFC.mat");

if ~exist(ICAName, "file")
    comp = mICA2(trialsECOG_PFCMerge, sampleinfo, 1:64, window, 500);
    comp = rmfield(comp, "trial");
    save(ICAName, "comp", "-mat");
else
    load(ICAName);
end
trialsECOG_PFCMergeICA = cellfun(@(x) comp.unmixing * x, trialsECOG_PFCMerge, "UniformOutput", false);

end

