%% Parameter setting
clear; clc; close all;
run("loadAllBlocks.m");

for i = 1 : length(basicRegIrreg)

    posStr = ["LAuC", "LPFC"];
    params.processFcn = @PassiveProcess_clickTrainContinuous;
    blkMerge = struct2cell(basicRegIrreg(i));
    blkMerge(isemptycell(blkMerge)) = [];
    opts.efNames = ["num0", "ordr"];
    opts.abortHeadTail = 0;
    [trialAll, ECOGDatasetRaw, segTimePoint] = ECOGPreprocessJoinBlock(blkMerge, params, opts);
    for pos =  1 : 2
        clearvars -except i basicRegIrreg pos ECOGDatasetRaw segTimePoint trialAll posStr params  posIndex blkMerge
        
        reLoadRawData = 0;
        replotFigure = 0;
        posIndex = pos;
        fs = 500; % Hz, for downsampling
        run("loadAllBlocks.m");

        savePath = strcat('E:\ECoG\matData\chouchou\ClickTrainLongTermMerge\Merge', num2str(i));
        ECOGDataset = ECOGDatasetRaw.(posStr(posIndex));
        if ~isempty(ECOGDataset)
            fs0 = ECOGDataset.fs;
        end

        %% ICA
        devType = unique([trialAll.devOrdr]);
        window = [0, 11000]; %=
        topoSize = [8, 8];
        icaPath = fullfile(savePath, 'icaData');
        
        if ~exist(fullfile(icaPath, strcat(posStr(posIndex), 'icaMergeData.mat')),'file')
            [comp, trialsECOG] = mICA(ECOGDataset, trialAll, window, "dev onset", fs);
            mkdir(icaPath);
            save(fullfile(icaPath, strcat(posStr(posIndex), 'icaMergeData.mat')), 'comp', 'trialsECOG', 'segTimePoint', 'trialAll', 'blkMerge' ,'-v7.3');
        else
            load(fullfile(icaPath, strcat(posStr(posIndex), 'icaMergeData.mat')));
        end
%%
        % topoFig
        FigTopo = plotTopo(comp, topoSize);
        AREANAME = {'AC', 'PFC', 'ratAC'};

        for blk = 1 : length(blkMerge)
            BLOCKPATH = blkMerge{blk};
            run('setParamsByBlock.m');
            paradigmPath = fullfile(savePath,Paradigm);
            figPath = fullfile(paradigmPath, 'figure');
            mkdir(figPath);
            % plot figure
            for dIndex = 1:length(devType)
                S = cellfun(@(x) comp.unmixing * x, trialsECOG([trialAll.devOrdr] == devType(dIndex) & [trialAll.devOnset] > segTimePoint(blk, 1)*1000 & [trialAll.devOnset] < segTimePoint(blk, 2)*1000), "UniformOutput", false);
                chMean{dIndex} = cell2mat(cellfun(@mean, changeCellRowNum(S), "UniformOutput", false)) * 1e6;
                trials{dIndex} = trialAll([trialAll.devOrdr] == devType(dIndex)  & [trialAll.devOnset] > segTimePoint(blk, 1)*1000 & [trialAll.devOnset] < segTimePoint(blk, 2)*1000);
                t{dIndex} = linspace(window(1), window(2), size(chMean{dIndex} , 2));
%                 t{dIndex} = (1:size(chMean{dIndex},2)) * 1000 / fs0 - S1Duration(dIndex);
                if ~exist(figPath,'dir') || replotFigure
                    FigDev_Wave(dIndex) = plotRawWave(chMean{dIndex}, [], window - S1Duration(dIndex), ['IC, stiTyme: ', num2str(stimStr{dIndex}), '(N=', num2str(length(trials{dIndex})), ')']);
                    drawnow;
                    FigDev_TFA(dIndex) = plotTFA(chMean{dIndex}, fs0, fs, window - S1Duration(dIndex), ['IC, stiTyme: ', num2str(stimStr{dIndex}), '(N=', num2str(length(trials{dIndex})), ') ']);
                    drawnow;
                end
            end
            ICARes = struct('chMean', chMean, 'trials', trials, 't', t, 'stimStr', stimStr, 'S1Duration', num2cell(S1Duration'), 'fs0', fs0);    
            save(fullfile(paradigmPath,strcat(posStr(posIndex), '_ICARes.mat')), 'ICARes', '-mat');

            
            % saveFigures
            
            mkdir(figPath);
            scaleAxes(FigDev_Wave, "y", [-10, 10]);
            saveas(FigTopo,strcat(figPath, '\',  AREANAME{posIndex}, '_icaTopo.jpg'));
            for figN = 1 : length(FigDev_Wave)
                saveas(FigDev_Wave(figN),strcat(fullfile(figPath,stimStr{figN}), '_',  AREANAME{posIndex}, '_Waveform.jpg'));
                saveas(FigDev_TFA(figN),strcat(fullfile(figPath,stimStr{figN}), '_',  AREANAME{posIndex}, '_TimeFrequency.jpg'));
            end

            close(FigDev_Wave, FigDev_TFA);

        end
        close(FigTopo)
        %%

    end
end
