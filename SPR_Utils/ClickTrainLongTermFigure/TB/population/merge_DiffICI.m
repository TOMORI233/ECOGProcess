close all; clc; clear;

monkeyId = 1;  % 1：chouchou; 2：xiaoxiao

if monkeyId == 1
    MATPATH{1} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\TB\Basic_ICI4\';
    MATPATH{2} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\TB\Basic_ICI8\';
    MATPATH{3} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\TB\Basic_ICI20\';
    MATPATH{4} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\TB\Basic_ICI40\';
    MATPATH{5} = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\TB\Basic_ICI80\';
elseif monkeyId == 2
    MATPATH{1} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\TB\Basic_ICI4\';
    MATPATH{2} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\TB\Basic_ICI8\';
    MATPATH{3} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\TB\Basic_ICI20\';
    MATPATH{4} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\TB\Basic_ICI40\';
    MATPATH{5} = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\TB\Basic_ICI80\';
end

stimSelect = 1; % "RegOrd", "RegRev", "IrregOrd", "IrregRev"
selectCh = 9;
stimStrs = ["RegOrd", "RegRev", "IrregOrd", "IrregRev"];

protStr = ["ICI4", "ICI8", "ICI20", "ICI40", "ICI80"];
ROOTPATH = "E:\ECoG\corelDraw\ClickTrainLongTerm\Basic\";
params.posIndex = 1; % 1-AC, 2-PFC
params.processFcn = @PassiveProcess_clickTrainContinuous;

CRIMethod = 2;
CRIMethodStr = ["Resp_devided_by_Spon", "R_minus_S_devide_R_plus_S"];
CRIScale = [0.8, 2; -0.1 0.5];
CRITest = [1, 0];
pBase = 0.01;

colors = ["#FF0000", "#FFA500", "#0000FF", "#000000", "#AAAAAA"];

AREANAME = ["AC", "PFC"];
AREANAME = AREANAME(params.posIndex);
fs = 500;


    trialsECOG_Merge_Buffer = [];
    trialsECOG_S1_Merge_Buffer = [];
    trialAll_Buffer = [];
for mIndex = 1 : length(MATPATH)

    
    NegOrPos{1} = -1 * ones(64, 1);
    NegOrPos{2} = [ones(24, 1); -1*ones(40, 1)];
    chNP = NegOrPos{monkeyId};
    disp(strcat("processing ", protStr(mIndex), "..."));
    temp = string(split(MATPATH{mIndex}, '\'));
    Protocol = temp(end - 1);
    FIGPATH = strcat(ROOTPATH, "Pop_Figure3_DiffICI\", CRIMethodStr(CRIMethod), "\", temp(4), "\");
    SAVEPATH = strcat(ROOTPATH, "Pop_Figure3_DiffICI_Merge\", CRIMethodStr(CRIMethod), "\", temp(4), "\");
    mkdir(FIGPATH);
    mkdir(SAVEPATH);
    %% process
    tic
    if ~exist(strcat(FIGPATH, protStr(mIndex), "_PopulationData.mat"), "file")
        [trialsECOG_Merge, trialsECOG_S1_Merge , ~, ~, trialAll, badCHs] = mergeECOGPreprocess(MATPATH{mIndex}, AREANAME);
        save(strcat(FIGPATH, protStr(mIndex), "_PopulationData.mat"), "trialsECOG_S1_Merge", "trialsECOG_Merge", "trialAll", "badCHs");
    else
        load(strcat(FIGPATH, protStr(mIndex), "_PopulationData.mat"));
    end
    toc




    %% ICA
    % align to certain duration
    run("CTLconfig.m");
    ICAName = strcat(FIGPATH, "comp_", AREANAME, "_", protStr(mIndex), ".mat");
    trialsECOG_MergeTemp = trialsECOG_Merge;
    trialsECOG_S1_MergeTemp = trialsECOG_S1_Merge;

    if ~exist(ICAName, "file")
        [comp, ICs, FigTopoICA, FigWave] = ICA_Population(trialsECOG_MergeTemp, fs, Window);
        compT = comp;
        compT.topo(:, ~ismember(1:size(compT.topo, 2), ICs)) = 0;
        trialsECOG_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_MergeTemp, "UniformOutput", false);
        trialsECOG_S1_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_S1_MergeTemp, "UniformOutput", false);
        close(FigTopoICA);
        close(FigWave);
        save(ICAName, "compT", "comp", "ICs", "-mat");
    else
        load(ICAName);
        trialsECOG_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_MergeTemp, "UniformOutput", false);
        trialsECOG_S1_Merge = cellfun(@(x) compT.topo * comp.unmixing * x, trialsECOG_S1_MergeTemp, "UniformOutput", false);
    end

    tIndex = [trialAll.devOrdr]' == 117;
    trialsECOG_Merge_Buffer = [trialsECOG_Merge_Buffer; trialsECOG_Merge(tIndex)];
    trialsECOG_S1_Merge_Buffer = [trialsECOG_S1_Merge_Buffer; trialsECOG_S1_Merge(tIndex)];
    trialAll_Temp =  trialAll(tIndex);
    trialAll_Temp = addFieldToStruct(trialAll_Temp, num2cell(mIndex*ones(length(trialAll_Temp), 1)), "devOrdr");
    trialAll_Buffer = [trialAll_Buffer; trialAll_Temp];
    clear trialsECOG_Merge trialsECOG_S1_Merge
end
trialAll = trialAll_Buffer;
trialsECOG_Merge = trialsECOG_Merge_Buffer;
trialsECOG_S1_Merge = trialsECOG_S1_Merge_Buffer;
ResName = strcat(SAVEPATH, "PopulationData.mat");
save(ResName, "trialsECOG_S1_Merge", "trialsECOG_Merge", "trialAll");

% clearvars -except toPlot_Wave compare sigch cdrPlot ampNorm latency temp
close all
