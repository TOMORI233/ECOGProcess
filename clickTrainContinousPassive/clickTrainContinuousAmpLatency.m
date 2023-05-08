%% Parameter setting
clear; clc; close all;
for pos = 1 : 2
    clearvars -except pos
    posStr = ["LAuC", "LPFC"];
    params.posIndex = pos; % 1-AC, 2-PFC
    posIndex = params.posIndex;
    replotFigure = 0;
    fs = 500;
    reprocess = 1;
    run("loadAllBlocks.m");
    for blks = 1:length(allBlocks)
        clear amp latency
        %% Processing
        BLOCKPATH = allBlocks{blks};
        if isempty(BLOCKPATH)
            continue
        end
        run('setParamsByBlock.m');
        DATAPATH = strcat(replace(BLOCKPATH, 'E:\ECoG', 'E:\ECoG\matData'), '_', Paradigm) ;

        if ~exist(fullfile(DATAPATH,strcat(posStr(posIndex), '_ampLatencyRaw.mat')), "file") || reprocess
            load(fullfile(DATAPATH,strcat(posStr(posIndex), '_rawData.mat')));
        else
            continue
        end
        temp = TDTbin2mat(BLOCKPATH,'T2',0.1);
        fs0 = temp.streams.(posStr(posIndex)).fs;
        
        %% Data saving params
        temp = string(split(BLOCKPATH, '\'));
        DateStr = temp(end - 1);
        AREANAME = {'AC', 'PFC'};


        %% ECoG data
        
        devType = unique([trialAll.devOrdr]);
        if contains(Paradigm, 'offsetScreen')
            window = [0 7000]; % ms
        else
            window = [0 11000]; % ms
        end
        selectWin = [0 300]; % ms
        selectWin2 = [-300 0]; % ms
        latencyWin = [0 1000];
        for dIndex = 1:length(devType)
            trialIdx = [trialAll.devOrdr] == devType(dIndex);
            trials{dIndex} = trialAll(trialIdx);
            trialsECOG{dIndex} = selectEcog(ECOGDataset, trials{dIndex}, "trial onset", window);
            % trialsECOG{dIndex} = excludeTrials(trialsECOG{dIndex}, 0.1);
            amp1(trialIdx, 1) = cellfun(@(x) waveAmp(x, selectWin + S1Duration(dIndex), fs0), trialsECOG{dIndex}, 'UniformOutput', false);
            amp2(trialIdx, 1) = cellfun(@(x) waveAmp(x, selectWin2 + S1Duration(dIndex), fs0), trialsECOG{dIndex}, 'UniformOutput', false);
            amp = amp1 - amp2;
            
            latency(trialIdx, 1) = cellfun(@(x) waveLatency(x, latencyWin + S1Duration(dIndex), fs0, 0.5) - S1Duration(dIndex), trialsECOG{dIndex}, 'UniformOutput', false);
        end
        save(fullfile(DATAPATH,strcat(posStr(posIndex), '_ampLatencyRaw.mat')),"latency", "trialAll", "amp", "selectWin");
    end
end

