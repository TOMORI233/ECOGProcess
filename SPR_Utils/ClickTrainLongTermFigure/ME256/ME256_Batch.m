clear; clc;
rootPathMat = "E:\ECoG\MAT Data\Joker\ClickTrainLongTerm\ME256\";
rootPathFig = "E:\ECoG\corelDraw\ClickTrainLongTerm\ME256\";

%% set protocols
temp = dir(rootPathMat);
temp(ismember(string({temp.name}'), [".", ".."])) = [];
protocols = string({temp.name}');

%% select data
areaSel = "AC";
dateSel = "";
protSel = ["TB_Basic", "TB_BaseICI", "TB_Ratio", "TB_Jitter"];

% validate areaSel
if ~matches(areaSel, "AC") || length(areaSel) > 1
    error("Var 'areaSel' must be one of 'AC' !");
end


for rIndex = 1 : length(protocols)

    protPathMat = strcat(rootPathMat, protocols(rIndex), "\");
    protocolStr = protocols(rIndex);

    temp = dir(protPathMat);
    temp(ismember(string({temp.name}'), [".", ".."])) = [];

    MATPATHS = cellfun(@(x) string([char(protPathMat), x, '\']), {temp.name}', "UniformOutput", false);
    MATPATHS = MATPATHS(contains(string(MATPATHS), dateSel) & contains(string(MATPATHS), protSel) );

    temp = cellfun(@(x) strsplit(x, "\"), MATPATHS, "UniformOutput", false);
    MATPATHS = cellfun(@(x, y) strcat(x, y(end-1),".mat"), MATPATHS, temp, "uni", false);


    for mIndex = 1 : length(MATPATHS)
        clearvars -except areaSel rootPathMat rootPathFig protocols protocolStr rIndex dateSel protSel MATPATHS mIndex
            run("Figure_Example_ME256_Basic.m");

    end
end

% if ~isempty(gcp('nocreate'))
%     delete(gcp('nocreate'));
% end