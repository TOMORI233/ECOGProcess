
clc;
rootPathMat = strcat("E:\ECoG\MAT Data\", monkeyName, "\ClickTrainLongTerm\MSTI\");
rootPathFig = "E:\ECoG\corelDraw\ClickTrainLongTerm\MSTI\";

%% set protocols
temp = dir(rootPathMat);
temp(ismember(string({temp.name}'), [".", ".."])) = [];
protocols = string({temp.name}');

%% select data
% areaSel = "AC";
dateSel = "";
protSel = ["MSTI_BG-5_S1-4o5_S2-4_ISI-800_Dur-300_StdN-15", "MSTI_BG-5_S1-4o5_S2-4_ISI-500_Dur-300_StdN-15", "MSTI_BG-5_S1-4o5_S2-4_ISI-400_Dur-200_StdN-15"];

% validate areaSel
if ~matches(areaSel, ["AC", "PFC"]) || length(areaSel) > 1
    error("Var 'areaSel' must be one of 'AC' and 'PFC' !");
end


for rIndex = 1 : length(protocols)

    protPathMat = strcat(rootPathMat, protocols(rIndex), "\");
    protocolStr = protocols(rIndex);

    temp = dir(protPathMat);
    temp(ismember(string({temp.name}'), [".", ".."])) = [];

    MATPATHS = cellfun(@(x) string([char(protPathMat), x, '\']), {temp.name}', "UniformOutput", false);
    MATPATHS = MATPATHS(contains(string(MATPATHS), dateSel) & contains(string(MATPATHS), protSel) );

    temp = cellfun(@(x) strsplit(x, "\"), MATPATHS, "UniformOutput", false);
    MATPATHS = cellfun(@(x, y) strcat(x, y(end-1), "_", areaSel, ".mat"), MATPATHS, temp, "uni", false);


    for mIndex = 1 : length(MATPATHS)
        clearvars -except areaSel rootPathMat rootPathFig protocols protocolStr rIndex dateSel protSel MATPATHS mIndex AREAS NAMES aIndex monIndex;
        if matches(protocolStr, ["MSTI_BG-5_S1-4o5_S2-4_ISI-800_Dur-300", "MSTI_BG-5_S1-4o5_S2-4_ISI-800-800-650_Dur-300-150-150", ...
                "MSTI_BG-5_S1-4o5_S2-4_ISI-800_Dur-300_StdN-15", "MSTI_BG-5_S1-4o5_S2-4_ISI-500_Dur-300_StdN-15", "MSTI_BG-5_S1-4o5_S2-4_ISI-400_Dur-200_StdN-15"])
            run("Figure_Example_MSTI_Basic.m");
        end

    end
end

% if ~isempty(gcp('nocreate'))
%     delete(gcp('nocreate'));
% end