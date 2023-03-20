function [trialsECOG_ACMerge, trialsECOG_S1_ACMerge, trialsECOG_PFCMerge, trialsECOG_S1_PFCMerge,trialAll_merge, chIdx] = mergeECOGPreprocess(rootPathMat, areaSelect, params)
narginchk(2, 3);


temp = dir(rootPathMat);
temp(ismember(string({temp.name}'), [".", ".."])) = [];

trialAll = cell(length(temp), 1);
trialsECOG.AC = cell(length(temp), 1);
trialsECOG.PFC = cell(length(temp), 1);
trialsECOG_S1.AC = cell(length(temp), 1);
trialsECOG_S1.PFC = cell(length(temp), 1);
chIdx = cell(length(temp), 1);
for fIndex = 1:length(temp)

    MATFiles = what([rootPathMat, temp(fIndex).name]).mat;

    for mIndex = 1:length(MATFiles)
        [~, name] = fileparts(MATFiles{mIndex});
        splitName = split(name, '_');
        if nargin < 3
            if isequal(splitName{end}, 'AC') && isequal(string(areaSelect), 'AC')
                [trialAll{fIndex}, trialsECOG.AC{fIndex}, trialsECOG_S1.AC{fIndex}, chIdx{fIndex}] =  mergeCTLTrialsECOG([rootPathMat, temp(fIndex).name, '\', MATFiles{mIndex}], 1);
            elseif isequal(splitName{end}, 'PFC') && isequal(string(areaSelect), 'PFC')
                [trialAll{fIndex}, trialsECOG.PFC{fIndex}, trialsECOG_S1.PFC{fIndex}, chIdx{fIndex}] =  mergeCTLTrialsECOG([rootPathMat, temp(fIndex).name, '\', MATFiles{mIndex}], 2);
            end
        else
            if isequal(splitName{end}, 'AC') && isequal(string(areaSelect), 'AC')
                [trialAll{fIndex}, trialsECOG.AC{fIndex}, trialsECOG_S1.AC{fIndex}, chIdx{fIndex}] =  mergeCTLTrialsECOG([rootPathMat, temp(fIndex).name, '\', MATFiles{mIndex}], 1, params);
            elseif isequal(splitName{end}, 'PFC') && isequal(string(areaSelect), 'PFC')
                [trialAll{fIndex}, trialsECOG.PFC{fIndex}, trialsECOG_S1.PFC{fIndex}, chIdx{fIndex}] =  mergeCTLTrialsECOG([rootPathMat, temp(fIndex).name, '\', MATFiles{mIndex}], 2, params);
            end
        end
    end

end

selIdx = ~cellfun(@isempty, trialAll);
trialAll_merge = mergeSameFieldStruct(trialAll(selIdx));
trialsECOG_ACMerge = mergeSameContentCell(trialsECOG.AC(selIdx));
trialsECOG_PFCMerge = mergeSameContentCell(trialsECOG.PFC(selIdx));
trialsECOG_S1_ACMerge = mergeSameContentCell(trialsECOG_S1.AC(selIdx));
trialsECOG_S1_PFCMerge = mergeSameContentCell(trialsECOG_S1.PFC(selIdx));
chIdx = unique(cell2mat(chIdx));





