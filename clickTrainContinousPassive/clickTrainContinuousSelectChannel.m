function [sigIndex, h, p] = clickTrainContinuousSelectChannel(matFile)
clear; clc; close all;
for id = 1 : 2
    for pos = 1 : 2
        clearvars -except pos id sigIndex
        monkeyId = ["chouchou", "xiaoxiao"];
        posStr = ["LAuC", "LPFC"];
        params.posIndex = pos; % 1-AC, 2-PFC
        posIndex = params.posIndex;
        replotFigure = 0;
        fs = 500;
        run("loadAllBlocks.m");
        tempBlock = RegIrreg4msBlk(contains(RegIrreg4msBlk, monkeyId(id)));
        clear amp amp1 amp2
        amp1 = [];
        amp2 = [];
        for blks = 1:length(tempBlock)
            %% Processing
            BLOCKPATH = tempBlock{blks};
            temp = TDTbin2mat(BLOCKPATH,'T2',0.1);
            fs0 = temp.streams.(posStr(posIndex)).fs;
            run('setParamsByBlock.m');
            DATAPATH = strcat(replace(BLOCKPATH, 'E:\ECoG', 'E:\ECoG\matData'), '_', Paradigm) ;

            %% Data saving params
            temp = string(split(BLOCKPATH, '\'));
            DateStr = temp(end - 1);
            AREANAME = {'AC', 'PFC'};


            %% ECoG data
            load(fullfile(DATAPATH,strcat(posStr(posIndex), matFile)));
            devType = unique([trialAll.devOrdr]);
            if contains(Paradigm, 'offsetScreen')
                window = [3000 5000]; % ms
            else
                window = [4000 6000]; % ms
            end

            if pos == 1   % AC
                selectWin1 = [0 300]; % ms
                selectWin2 = [-300 0]; % ms
            elseif pos == 2
                selectWin1 = [0 200]; % ms
                selectWin2 = [-200 0]; % ms
            end

            trials = trialAll([trialAll.devOrdr] == devType(1));
            trialsECOG = selectEcog(ECOGDataset, trials, "trial onset", window);
            trialsECOG = excludeTrials(trialsECOG, 0.1);
            
            % to determine if response is evoked at change detection
            amp1 = [amp1 cell2mat(cellfun(@(x) waveAmp(x, selectWin1 + S1Duration(1) - window(1), fs0), trialsECOG, 'UniformOutput', false)')];
            amp2 = [amp2 cell2mat(cellfun(@(x) waveAmp(x, selectWin2 + S1Duration(1) - window(1), fs0), trialsECOG, 'UniformOutput', false)')];

        end
        amp = array2VectorCell([array2VectorCell(amp1) array2VectorCell(amp2)]);
        % to determine if response is evoked at change detection
        [h, p] = cellfun(@(x) ttest(x{1}, x{2}), amp, 'UniformOutput', false);

        % to detect if the channel is not bad according to resting activity 
        ampRest = changeCellRowNum(array2VectorCell(amp2));
        [~, chIdx] = excludeTrials(ampRest, 0.1);
        sigIndex.(monkeyId(id)).(posStr(posIndex)) = find((cell2mat(h) == 1 & chIdx));
    end
end
