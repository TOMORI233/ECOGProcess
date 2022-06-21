function [trialAll, ECOGDataset, segTimePoint] = ECOGPreprocessJoinBlock(BLOCKPATH, params, opts, T2)
    % Description: load data from *.mat or TDT block
    % Input:
    %     DATAPATH: full path of *.mat or TDT block path
    %     params:
    %         - posStr: all possible recording storages
    %         - posIndex: position number, 1-AC, 2-PFC
    %         - choiceWin: choice window, in ms
    %         - processFcn: behavior processing function handle
    %         - behaviorOnly: if true, return [trialAll] only
    % Output:
    %     trialAll: n*1 struct of trial information
    %     ECOGDataset: TDT dataset of [streams.(posStr(posIndex))]

    narginchk(2, 4);
    if nargin < 4
        T2 = zeros(1, length(BLOCKPATH));
    end


    %% Parameter settings
    run("paramsConfig.m");
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

        disp("Try loading data from TDT BLOCK...");
        if iscell(BLOCKPATH)
            for i = 1:length(BLOCKPATH)
                eval(['data' num2str(i) ' = TDTbin2mat(BLOCKPATH{' num2str(i) '}, ''T2'', T2(' num2str(i) '));']);
            end
        end
        
        strBuffer = '[temp segTimePoint] = joinBlocks(opts';
        for i = 1:length(BLOCKPATH)
            strBuffer = [strBuffer ', data' num2str(i)];
        end
        strBuffer = [strBuffer ');'];
        eval(strBuffer);
        epocs = temp.epocs;
        streams = temp.streams;
        ECOGDataset = streams;
        trialAll = processFcn(epocs, choiceWin);

    return;
end