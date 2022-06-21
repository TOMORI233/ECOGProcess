%% Parameter setting
clear; clc; close all;
for pos = 1 : 2
    clearvars -except pos
    posStr = ["LAuC", "LPFC"];
    params.posIndex = pos; % 1-AC, 2-PFC
    posIndex = params.posIndex;
    replotFigure = 0;
    params.processFcn = @PassiveProcess_clickTrainContinuous;
    fs = 500; % Hz, for downsampling
    run("loadAllBlocks.m");
    for blks = 1:length(allBlocks)
        %% Processing
        %     BLOCKPATH = 'E:\ECoG\chouchou\cc20220601\Block-4';
        BLOCKPATH = allBlocks{blks};
        %     BLOCKPATH = 'E:\ECoG\chouchou\cc20220522\Block-1';
        run('setParamsByBlock.m');
        DATAPATH = strcat(replace(BLOCKPATH, 'E:\ECoG', 'E:\ECoG\matData'), '_', Paradigm) ;
        
        if contains(BLOCKPATH,'HQY')
            params.posIndex = 3; % 1-AC, 2-PFC
            posIndex = params.posIndex;
        end
        if ~exist(fullfile(DATAPATH,strcat(posStr(posIndex), '_data.mat')),"file") % check if rawData exist
            [trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH, params);
            mkdir(DATAPATH);
            save(fullfile(DATAPATH,strcat(posStr(posIndex), '_data.mat')), 'ECOGDataset', 'trialAll', '-mat');
        elseif  replotFigure
            load(fullfile(DATAPATH,strcat(posStr(posIndex), '_data.mat')));
        else
            continue
        end

        if ~isempty(ECOGDataset)
            fs0 = ECOGDataset.fs;
        end

       


        %% Data saving params
        temp = string(split(BLOCKPATH, '\'));
        DateStr = temp(end - 1);
        AREANAME = {'AC', 'PFC', 'ratAC'};
        ROOTPATH = fullfile('E:\ECoG\ECoGClickTrainContinuous',DateStr,Paradigm);


        %% ICA

        devType = unique([trialAll.devOrdr]);
        window = [0, 11000]; %=
        topoSize = [8, 8];
        if contains(BLOCKPATH,'HQY')
            topoSize = [4, 2];
            ECOGDatasetCopy = ECOGDataset;
            ECOGDataset.channels = 1:8;
            ECOGDataset.data = ECOGDatasetCopy.data(1:8,:);
        end



        if ~exist(fullfile(DATAPATH,strcat(posStr(posIndex), '_ICAdata.mat')),"file")  % check if exist ICA data
            [comp, trialsECOG] = mICA(ECOGDataset, trialAll, window, "dev onset", fs);
            save(fullfile(DATAPATH,strcat(posStr(posIndex), '_ICAdata.mat')), 'comp', 'trialsECOG', '-mat');
        elseif  replotFigure
            load(fullfile(DATAPATH,strcat(posStr(posIndex), '_ICAdata.mat')));
        end

        devPath = fullfile(ROOTPATH,'ICAReulst');

        Fig1 = plotTopo(comp, topoSize);
        if ~exist(fullfile(DATAPATH,strcat(posStr(posIndex), '_ICARes.mat')),"file")
        for dIndex = 1:length(devType)
            S = cellfun(@(x) comp.unmixing * x, trialsECOG([trialAll.devOrdr] == devType(dIndex)), "UniformOutput", false);
            chMean{dIndex} = cell2mat(cellfun(@mean, changeCellRowNum(S), "UniformOutput", false)) * 1e6;
            trials{dIndex} = trialAll([trialAll.devOrdr] == devType(dIndex));
            t{dIndex} = (1:size(chMean{dIndex},2)) / fs - S1Duration(dIndex);
            if ~exist(devPath,'dir') || replotFigure
                FigDev_Wave(dIndex) = plotRawWave(chMean{dIndex}, [], window - S1Duration(dIndex), ['IC, stiTyme: ', num2str(stimStr{dIndex}), '(N=', num2str(length(trials{dIndex})), ')']);
                drawnow;
                FigDev_TFA(dIndex) = plotTFA(chMean{dIndex}, fs0, fs, window - S1Duration(dIndex), ['IC, stiTyme: ', num2str(stimStr{dIndex}), '(N=', num2str(length(trials{dIndex})), ') ']);
                drawnow;
            end
        end
        % save result data
        ICARes = struct('chMean', chMean, 'trials', trials, 't', t, 'stimStr', stimStr, 'S1Duration', S1Duration);    
            save(fullfile(DATAPATH,strcat(posStr(posIndex), '_ICARes.mat')), 'ICARes', '-mat');
        else
            load(fullfile(DATAPATH,strcat(posStr(posIndex), '_ICARes.mat')));
        end


        if ~exist(devPath,"dir")
            mkdir(devPath)
            % Scale
            scaleAxes(FigDev_Wave, "y", [-10, 10]);
            %     scaleAxes(FigDev_TFA, "c", [], [0, 20]);

            % Layout
%             plotLayout(FigDev_Wave, posIndex);
            %saveFigures
            saveas(Fig1,strcat(devPath, '\',  AREANAME{posIndex}, '_icaTopo.jpg'));
            for figN = 1 : length(FigDev_Wave)
                saveas(FigDev_Wave(figN),strcat(fullfile(devPath,stimStr{figN}), '_',  AREANAME{posIndex}, '_Waveform.jpg'));
                saveas(FigDev_TFA(figN),strcat(fullfile(devPath,stimStr{figN}), '_',  AREANAME{posIndex}, '_TimeFrequency.jpg'));
            end
        end

        %% ECoG Result
        devPath2 = fullfile(ROOTPATH,'rawDataResult');

        devType = unique([trialAll.devOrdr]);
        window = [0, 11000]; %=
        for dIndex = 1:length(devType)

            trials{dIndex} = trialAll([trialAll.devOrdr] == devType(dIndex));
            [~, chMean{dIndex}, chStd] = selectEcog(ECOGDataset, trials{dIndex}, "trial onset", window);
            t{dIndex} = (1:size(chMean{dIndex},2)) / fs - S1Duration(dIndex);
            if ~exist(devPath2,'dir')
                FigDev_Wave2(dIndex) = plotRawWave(chMean{dIndex}, chStd, window - S1Duration(dIndex), ['stiTyme: ', num2str(stimStr{dIndex}), '(N=', num2str(length(trials{dIndex})), ')']);
                drawnow;
                FigDev_TFA2(dIndex) = plotTFA(chMean{dIndex}, fs0, fs, window - S1Duration(dIndex), ['stiTyme: ', num2str(stimStr{dIndex}), '(N=', num2str(length(trials{dIndex})), ') ']);
                drawnow
            end
        end

          % save result data
        RawRes = struct('chMean', chMean, 'trials', trials, 't', t, 'stimStr', stimStr, 'S1Duration', S1Duration);
        if ~exist(fullfile(DATAPATH,strcat(posStr(posIndex), '_RawRes.mat')),"file")
            save(fullfile(DATAPATH,strcat(posStr(posIndex), '_RawRes.mat')), 'RawRes', '-mat');
        else
            load(fullfile(DATAPATH,strcat(posStr(posIndex), '_RawRes.mat')));
        end

        %saveFigures
        if ~exist(devPath2,"dir")
            mkdir(devPath2)
            % Scale
            scaleAxes(FigDev_Wave2, "y", [-80, 80]);
            scaleAxes(FigDev_TFA2, "c", [], [0, 20]);
            % Layout
            plotLayout(FigDev_Wave2, posIndex);

            for figN = 1 : length(FigDev_Wave2)
                saveas(FigDev_Wave2(figN),strcat(fullfile(devPath2,stimStr{figN}), '_',  AREANAME{posIndex}, '_Waveform.jpg'));
                saveas(FigDev_TFA2(figN),strcat(fullfile(devPath2,stimStr{figN}), '_',  AREANAME{posIndex}, '_TimeFrequency.jpg'));
            end
        end


        %%
        close all;
    end
end

