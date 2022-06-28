function [trialAll, EEGDataset] = EEGPreprocess(DATAPATH, params, behaviorOnly)
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
    %     ECOGDataset: EEG dataset of [EEG.data]
narginchk(2, 3);

if nargin < 3
    behaviorOnly = false;
end

%% Parameter settings
run("paramsConfig.m");
params = getOrFull(params, paramsDefault);

paramsNames = fieldnames(params);

for index = 1:size(paramsNames, 1)
    eval([paramsNames{index}, '=params.', paramsNames{index}, ';']);
end

% %% Validation
% if isempty(processFcn)
%     error("Process function is not specified");
% end

%% Loading data
try
    EEG = loadcurry(DATAPATH);
catch e
    disp(e.message);
end
%% epocs
epocs = EEGAPI(EEG);
trialAll = processFcn(epocs, choiceWin);

%% EEGDataset
if ~behaviorOnly
    EEGDataset.channels = 1 : 64;
    EEGDataset.data = EEG.data(1 : 64, :);
    EEGDataset.fs = EEG.srate;
else
    ECOGDataset = [];
end

end



