function [trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH, params)
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
    temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'epocs'});
    epocs = temp.epocs;
    temp = TDTbin2mat(BLOCKPATH, 'TYPE', {'streams'}, 'STORE', posStr(posIndex));
    streams = temp.streams;
    ECOGDataset = streams.(posStr(posIndex));

    %% Processing
    trialAll = processFcn(epocs, choiceWin);

    return;
end