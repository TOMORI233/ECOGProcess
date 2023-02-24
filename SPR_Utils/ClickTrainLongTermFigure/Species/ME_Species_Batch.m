clear; clc;
rootPathMat = "E:\ECoG\MAT Data\XX\ClickTrainLongTerm\SpeciesNew\";
rootPathFig = "E:\ECoG\corelDraw\ClickTrainLongTerm\Species\";

%% set protocols
temp = dir(rootPathMat);
temp(ismember(string({temp.name}'), [".", ".."])) = [];
protocols = string({temp.name}');

%% select data
areaSel = "AC";
dateSel = "xx20221121";
protSel = "Species_2_4_6_8_Duaration_1o5";

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
        clearvars -except areaSel rootPathMat rootPathFig protocols protocolStr rIndex dateSel protSel MATPATHS mIndex

        if matches(protocolStr, ["Species_2_4ms_Ratio", "Species_6_8ms_Ratio"])
            run("Figure_Example_Species_Basic.m");
        elseif matches(protocolStr, ["Species_2_4_6_8_Duaration_1o5", "Species_2_4_6_8_Duaration_1o015"])
            run("Figure_Example_Species_Basic.m");
        elseif matches(protocolStr, ["Species2_4_Oscillation_1o5", "Species6_8_Oscillation_1o5", "Species2_4_Oscillation_1o015", "Species6_8_Oscillation_1o015"])
            continue
        elseif matches(protocolStr, ["Species2_4_Variance_1o5", "Species6_8_Variance_1o5", "Species2_4_Variance_1o015", "Species6_8_Variance_1o015"])
            run("Figure_Example_Species_Basic.m");
        elseif matches(protocolStr, ["Species_2ms_Control_1o5", "Species_4ms_Control_1o5", "Species_2ms_Control_1o015", "Species_4ms_Control_1o015"])
%             continue
            run("Figure_Example_Species_Basic.m");
        end

    end
end

% if ~isempty(gcp('nocreate'))
%     delete(gcp('nocreate'));
% end