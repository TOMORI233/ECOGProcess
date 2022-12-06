function [trialAll, ECOGDataset] = ECOGPreprocess(DATAPATH, params, behaviorOnly)
    % Description: load data from *.mat or TDT block
    % Input:
    %     DATAPATH: full path of *.mat or TDT block path
    %     params:
    %         - posStr: all possible recording storages
    %         - posIndex: position number, 1-AC, 2-PFC
    %         - choiceWin: choice window, in ms
    %         - processFcn: behavior processing function handle
    %     behaviorOnly: if set true, return [trialAll] only
    % Output:
    %     trialAll: n*1 struct of trial information
    %     ECOGDataset: TDT dataset of [streams.(posStr(posIndex))]

    narginchk(2, 3);

    if nargin < 3
        behaviorOnly = false;
    end

    %% Parameter settings
    run("preprocessConfig.m");
    params = getOrFull(params, paramsDefault);

    paramsNames = fieldnames(params);

    for index = 1:size(paramsNames, 1)
        eval([paramsNames{index}, '=params.', paramsNames{index}, ';']);
    end

    %% Validation
    if isempty(processFcn)
        error("Process function is not specified");
    end

    %% Loading data
    try
        disp("Try loading data from MAT");

        if ~behaviorOnly
            load(DATAPATH, "-mat", "trialAll", "ECOGDataset");
        else
            load(DATAPATH, "-mat", "trialAll");
            ECOGDataset = [];
        end

    catch e
        disp(e.message);
        disp("Try loading data from TDT BLOCK...");
        temp = TDTbin2mat(char(DATAPATH), 'TYPE', {'epocs'});
        epocs = temp.epocs;
        trialAll = processFcn(epocs, choiceWin);
    
        if ~behaviorOnly
            temp = TDTbin2mat(char(DATAPATH), 'TYPE', {'streams'}, 'STORE', {char(posStr(posIndex))});
            streams = temp.streams;
            ECOGDataset = streams.(posStr(posIndex));
        else
            ECOGDataset = [];
        end

    end

    return;
end