clear; clc;
rootPathMat = "E:\ECoG\MAT Data\CC\ClickTrainLongTerm\Offset\";
rootPathFig = "E:\ECoG\corelDraw\ClickTrainLongTerm\Offset\";

%% set protocols
temp = dir(rootPathMat);
temp(ismember(string({temp.name}'), [".", ".."])) = [];
protocols = string({temp.name}');

%% select data
areaSel = "AC";
dateSel = "";
protSel = ["Offset_Var_4ms_Last4_8_16"];

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

        if matches(protocolStr, ["Offset_2_128_4s", ...
                                "Offset_256_512_10s",...
                                "Offset_Duration_Effect_4ms_16ms_Reg", ...
                                "Offset_Variance_Effect_4ms_16ms_sigma250_2_Reg", ...
                                "Offset_2_128_4s_New", ...
                                "Offset_Duration_Effect_4ms_Reg_New", ...
                                "Offset_Duration_Effect_8ms_Reg_New", ...
                                "Offset_Variance_Effect_4ms_8ms_sigma250_2_Reg_500ms", ...
                                "Offset_Variance_Effect_4ms_8ms_sigma100_2_Reg_500ms", ...
                                "Offset_4ms_16ms_Int_last2", ...
                                "Offset_16ms_Int_last4-8", ...
                                "Offset_16ms_Int_SingleChange_last8", ...
                                "Offset_16ms_Int_SingleChange_LowHigh_last8", ...
                                "Offset_16ms_Int_SingleChange_LowHigh_last12", ...
                                "Offset_Var_4ms_Last4_8_16", ...
                                "Offset_Anesthesia_16_64_Awake", ...
                                "Offset_Anesthesia_16_64_Rate_20", ...
                                "Offset_Anesthesia_16_64_Rate_40", ...
                                ])
            run("Figure_Example_Offset_Basic.m");
        end

    end
end

% if ~isempty(gcp('nocreate'))
%     delete(gcp('nocreate'));
% end