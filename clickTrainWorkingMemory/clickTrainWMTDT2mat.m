clear; clc; close all;

blksActive = {'E:\ECoG\chouchou\cc20220530\Block-4'; ...
    'E:\ECoG\chouchou\cc20220531\Block-1';...
    'E:\ECoG\chouchou\cc20220602\Block-1';...
    'E:\ECoG\chouchou\cc20220604\Block-1';...
    'E:\ECoG\chouchou\cc20220605\Block-3';...
    'E:\ECoG\chouchou\cc20220607\Block-1';...
    };

blksPassive = {'E:\ECoG\chouchou\cc20220530\Block-5'; ...
    'E:\ECoG\chouchou\cc20220531\Block-2';...
    'E:\ECoG\chouchou\cc20220602\Block-2';...
    'E:\ECoG\chouchou\cc20220604\Block-2';...
    'E:\ECoG\chouchou\cc20220605\Block-2';...
    'E:\ECoG\chouchou\cc20220607\Block-2';...
    };
%% click train compare

params.choiceWin = [100, 800];
params.processFcn = @ActiveProcess_clickTrainWM;
SAVEPATH = 'E:\ECoG\matData\CC\ClickTrainOddCompare';
exportTDT2Mat(blksActive, SAVEPATH, params, 'Active');

exportTDT2Mat(blksPassive, SAVEPATH, params, 'Passive');


function exportTDT2Mat(blks, SAVEPATH, params, activeOrPassive)
for blkN = 1 :length(blks)
    for posIndex = 1 : 2
        clearvars -except posIndex blkN blks params SAVEPATH activeOrPassive
        posStr = ["LAuC", "LPFC"];
        params.posIndex = posIndex; % 1-AC, 2-PFC
        BLOCKPATH = blks{blkN};
        temp = string(split(BLOCKPATH, '\'));
        DateStr = temp(end - 1);
        SAVEPATH = fullfile(SAVEPATH , DateStr, activeOrPassive);
        if ~exist(fullfile(SAVEPATH,strcat(posStr(posIndex), '_data.mat')),"file") % check if rawData exist

        [trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH, params);

        % saveData
        mkdir(SAVEPATH);
        save(fullfile(DATAPATH,strcat(posStr(posIndex), '_data.mat')), 'ECOGDataset', 'trialAll', '-mat');
        else
            continue
        end
    end
end
end
