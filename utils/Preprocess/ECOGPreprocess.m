function [trialAll, ECOGDataset] = ECOGPreprocess(DATAPATH, params, varargin)
    % Description: load data from *.mat or TDT block
    % Input:
    %     DATAPATH: full path of *.mat or TDT block path
    %     params: * marks not-null fields
    %         - posStr: all possible recording storages
    %        *- posIndex: position number, 1-AC, 2-PFC
    %         - choiceWin: choice window, in ms
    %        *- processFcn: behavior processing function handle
    %         - other parameters for specific protocols
    %     behaviorOnly: if set true, return [trialAll] only
    %     patch: channel adjustment option
    % Output:
    %     trialAll: n*1 struct of trial information
    %     ECOGDataset: TDT dataset of [streams.(posStr(posIndex))]
    % Example:
    %     TDTPath = 'D:\Data\xx\xx20230220\Block-1';
    %     params.posIndex = 1; % AC
    %     params.choiceWin = [100, 800]; % ms
    %     params.processFcn = @ActiveProcess_7_10Freq;
    %     [trialAll, ECOGDataset] = ECOGPreprocess(DATAPATH, params);

    mIp = inputParser;
    mIp.addRequired("DATAPATH");
    mIp.addRequired("params", @(x) isstruct(x));
    mIp.addParameter("behaviorOnly", false, @(x) validateattrbutes(x, 'logical', {'scalar'}));
    mIp.addParameter("patch", "reject", @(x) any(validatestring(x, {'reject', 'matchIssue', 'bankIssue'})));
    mIp.parse(DATAPATH, params, varargin{:});

    behaviorOnly = mIp.Results.behaviorOnly;
    patch = mIp.Results.patch;

    %% Parameter settings
    run(fullfile(fileparts(fileparts(mfilename("fullpath"))), "Config\preprocessConfig.m"));
    params = getOrFull(params, paramsDefault);
    parseStruct(params);

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
        trialAll = processFcn(epocs, params);
    
        if ~behaviorOnly
            temp = TDTbin2mat(char(DATAPATH), 'TYPE', {'streams'}, 'STORE', {char(posStr(posIndex))});
            streams = temp.streams;

            if ~strcmpi(patch, "reject")
                streams.(posStr(posIndex)).data = streams.(posStr(posIndex)).data(ECOGSitePatch(posStr(posIndex), patch), :);
            end

            ECOGDataset = streams.(posStr(posIndex));
        else
            ECOGDataset = [];
        end

    end

    return;
end