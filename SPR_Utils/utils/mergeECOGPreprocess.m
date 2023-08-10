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
m_AC = 0;
m_PFC = 0;
for fIndex = 1:length(temp)

    MATFiles = what([rootPathMat, temp(fIndex).name]).mat;

    for mIndex = 1:length(MATFiles)
        [~, name] = fileparts(MATFiles{mIndex});
        splitName = split(name, '_');
         
        if nargin < 3
            if isequal(splitName{end}, 'AC') && isequal(string(areaSelect), 'AC')
                m_AC = m_AC+1;
                [trialAll{m_AC}, trialsECOG.AC{m_AC}, trialsECOG_S1.AC{m_AC}, chIdx{m_AC}] =  mergeCTLTrialsECOG([rootPathMat, temp(fIndex).name, '\', MATFiles{mIndex}], 1);
            elseif isequal(splitName{end}, 'PFC') && isequal(string(areaSelect), 'PFC')
                m_PFC = m_PFC+1;
                [trialAll{m_PFC}, trialsECOG.PFC{m_PFC}, trialsECOG_S1.PFC{m_PFC}, chIdx{m_PFC}] =  mergeCTLTrialsECOG([rootPathMat, temp(fIndex).name, '\', MATFiles{mIndex}], 2);
            end
        else
            if isequal(splitName{end}, 'AC') && isequal(string(areaSelect), 'AC')
                m_AC = m_AC+1;
                [trialAll{m_AC}, trialsECOG.AC{m_AC}, trialsECOG_S1.AC{m_AC}, chIdx{m_AC}] =  mergeCTLTrialsECOG([rootPathMat, temp(fIndex).name, '\', MATFiles{mIndex}], 1, params);
            elseif isequal(splitName{end}, 'PFC') && isequal(string(areaSelect), 'PFC')
                m_PFC = m_PFC+1;
                [trialAll{m_PFC}, trialsECOG.PFC{m_PFC}, trialsECOG_S1.PFC{m_PFC}, chIdx{m_PFC}] =  mergeCTLTrialsECOG([rootPathMat, temp(fIndex).name, '\', MATFiles{mIndex}], 2, params);
            end
        end
    end

end

selIdx = ~cellfun(@isempty, trialAll);
trialAll_merge = mergeSameFieldStruct(trialAll(selIdx));
if isequal(string(areaSelect), 'AC')
    trialsECOG_ACMerge = mergeSameContentCell(trialsECOG.AC(selIdx));
    trialsECOG_S1_ACMerge = mergeSameContentCell(trialsECOG_S1.AC(selIdx));
    trialsECOG_PFCMerge = [];
    trialsECOG_S1_PFCMerge = [];
end
if isequal(string(areaSelect), 'PFC')
    trialsECOG_ACMerge = [];
    trialsECOG_S1_ACMerge = [];
    trialsECOG_PFCMerge = mergeSameContentCell(trialsECOG.PFC(selIdx));
    trialsECOG_S1_PFCMerge = mergeSameContentCell(trialsECOG_S1.PFC(selIdx));
end
if ~iscolumn(chIdx)
    chIdx = chIdx';
end
chIdx = unique(cell2mat(chIdx));





