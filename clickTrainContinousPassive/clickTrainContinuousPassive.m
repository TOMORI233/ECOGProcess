%% Parameter setting
clear; clc; close all;
for pos = 1 : 2
    clearvars -except pos
    posStr = ["LAuC", "LPFC"];
    params.posIndex = pos; % 1-AC, 2-PFC
    posIndex = params.posIndex;
    toPlot = 0;
    replotFigure = 0;
    reprocess = 0;
    params.processFcn = @PassiveProcess_clickTrainContinuous;
    fs = 500; % Hz, for downsampling
    run("loadAllBlocks.m");
    for blks = 1:length(allBlocks)
        clear chMean trials t stimStr S1Duration FigDev_Wave FigDev_Wave2 FigDev_TFA FigDev_TFA2 FigReCon_Wave FigReCon_TFA
        disp(strcat('processing...(', num2str((pos - 1) * length(allBlocks) + blks), '/', num2str(2 * length(allBlocks)), ')'));

        %% Processing
        %     BLOCKPATH = 'E:\ECoG\chouchou\cc20220601\Block-4';
        BLOCKPATH = allBlocks{blks};
        %     BLOCKPATH = 'E:\ECoG\chouchou\cc20220522\Block-1';
        if isempty(BLOCKPATH)
            continue
        end
        run('setParamsByBlock.m');
        params.Paradigm = Paradigm;
        DATAPATH = strcat(replace(BLOCKPATH, 'E:\ECoG', 'E:\ECoG\matData'), '_', Paradigm) ;


        if ~exist(fullfile(DATAPATH,strcat(posStr(posIndex), '_rawData.mat')),"file") % check if rawData exist
            [trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH, params);

            mkdir(DATAPATH);
            save(fullfile(DATAPATH,strcat(posStr(posIndex), '_rawData.mat')), 'ECOGDataset', 'trialAll', '-mat');
        elseif  replotFigure || reprocess
            load(fullfile(DATAPATH,strcat(posStr(posIndex), '_rawData.mat')));
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
        if contains(Paradigm, 'offsetScreen')
            window = [0 7000];
        else
            window = [0 11000];
        end

        topoSize = [8, 8];

        [trialsECOG, ~, ~] = selectEcog(ECOGDataset, trialAll, "trial onset", window);
        if ~exist(fullfile(DATAPATH,strcat(posStr(posIndex), '_ICAdata.mat')),"file")  % check if exist ICA data
            comp = mICA(ECOGDataset, trialAll(1:40), window, "dev onset", fs);
            save(fullfile(DATAPATH,strcat(posStr(posIndex), '_ICAdata.mat')), 'comp', '-mat');
        elseif  replotFigure || reprocess
            load(fullfile(DATAPATH,strcat(posStr(posIndex), '_ICAdata.mat')));
        end

        devPath = fullfile(ROOTPATH,'ICAReulst');

        Fig1 = plotTopo(comp, topoSize, topoSize);


        if ~exist(fullfile(DATAPATH,strcat(posStr(posIndex), '_ICARes.mat')),"file") || reprocess
            for dIndex = 1:length(devType)

                S = cellfun(@(x) comp.unmixing * x, trialsECOG([trialAll.devOrdr] == devType(dIndex)), "UniformOutput", false);
                chMean{dIndex} = cell2mat(cellfun(@mean, changeCellRowNum(S), "UniformOutput", false));
                trials{dIndex} = trialAll([trialAll.devOrdr] == devType(dIndex));
                t{dIndex} = (1:size(chMean{dIndex},2)) * 1000 / fs0 - S1Duration(dIndex);
                if ~exist(devPath,'dir') || replotFigure
                    FigDev_Wave(dIndex) = plotRawWave(chMean{dIndex}, [], window - S1Duration(dIndex), ['IC, stiTyme: ', num2str(stimStr{dIndex}), '(N=', num2str(length(trials{dIndex})), ')']);
                    drawnow;
                    FigDev_TFA(dIndex) = plotTFA(chMean{dIndex}, fs0, fs, window - S1Duration(dIndex), ['IC, stiTyme: ', num2str(stimStr{dIndex}), '(N=', num2str(length(trials{dIndex})), ') ']);
                    drawnow;
                end
            end
            % save result data
            ICARes = struct('chMean', chMean, 'trials', trials, 't', t, 'stimStr', stimStr, 'S1Duration', num2cell(S1Duration));
            save(fullfile(DATAPATH,strcat(posStr(posIndex), '_ICARes.mat')), 'ICARes', '-mat');
        else
            load(fullfile(DATAPATH,strcat(posStr(posIndex), '_ICARes.mat')));
        end



        if ~exist(devPath,"dir")  || replotFigure
            mkdir(devPath)
            % Scale
            scaleAxes(FigDev_Wave, "y", []);
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
        clear chMean

        %% ICA Reconstruct result
        devType = unique([trialAll.devOrdr]);
        if contains(Paradigm, 'offsetScreen')
            window = [0 7000];
        else
            window = [0 11000];
        end
        reConPath = fullfile(ROOTPATH,'ICAReconReulst');
        load(fullfile(DATAPATH,strcat(posStr(posIndex), '_ICARes.mat')));
        [trialsECOG, ~, ~] = selectEcog(ECOGDataset, trialAll, "trial onset", window);
        

        % test
        dIndex = 1;
        t1 = 0 + S1Duration(dIndex);
        t2 = t1 + 300;
        S2 = cellfun(@(x)  comp.unmixing * x, trialsECOG([trialAll.devOrdr] == devType(dIndex)), "UniformOutput", false);
        comp.trial = S2;
        comp.fsample = size(S2{1}, 2) * 1000 / diff(window);
        [comp0, ICs] = selectIC(comp, window, t1, t2);
