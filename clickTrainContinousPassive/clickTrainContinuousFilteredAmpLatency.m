%% Parameter setting
clear; clc; close all;
for pos = 1 : 2
    clearvars -except pos
    posStr = ["LAuC", "LPFC"];
    params.posIndex = pos; % 1-AC, 2-PFC
    posIndex = params.posIndex;
    replotFigure = 0;
    fs = 500;
    reprocess = 0;
    run("loadAllBlocks.m");
    for blks = 1:length(allBlocks)
        clear ampFiltered ampRms ampArea ampPeak ampTrough
        disp(strcat('processing...(', num2str((pos - 1) * length(allBlocks) + blks), '/', num2str(2 * length(allBlocks)), ')'));

        %% Processing
        BLOCKPATH = allBlocks{blks};
        if isempty(BLOCKPATH)
            continue
        end
        run('setParamsByBlock.m');
        DATAPATH = strcat(replace(BLOCKPATH, 'E:\ECoG', 'E:\ECoG\matData'), '_', Paradigm) ;

        if ~exist(fullfile(DATAPATH,strcat(posStr(posIndex), '_ampFiltered.mat')), "file") || reprocess
            load(fullfile(DATAPATH,strcat(posStr(posIndex), '_filterResHP1Hz.mat')));
        else
            continue
        end
        if isfield(filterRes, 'amp')
            filterRes = rmfield(filterRes, 'amp');
        end
       %% for validation
       
       fs0Temp = [filterRes.fs0]';
       fsTemp = [filterRes.fs]';
        %% Data saving params
        temp = string(split(BLOCKPATH, '\'));
        DateStr = temp(end - 1);
        AREANAME = {'AC', 'PFC'};


        %% ECoG data
        
       
        if contains(Paradigm, 'offsetScreen')
            window = [0 7000]; % ms
        else
            window = [0 11000]; % ms
        end
        selectWin = [50 200]; % ms
        selectWin1 = [150 400]; % ms
        selectWin2 = [-400 0]; % ms
        latencyWin = [0 1000];
        for dIndex = 1:length(filterRes)
            if filterRes(dIndex).fs0 == 300
                filterRes(dIndex).fs0 = fsTemp(dIndex);
                filterRes(dIndex).fs = fs0Temp(dIndex);
            end
            amp1 = cellfun(@(x) waveAmp(x, selectWin + S1Duration(dIndex), filterRes(dIndex).fs), filterRes(dIndex).FDZData, 'UniformOutput', false);
            amp2 = cellfun(@(x) waveAmp(x, selectWin2 + S1Duration(dIndex), filterRes(dIndex).fs), filterRes(dIndex).FDZData, 'UniformOutput', false);
%             ampRms{dIndex} = cell2mat((amp1 - amp2)');
            ampRms{dIndex} = cell2mat((amp1)');
            amp1 = cellfun(@(x) waveAmp(x, selectWin + S1Duration(dIndex), filterRes(dIndex).fs, 2), filterRes(dIndex).FDZData, 'UniformOutput', false);
            amp2 = cellfun(@(x) waveAmp(x, selectWin2 + S1Duration(dIndex), filterRes(dIndex).fs, 2), filterRes(dIndex).FDZData, 'UniformOutput', false);
%             ampArea{dIndex} = cell2mat((amp1 - amp2)');
            ampArea{dIndex} = cell2mat((amp1)');
            amp1 = cellfun(@(x) waveAmp(x, selectWin1 + S1Duration(dIndex), filterRes(dIndex).fs, 3), filterRes(dIndex).FDZData, 'UniformOutput', false);
            amp2 = cellfun(@(x) waveAmp(x, selectWin2 + S1Duration(dIndex), filterRes(dIndex).fs, 5), filterRes(dIndex).FDZData, 'UniformOutput', false);
            ampPeak{dIndex} = cell2mat((amp1 - amp2)');
            amp1 = cellfun(@(x) waveAmp(x, selectWin + S1Duration(dIndex), filterRes(dIndex).fs, 4), filterRes(dIndex).FDZData, 'UniformOutput', false);
            amp2 = cellfun(@(x) waveAmp(x, selectWin2 + S1Duration(dIndex), filterRes(dIndex).fs, 5), filterRes(dIndex).FDZData, 'UniformOutput', false);
            ampTrough{dIndex} = cell2mat((amp1 - amp2)');
        end
        filterRes = addFieldToStruct(filterRes, [ampRms', ampArea', ampPeak', ampTrough', array2VectorCell(repmat(selectWin, length(filterRes), 1) ), array2VectorCell(repmat(selectWin1, length(filterRes), 1) ), array2VectorCell(repmat(selectWin2, length(filterRes), 1) )], ["ampRMS"; "ampAREA"; "ampPeak"; "ampTrough"; "ampSelWin"; "ampSelWin1"; "ampSelWin2"]);
        save(fullfile(DATAPATH,strcat(posStr(posIndex), '_ampFiltered.mat')), "ampRms", "ampArea", "ampPeak", "ampTrough");
        save(fullfile(DATAPATH,strcat(posStr(posIndex), '_filterResHP1Hz.mat')), "filterRes");
    end
end

