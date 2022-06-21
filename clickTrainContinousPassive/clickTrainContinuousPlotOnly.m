%% Parameter setting
clear; clc; close all;
for pos = 1 : 2
    clearvars -except pos
    posStr = ["LAuC", "LPFC"];
    params.posIndex = pos; % 1-AC, 2-PFC
    posIndex = params.posIndex;
    replotFigure = 0;
    fs = 500;
    run("loadAllBlocks.m");
    for blks = 1:length(allBlocks)
        %% Processing
        BLOCKPATH = allBlocks{blks};
        temp = TDTbin2mat(BLOCKPATH,'T2',0.1);
        fs0 = temp.streams.(posStr(posIndex)).fs;
        run('setParamsByBlock.m');
        DATAPATH = strcat(replace(BLOCKPATH, 'E:\ECoG', 'E:\ECoG\matData'), '_', Paradigm) ;

        %% Data saving params
        temp = string(split(BLOCKPATH, '\'));
        DateStr = temp(end - 1);
        AREANAME = {'AC', 'PFC', 'ratAC'};
        ROOTPATH = fullfile('E:\ECoG\ECoGClickTrainContinuous',DateStr,Paradigm);


        %% ICA
        % load ICA
        devPath = fullfile(ROOTPATH,'ICAReulst');
        window = [0, 11000]; %=
        topoSize = [8, 8];
        if ~exist(devPath,"dir") || replotFigure
        load(fullfile(DATAPATH,strcat(posStr(posIndex), '_ICAdata.mat')));
        
        Fig1 = plotTopo(comp, topoSize);

        % load result data
        load(fullfile(DATAPATH,strcat(posStr(posIndex), '_ICARes.mat')));
        for dIndex = 1:length(ICARes)
            FigDev_Wave(dIndex) = plotRawWave(ICARes(dIndex).chMean, [], window - S1Duration(dIndex), ['IC, stiTyme: ', num2str(ICARes(dIndex).stimStr), '(N=', num2str(length(ICARes(dIndex).trials)), ')']);
            drawnow;
            FigDev_TFA(dIndex) = plotTFA(ICARes(dIndex).chMean, fs0, fs, window - S1Duration(dIndex), ['IC, stiTyme: ', num2str(ICARes(dIndex).stimStr), '(N=', num2str(length(ICARes(dIndex).trials)), ') ']);
            drawnow
        end

        
            mkdir(devPath)
        
        scaleAxes(FigDev_Wave, "y", [-10, 10]);

        %saveFigures
        saveas(Fig1,strcat(devPath, '\',  AREANAME{posIndex}, '_icaTopo.jpg'));
        for figN = 1 : length(FigDev_Wave)
            saveas(FigDev_Wave(figN),strcat(fullfile(devPath,ICARes(figN).stimStr), '_',  AREANAME{posIndex}, '_Waveform.jpg'));
            saveas(FigDev_TFA(figN),strcat(fullfile(devPath,ICARes(figN).stimStr), '_',  AREANAME{posIndex}, '_TimeFrequency.jpg'));
        end
        end

        %% ECoG Result
        
        devPath2 = fullfile(ROOTPATH,'rawDataResult');
        if ~exist(devPath,"dir") || replotFigure
        window = [0, 11000]; %=
        load(fullfile(DATAPATH,strcat(posStr(posIndex), '_RawRes.mat')));
        for dIndex = 1:length(RawRes)
            FigDev_Wave2(dIndex) = plotRawWave(RawRes(dIndex).chMean, [], window - S1Duration(dIndex), ['IC, stiTyme: ', num2str(RawRes(dIndex).stimStr), '(N=', num2str(length(RawRes(dIndex).trials)), ')']);
            drawnow;
            FigDev_TFA2(dIndex) = plotTFA(RawRes(dIndex).chMean, fs0, fs, window - S1Duration(dIndex), ['IC, stiTyme: ', num2str(RawRes(dIndex).stimStr), '(N=', num2str(length(RawRes(dIndex).trials)), ') ']);
            drawnow
        end
        %saveFigures
        
            mkdir(devPath2)
        
        % Scale
        scaleAxes(FigDev_Wave2, "y", [-80, 80]);
        scaleAxes(FigDev_TFA2, "c", [], [0, 20]);
        % Layout
        plotLayout(FigDev_Wave2, posIndex);

        for figN = 1 : length(FigDev_Wave2)
            saveas(FigDev_Wave2(figN),strcat(fullfile(devPath2,RawRes(figN).stimStr), '_',  AREANAME{posIndex}, '_Waveform.jpg'));
            saveas(FigDev_TFA2(figN),strcat(fullfile(devPath2,RawRes(figN).stimStr), '_',  AREANAME{posIndex}, '_TimeFrequency.jpg'));
        end
        end



        %%
        close all;
    end
end