%         chMean{dIndex} = cell2mat(cellfun(@mean, changeCellRowNum(comp0.trial), "UniformOutput", false));
%         trials{dIndex} = trialAll([trialAll.devOrdr] == devType(dIndex));
%         t{dIndex} = (1:size(chMean{dIndex},2)) * 1000 / fs0 - S1Duration(dIndex);
%         ICAFig = plotRawWave(chMean{dIndex}, [], window - S1Duration(dIndex), ['IC, stiTyme: ', num2str(stimStr{dIndex}), '(N=', num2str(length(trials{dIndex})), ')']);
%         scaleAxes(ICAFig, 'x', [t1 t2]);

        % reconstruct
        comp2 = reconstructData(comp, ICs);

%         % test
        dIndex = 1;
        S2 = cellfun(@(x) comp2.topo * comp.unmixing * x, trialsECOG([trialAll.devOrdr] == devType(dIndex)), "UniformOutput", false);
        chMean{dIndex} = cell2mat(cellfun(@mean, changeCellRowNum(S2), "UniformOutput", false));
        trials{dIndex} = trialAll([trialAll.devOrdr] == devType(dIndex));
        t{dIndex} = (1:size(chMean{dIndex},2)) * 1000 / fs0 - S1Duration(dIndex);
        plotRawWave(chMean{dIndex}, [], window - S1Duration(dIndex), ['IC, stiTyme: ', num2str(stimStr{dIndex}), '(N=', num2str(length(trials{dIndex})), ')']);
        

        %
        if ~exist(fullfile(DATAPATH,strcat(posStr(posIndex), '_ICAReconRes.mat')),"file") || reprocess
            for dIndex = 1:length(devType)
                S2 = cellfun(@(x) comp2.topo * comp.unmixing * x, trialsECOG([trialAll.devOrdr] == devType(dIndex)), "UniformOutput", false);
                chMean{dIndex} = cell2mat(cellfun(@mean, changeCellRowNum(S2), "UniformOutput", false));
                trials{dIndex} = trialAll([trialAll.devOrdr] == devType(dIndex));
                t{dIndex} = (1:size(chMean{dIndex},2)) * 1000 / fs0 - S1Duration(dIndex);
                if ~exist(reConPath,'dir') || replotFigure
                    FigReCon_Wave(dIndex) = plotRawWave(chMean{dIndex}, [], window - S1Duration(dIndex), ['IC, stiTyme: ', num2str(stimStr{dIndex}), '(N=', num2str(length(trials{dIndex})), ')']);
                    drawnow;
                    FigReCon_TFA(dIndex) = plotTFA(chMean{dIndex}, fs0, fs, window - S1Duration(dIndex), ['IC, stiTyme: ', num2str(stimStr{dIndex}), '(N=', num2str(length(trials{dIndex})), ') ']);
                    drawnow;
                end
            end
            % save result data
            ICAReconRes = struct('chMean', chMean, 'trials', trials, 't', t, 'stimStr', stimStr, 'S1Duration', num2cell(S1Duration));
            save(fullfile(DATAPATH,strcat(posStr(posIndex), '_ICAReconRes.mat')), 'ICAReconRes', 'comp2', '-mat');
        else
            load(fullfile(DATAPATH,strcat(posStr(posIndex), '_ICAReconRes.mat')));
        end
        clear chMean
        if ~exist(reConPath,"dir")  || replotFigure
            mkdir(reConPath)
            % Scale
            scaleAxes(FigReCon_Wave, "y", []);
            %     scaleAxes(FigDev_TFA, "c", [], [0, 20]);
            saveas(Fig1,strcat(reConPath, '\',  AREANAME{posIndex}, '_icaTopo.jpg'));
            for figN = 1 : length(FigReCon_Wave)
                saveas(FigReCon_Wave(figN),strcat(fullfile(reConPath,stimStr{figN}), '_',  AREANAME{posIndex}, '_Waveform.jpg'));
                saveas(FigReCon_TFA(figN),strcat(fullfile(reConPath,stimStr{figN}), '_',  AREANAME{posIndex}, '_TimeFrequency.jpg'));
            end
        end

        %% ECoG Result
        clear('comp', 'trialsECOG');
        devPath2 = fullfile(ROOTPATH,'rawDataResult');

        devType = unique([trialAll.devOrdr]);
        if contains(Paradigm, 'offsetScreen')
            window = [0 7000];
        else
            window = [0 11000];
        end
        for dIndex = 1:length(devType)

            trials{dIndex} = trialAll([trialAll.devOrdr] == devType(dIndex));
            [~, chMean{dIndex}, chStd] = selectEcog(ECOGDataset, trials{dIndex}, "trial onset", window);
            t{dIndex} = (1:size(chMean{dIndex},2)) * 1000 / fs0 - S1Duration(dIndex);
            if ~exist(devPath2,'dir')  || replotFigure
                FigDev_Wave2(dIndex) = plotRawWave(chMean{dIndex}, chStd, window - S1Duration(dIndex), ['stiTyme: ', num2str(stimStr{dIndex}), '(N=', num2str(length(trials{dIndex})), ')']);
                drawnow;
                FigDev_TFA2(dIndex) = plotTFA(chMean{dIndex}, fs0, fs, window - S1Duration(dIndex), ['stiTyme: ', num2str(stimStr{dIndex}), '(N=', num2str(length(trials{dIndex})), ') ']);
                drawnow
            end
        end

        % save result data
        RawRes = struct('chMean', chMean, 'trials', trials, 't', t, 'stimStr', stimStr, 'S1Duration', num2cell(S1Duration));
        if ~exist(fullfile(DATAPATH,strcat(posStr(posIndex), '_RawRes.mat')),"file") || reprocess
            save(fullfile(DATAPATH,strcat(posStr(posIndex), '_RawRes.mat')), 'RawRes', '-mat');
        else
            load(fullfile(DATAPATH,strcat(posStr(posIndex), '_RawRes.mat')));
        end

        %saveFigures
        if ~exist(devPath2,"dir") || replotFigure
            mkdir(devPath2)
            % Scale
            scaleAxes(FigDev_Wave2, "y", [-80, 80]);
            scaleAxes(FigDev_TFA2, "c", [], [0, 20]);
            % Layout
            if contains(BLOCKPATH, 'cc')
                plotLayout(FigDev_Wave2, posIndex);
            else
                plotLayout(FigDev_Wave2, posIndex + 2);
            end

            for figN = 1 : length(FigDev_Wave2)
                saveas(FigDev_Wave2(figN),strcat(fullfile(devPath2,stimStr{figN}), '_',  AREANAME{posIndex}, '_Waveform.jpg'));
                saveas(FigDev_TFA2(figN),strcat(fullfile(devPath2,stimStr{figN}), '_',  AREANAME{posIndex}, '_TimeFrequency.jpg'));
            end
        end


        %%
        close all;
    end
end

