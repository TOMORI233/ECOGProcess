function [trialAll_merge, trialsECOG_Merge] = CTL_Pop_MultiProt_Raw(rootPathMat)

for rIndex = 1 : length(rootPathMat)
    tempStr = strsplit(rootPathMat{rIndex}, "\");
    Protocol = tempStr{end - 1};

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
    trialsECOG_Merge.AC.(Protocol) = mergeSameContentCell(trialsECOG.AC);
    trialsECOG_Merge.PFC.(Protocol) = mergeSameContentCell(trialsECOG.PFC);

end
end

