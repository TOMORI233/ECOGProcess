%% Parameter setting
%filterRes.mat : 1-20Hz band pass filter,  filterResHP1Hz
clear; clc; close all;
for pos = 1 : 2
    clearvars -except pos
    posStr = ["LAuC", "LPFC"];
    params.posIndex = pos; % 1-AC, 2-PFC
    posIndex = params.posIndex;
    replotFigure = 0;
    reprocess = 0;
    params.processFcn = @PassiveProcess_clickTrainContinuous;
    fs = 300; % Hz, for downsampling
    flp = 0.1;
    fhp = 150;
    run("loadAllBlocks.m");
    for blks = 1:length(allBlocks)
        clear chMean chStd trials t stimStr S1Duration FDZData
        disp(strcat('processing...(', num2str((pos - 1) * length(allBlocks) + blks), '/', num2str(2 * length(allBlocks)), ')'));

        %% Processing
        BLOCKPATH = allBlocks{blks};
        if isempty(BLOCKPATH)
            continue
        end
        run('setParamsByBlock.m');
        params.Paradigm = Paradigm;
        DATAPATH = strcat(replace(BLOCKPATH, 'E:\ECoG', 'E:\ECoG\matData'), '_', Paradigm) ;
        if ~exist(fullfile(DATAPATH,strcat(posStr(posIndex), '_filterResHP0o1Hz.mat')),"file") || reprocess

            if ~exist(fullfile(DATAPATH,strcat(posStr(posIndex), '_rawData.mat')),"file") % check if rawData exist
                [trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH, params);
%                 trialAll([trialAll.stdOrdr] == 0) = [];
                mkdir(DATAPATH);
                save(fullfile(DATAPATH,strcat(posStr(posIndex), '_rawData.mat')), 'ECOGDataset', 'trialAll', '-mat');
            else
                load(fullfile(DATAPATH,strcat(posStr(posIndex), '_rawData.mat')));

            end

            if ~isempty(ECOGDataset)
                fs0 = ECOGDataset.fs;
            end

            %% Data saving params
            temp = string(split(BLOCKPATH, '\'));
            DateStr = temp(end - 1);
            AREANAME = {'AC', 'PFC', 'ratAC'};
            ROOTPATH = fullfile('E:\ECoG\ECoGClickTrainContinuous',DateStr,Paradigm);
            
            %% delete first sound
            trialAll(1) = [];
            %% ECoG Result
            devType = unique([trialAll.devOrdr]);
            winStart = -2000;
            if contains(Paradigm, 'offsetScreen')
                window = [winStart 7000];
            elseif contains(Paradigm, 'ratioDetect') || contains(Paradigm, 'ICIBind')
                window = [winStart 2500];
            else
                window = [winStart 11000];
            end

            ECOGFDZ = mResample(ECOGDataset, trialAll, window, "trial onset", 300, flp, fhp);% filtered, dowmsampled, zoomed

            for dIndex = 1:length(devType)
                tIndex = [trialAll.devOrdr] == devType(dIndex);
                trials{dIndex} = trialAll(tIndex);
                FDZData{dIndex} = ECOGFDZ.data(tIndex);
                %             [~, chMean{dIndex}, chStd] = selectEcog(ECOGDataset, trials{dIndex}, "trial onset", window);
                chMean{dIndex} = cell2mat(cellfun(@mean , changeCellRowNum(FDZData{dIndex}), 'UniformOutput', false));
                chStd{dIndex} = cell2mat(cellfun(@(x) std(x)/sqrt(length(tIndex)), changeCellRowNum(FDZData{dIndex}), 'UniformOutput', false));
                t{dIndex} = (1:size(chMean{dIndex},2)) * 1000 / fs - S1Duration(dIndex) + winStart;

            end

            % save result data
            filterRes = struct('chMean', chMean, 'chStd', chStd, 'trials', trials, 't', t, 'stimStr', stimStr, 'S1Duration', num2cell(S1Duration), 'FDZData', FDZData, 'fs', num2cell(ones(1, length(devType)) * fs), 'fs0', num2cell(ones(1, length(devType)) * fs0));
            save(fullfile(DATAPATH,strcat(posStr(posIndex), '_filterResHP0o1Hz.mat')), 'filterRes', '-mat');
        end
        %%
        close all;
    end
end

