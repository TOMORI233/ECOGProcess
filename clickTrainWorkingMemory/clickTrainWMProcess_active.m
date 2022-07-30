clear; clc; close all;
%% Parameter setting
blksActive = {'E:\ECoG\chouchou\cc20220531\Block-1';...
    'E:\ECoG\chouchou\cc20220602\Block-1';...
    'E:\ECoG\chouchou\cc20220604\Block-1';...
    'E:\ECoG\chouchou\cc20220605\Block-3';...
    'E:\ECoG\chouchou\cc20220607\Block-1';...
    'E:\ECoG\chouchou\cc20220701\Block-2';...
    'E:\ECoG\xiaoxiao\xx20220709\Block-2';...
    'E:\ECoG\xiaoxiao\xx20220705\Block-2';...
    %     'E:\ECoG\xiaoxiao\xx20220701\Block-2';...
    'E:\ECoG\xiaoxiao\xx20220630\Block-2';...
    'E:\ECoG\xiaoxiao\xx20220629\Block-2';...
%     'E:\ECoG\xiaoxiao\xx20220628\Block-2';...
    'E:\ECoG\xiaoxiao\xx20220627\Block-2';...

    };
% blksActive = {'E:\ECoG\chouchou\cc20220604\Block-1'};

for blkN = 1 : length(blksActive)
    for posIndex = 1 : 2
        clearvars -except posIndex blksActive blkN SAVEPATH
        SAVEPATH = 'E:\ECoG\matData\CC\ClickTrainOddCompare';
        posStr = ["LAuC", "LPFC"];
        replotFigure = 0;
        reprocess = 0;
        params.posIndex = posIndex; % 1-AC, 2-PFC
        params.choiceWin = [100, 800];
        params.processFcn = @ActiveProcess_clickTrainWM;
        fs = 500; % Hz, for downsampling

        %% Processing
        activeOrPassive = 'Active';
        BLOCKPATH = blksActive{blkN};
        temp = string(split(BLOCKPATH, '\'));
        DateStr = temp(end - 1);
        AREANAME = {'AC', 'PFC'};
        Paradigm = 'ClickTrainOddCompareActive';
        SAVEPATH = fullfile(SAVEPATH , DateStr, activeOrPassive);


        if ~exist(fullfile(SAVEPATH,strcat(posStr(posIndex), '_rawData.mat')),"file") % check if rawData exist
            [trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH, params);
            if contains(BLOCKPATH, 'cc20220604\Block-1')
                trialAll([121, 259]) = [];
            end
            mkdir(SAVEPATH);
            save(fullfile(SAVEPATH,strcat(posStr(posIndex), '_rawData.mat')), 'ECOGDataset', 'trialAll', '-mat');
        elseif  replotFigure || reprocess
            load(fullfile(SAVEPATH,strcat(posStr(posIndex), '_rawData.mat')));
        else
            continue
        end


        if ~isempty(ECOGDataset)
            fs0 = ECOGDataset.fs;
        end

        %% Data saving params


        ROOTPATH = fullfile('E:\ECoG\ECoGBehaviorResult',Paradigm,DateStr);
        soundDuration = 200; % ms

        %% title & labels
        % pairStr = {'4-4.06RC','4-4.06RD','4-4.06IC','4-4.06ID','4-4.06InC','4-4.06InD','40-40.6RC','40-40.6RD','Tone-C','Tone-D'};
        pairStr = {'4-4.06RC','4-4.06RD','4-4.06IC','4-4.06ID','FuzaTone-C','FuzaTone-D'};
        typeStr = {'4-4.06Regular','4-4.06Irregular','ComplexTone'};
        posStr = ["LAuC", "LPFC"];


        %% Behavior processing

        trialAll = trialAll(2:end);
        trialsNoInterrupt = trialAll([trialAll.interrupt] == false);
        ISI = fix(mean(cellfun(@(x, y) (x(end) - x(1)) / y, {trialsNoInterrupt.soundOnsetSeq}, {trialsNoInterrupt.stdNum})));
        diffPairs = [[trialsNoInterrupt.stdOrdr]' [trialsNoInterrupt.devOrdr]'];
        diffPairsUnique = unique(diffPairs, 'rows');
        stdType = unique(diffPairsUnique(:,1));
        devType = unique(diffPairsUnique(:,2));

        %% Plot behavior result
        trials = trialsNoInterrupt;
        [FigBehavior, mAxe] = plotClickTrainWMBehaviorOnly(trials, "k", {'control', 'dev'},pairStr);
        % saveFigures
        behavPath = fullfile(ROOTPATH,'behaviorResult');
        if ~exist(behavPath,"dir")
            mkdir(behavPath)
        end
        saveas(FigBehavior,strcat(behavPath, '_',  AREANAME{posIndex}, 'behavResult.jpg'));

        %% Prediction
        window = [-2500, 6000]; % ms
        for sIndex = 1 : length(stdType)
            trials = trialAll([trialAll.stdOrdr] == stdType(sIndex) & [trialAll.interrupt] == false);
            [~, chMean{sIndex}, chStd{sIndex}] = joinSTD(trials, ECOGDataset, window);
            FigPWave(sIndex) = plotRawWave(chMean{sIndex}, chStd{sIndex}, window, ['stiTyme: ', num2str(typeStr{sIndex}), '(N=', num2str(length(trials)), ')']);
            drawnow;
            FigPTF(sIndex) = plotTFA(double(chMean{sIndex}), fs0, fs, window, ['stiTyme: ', num2str(typeStr{sIndex}), '(N=', num2str(length(trials)), ')']);
            drawnow;
        end

        % save prediction data
        save(fullfile(SAVEPATH,strcat(posStr(posIndex), '_predictionData.mat')), 'trials','typeStr', 'pairStr', 'chMean', 'chStd', 'fs', 'fs0', 'window', 'stdType');


        scaleAxes(FigPWave, "y", [-60, 60]);
        scaleAxes(FigPTF, "c", [], [0, 20]);

        % Layout
        plotLayout(FigPWave, posIndex);

        % saveFigures
        predictPath = fullfile(ROOTPATH,'predictionResponse',  AREANAME{posIndex});
        if ~exist(predictPath,"dir")
            mkdir(predictPath)
        end
        for figN = 1 : length(FigPWave)
            saveas(FigPWave(figN),strcat(fullfile(predictPath,typeStr{figN}), '_Waveform.jpg'));
            saveas(FigPTF(figN),strcat(fullfile(predictPath,typeStr{figN}), '_TimeFrequency.jpg'));
        end

        %%
        close(FigPWave, FigPTF);
        %% deivant response
        window = [-2000, 2000]; % ms

        for dIndex = 1:length(devType)
            trials = trialAll([trialAll.devOrdr] == devType(dIndex) & [trialAll.interrupt] == false & [trialAll.correct] == true);
            if isempty(trials)
                FigDev1(dIndex) = figure('Visible','off');
                FigDev2(dIndex) = figure('Visible','off');
                continue
            end
            [~, chMean{sIndex}, chStd{sIndex}] = selectEcog(ECOGDataset, trials, "dev onset", window);

            FigDev1(dIndex) = plotRawWave(chMean{sIndex}, chStd{sIndex}, window, ['stiTyme: ', num2str(pairStr{dIndex, 1}), '(N=', num2str(length(trials)), ')']);
            drawnow;
            FigDev2(dIndex) = plotTFA(chMean{sIndex}, fs0, fs, window, ['stiTyme: ', num2str(pairStr{dIndex, 1}), '(N=', num2str(length(trials)), ')']);
            drawnow;
        end

        % save deviant data
        save(fullfile(SAVEPATH,strcat(posStr(posIndex), '_deviantData.mat')), 'trials','typeStr', 'pairStr', 'chMean', 'chStd', 'fs', 'fs0', 'window', 'stdType');


        % Scale
        scaleAxes([FigDev1, FigDev2], "x", [-500, 1000]);
        scaleAxes(FigDev1, "y", [-60, 60]);
        scaleAxes(FigDev2, "c", [], [0, 20]);

        % Layout
        plotLayout(FigDev1, posIndex);

        % saveFigures
        devPath = fullfile(ROOTPATH,'deviantResponse',  AREANAME{posIndex});
        if ~exist(devPath,"dir")
            mkdir(devPath)
        end
        for figN = 1 : length(FigDev1)
            saveas(FigDev1(figN),strcat(fullfile(devPath,pairStr{figN}), '_Waveform.jpg'));
            saveas(FigDev2(figN),strcat(fullfile(devPath,pairStr{figN}), '_TimeFrequency.jpg'));
        end

        %%
        close(FigDev1, FigDev2);
        %% Decision making
        window = [-2000, 2000];
        % resultC = [];
        % resultW = [];

        for dIndex = 1 : length(devType)
            resultC{dIndex, 1} = [];
            resultW{dIndex, 1} = [];
            trials = trialAll([trialAll.devOrdr] == devType(dIndex));
            [result, ~, ~] = selectEcog(ECOGDataset, trials, "dev onset", window);
            result = changeCellRowNum(cellfun(@zscore, changeCellRowNum(result), "UniformOutput", false));
            resultC{dIndex, 1} = [resultC{dIndex, 1}; result([trials.correct] == true)];
            resultW{dIndex, 1} = [resultW{dIndex, 1}; result([trials.correct] == false & [trials.interrupt] == false)];
            if length(resultW{dIndex, 1})<0.1*length(trials) || length(resultC{dIndex, 1})<0.1*length(trials)
                FigDM1(dIndex) = figure('Visible','off');
                FigDM2(dIndex) = figure('Visible','off');
                continue
            else
                chMeanStd{dIndex, 1} = cell2mat(cellfun(@mean, changeCellRowNum(resultC{dIndex, 1}), "UniformOutput", false));
                chMeanDev{dIndex, 1} = cell2mat(cellfun(@mean, changeCellRowNum(resultW{dIndex, 1}), "UniformOutput", false));
                FigDM1(dIndex) = plotRawWave(chMeanDev{dIndex, 1} - chMeanStd{dIndex, 1}, [], window, ['C', num2str(length(resultC{dIndex, 1})), 'W', num2str(length(resultW{dIndex, 1}))]);
                drawnow;
                FigDM2(dIndex) = plotTFACompare(chMeanDev{dIndex, 1}, chMeanStd{dIndex, 1}, fs0, fs, window, ['C', num2str(length(resultC{dIndex, 1})), 'W', num2str(length(resultW{dIndex, 1}))]);
                drawnow;
            end
        end

        % save deviant data
        save(fullfile(SAVEPATH,strcat(posStr(posIndex), '_decisionMakingData.mat')), 'trials','typeStr', 'pairStr', 'resultC', 'resultW' ,'chMeanStd', 'chMeanDev', 'chStd', 'fs', 'fs0', 'window', 'stdType');


        % Scale
        scaleAxes([FigDM1, FigDM2], "x", [-1000, 1000]);
        scaleAxes(FigDM1, "y", [], [-60 60]);
        cRange = scaleAxes(FigDM2, "c", []);

        % Layout
        plotLayout(FigDM1, posIndex);

        % saveFigures
        DMPath = fullfile(ROOTPATH,'decisionMaking',  AREANAME{posIndex});
        if ~exist(DMPath,"dir")
            mkdir(DMPath)
        end
        for figN = 1 : length(FigDM1)
            saveas(FigDM1(figN),strcat(fullfile(DMPath,pairStr{figN}), '_Waveform.jpg'));
            saveas(FigDM2(figN),strcat(fullfile(DMPath,pairStr{figN}), '_TimeFrequency.jpg'));
        end

        %%
        close(FigDM1, FigDM2);

        %% MMN
        window = [-2000, 2000];
        dIndex = 2;
        trialsC{dIndex, 1} = trialAll([trialAll.correct] == true & [trialAll.devOrdr] == devType(dIndex));
        trialsW{dIndex, 1} = trialAll([trialAll.correct] == false & [trialAll.interrupt] == false & [trialAll.devOrdr] == devType(dIndex));
        trialsAll{dIndex, 1} = trialAll([trialAll.devOrdr] == devType(dIndex));
        
        [~, chMeanDEVC{dIndex, 1}, ~] = selectEcog(ECOGDataset, trialsC{dIndex, 1}, "dev onset", window);
        [~, chMeanLastSTDC{dIndex, 1}, ~] = selectEcog(ECOGDataset, trialsC{dIndex, 1}, "last std", window);
        [~, chMeanDEVW{dIndex, 1}, ~] = selectEcog(ECOGDataset, trialsW{dIndex, 1}, "dev onset", window);
        [~, chMeanLastSTDW{dIndex, 1}, ~] = selectEcog(ECOGDataset, trialsW{dIndex, 1}, "last std", window);
        [~, chMeanDEV{dIndex, 1}, ~] = selectEcog(ECOGDataset, trialsAll{dIndex, 1}, "dev onset", window);
        [~, chMeanLastSTD{dIndex, 1}, ~] = selectEcog(ECOGDataset, trialsAll{dIndex, 1}, "last std", window);

        MMNData = struct("pairStr", pairStr, "fs", num2cell(ones(length(devType, 1) * fs)), "fs0", num2cell(ones(length(devType, 1) * fs0)), "window", ...
            array2VectorCell(repmat(window, length(devType), 1)), "chMeanDEV", chMeanDEV, "chMeanLastSTD", chMeanLastSTD, "chMeanDEVC", chMeanDEVC, ...
            "chMeanLastSTDC", chMeanLastSTDC, "chMeanDEVW", chMeanDEVW, "chMeanLastSTDW", chMeanLastSTDW, "trialsC", trialsC, "trialsW", trialsW);

        FigMMN1(1) = plotRawWave(chMeanDEV{2}, [], window, "DEV");
        FigMMN1(2) = plotRawWave(chMeanLastSTD{2}, [], window, "last STD");
        FigMMN2(1) = plotTFA(chMeanDEV, fs0, fs, window, "DEV");
        FigMMN2(2) = plotTFA(chMeanDEV, fs0, fs, window, "last STD");


        % save MMN data
        save(fullfile(SAVEPATH,strcat(posStr(posIndex), '_MMNData.mat')), "MMNData");


        scaleAxes([FigMMN1, FigMMN2], "x", [0, 500]);
        scaleAxes(FigMMN1, "y", [], [-60, 60], "max");
        scaleAxes(FigMMN2, "c", [], [-10, 10]);
        % Layout
        plotLayout(FigMMN1, posIndex);

        % saveFigures
        MMNPath = fullfile(ROOTPATH,'MMN',  AREANAME{posIndex});
        if ~exist(MMNPath,"dir")
            mkdir(MMNPath)
        end
        for figN = 1 : length(FigMMN1)
            saveas(FigMMN1(figN),strcat(fullfile(MMNPath,pairStr{figN}), '_Waveform.jpg'));
            saveas(FigMMN2(figN),strcat(fullfile(MMNPath,pairStr{figN}), '_TimeFrequency.jpg'));
        end

        %%
        close(FigMMN1, FigMMN2);

        %% dev V.S. control, push onset
        window = [-2000, 2000];
        dIndex = 2;
        trialsRegD = trialAll([trialAll.stdOrdr] == stdType(1) & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV" & [trialAll.correct]);
        trialsIrregD = trialAll([trialAll.stdOrdr] == stdType(2) & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV" & [trialAll.correct]);
        trialsToneD = trialAll([trialAll.stdOrdr] == stdType(3) & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV" & [trialAll.correct]);




        if isempty(trialsRegD)
            FigDevVSControl1(1) = figure('Visible','off');
            FigDevVSControl2(1) = figure('Visible','off');
            chMeanRegD = [];
        else
            [~, chMeanRegD, ~] = selectEcog(ECOGDataset, trialsRegD, "push onset", window);
            FigDevVSControl1(1) = plotRawWave(chMeanRegD, [], window, "Reg:DEV-push");
            FigDevVSControl2(1) = plotTFA(chMeanRegD, fs0, fs, window, "Reg:DEV-push");
        end

        if isempty(trialsIrregD)
            FigDevVSControl1(2) = figure('Visible','off');
            FigDevVSControl2(2) = figure('Visible','off');
            chMeanIrregD = [];
        else
            [~, chMeanIrregD, ~] = selectEcog(ECOGDataset, trialsIrregD, "push onset", window);
            FigDevVSControl1(2) = plotRawWave(chMeanIrregD, [], window, "Irreg:DEV-push");
            FigDevVSControl2(2) = plotTFA(chMeanIrregD, fs0, fs, window, "Irreg:DEV-push");
        end

        if isempty(trialsToneD)
            FigDevVSControl1(3) = figure('Visible','off');
            FigDevVSControl2(3) = figure('Visible','off');
            chMeanToneD = [];
        else
            [~, chMeanToneD, ~] = selectEcog(ECOGDataset, trialsToneD, "push onset", window);
            FigDevVSControl1(3) = plotRawWave(chMeanToneD, [], window, "FuzaTone:DEV-push");
            FigDevVSControl2(3) = plotTFA(chMeanToneD, fs0, fs, window, "FuzaTone:DEV-push");
        end
        allAxes = findobj(FigDevVSControl1, "Type", "axes");
        yRange = scaleAxes(FigDevVSControl1);
        for aIndex = 1:length(allAxes)
            plot(allAxes(aIndex), [500, 500], yRange, "k--", "LineWidth", 0.6);
        end

        % save dev v.s. control data
        save(fullfile(SAVEPATH,strcat(posStr(posIndex), '_DevControlPush.mat')), 'typeStr', 'pairStr', 'chMeanRegD', 'chMeanIrregD', 'chMeanToneD', 'chStd', 'fs', 'fs0', 'window', 'stdType');


        scaleAxes([FigDevVSControl1, FigDevVSControl2], "x", [-500, 1000]);
        scaleAxes(FigDevVSControl1, "y", [], [-80, 80], "max");
        scaleAxes(FigDevVSControl2, "c", [], [-10, 10]);
        % Layout
        plotLayout(FigDevVSControl1, posIndex);

        % saveFigures
        devControlPath = fullfile(ROOTPATH,'Dev-Control push onset',  AREANAME{posIndex});
        if ~exist(devControlPath,"dir")
            mkdir(devControlPath)
        end
        for figN = 1 : length(FigDevVSControl1)
            saveas(FigDevVSControl1(figN),strcat(fullfile(devControlPath,typeStr{figN}), '_Waveform.jpg'));
            saveas(FigDevVSControl2(figN),strcat(fullfile(devControlPath,typeStr{figN}), '_TimeFrequency.jpg'));
        end

        %%
        clear   chMeanRegD      chMeanIrregD    chMeanToneD
        close(FigDevVSControl1, FigDevVSControl2);
        %% dev V.S. control, dev onset
        window = [-2000, 2000];
        trialsRegC = trialAll([trialAll.stdOrdr] == stdType(1) & [trialAll.interrupt] == false & [trialAll.oddballType] == "STD" );
        trialsIrregC = trialAll([trialAll.stdOrdr] == stdType(2) & [trialAll.interrupt] == false & [trialAll.oddballType] == "STD");
        trialsToneC = trialAll([trialAll.stdOrdr] == stdType(3) & [trialAll.interrupt] == false & [trialAll.oddballType] == "STD");

        trialsRegD = trialAll([trialAll.stdOrdr] == stdType(1) & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV" );
        trialsIrregD = trialAll([trialAll.stdOrdr] == stdType(2) & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV");
        trialsToneD = trialAll([trialAll.stdOrdr] == stdType(3) & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV");




        if isempty(trialsRegC) || isempty(trialsRegD)
            FigDevVSControl1(1) = figure('Visible','off');
            FigDevVSControl = figure('Visible','off');
            FigDevVSControl2(1) = figure('Visible','off');
        else
            [~, chMeanRegC, ~] = selectEcog(ECOGDataset, trialsRegC, "dev onset", window);
            [~, chMeanRegD, ~] = selectEcog(ECOGDataset, trialsRegD, "dev onset", window);
            FigDevVSControl1(1) = plotRawWave(chMeanRegD - chMeanRegC, [], window, "Reg:DEV-Control");
            FigDevVSControl = plotRawWave(chMeanRegD - chMeanRegC, [], window);
            FigDevVSControl2(1) = plotTFACompare(chMeanRegD, chMeanRegC, fs0, fs, window, "Reg:DEV-Control");
        end

        if isempty(trialsIrregC) || isempty(trialsIrregD)
            FigDevVSControl1(2) = figure('Visible','off');
            FigDevVSControl2(2) = figure('Visible','off');
        else
            [~, chMeanIrregC, ~] = selectEcog(ECOGDataset, trialsIrregC, "dev onset", window);
            [~, chMeanIrregD, ~] = selectEcog(ECOGDataset, trialsIrregD, "dev onset", window);
            FigDevVSControl1(2) = plotRawWave(chMeanIrregD - chMeanIrregC, [], window, "Irreg:DEV-Control");
            FigDevVSControl = plotRawWave2(FigDevVSControl, chMeanIrregD - chMeanIrregC, [], window, "b");
            FigDevVSControl2(2) = plotTFACompare(chMeanIrregD, chMeanIrregC, fs0, fs, window, "Irreg:DEV-Control");
        end



        if isempty(trialsToneC) || isempty(trialsToneD)
            FigDevVSControl1(3) = figure('Visible','off');
            FigDevVSControl2(3) = figure('Visible','off');
        else
            [~, chMeanToneC, ~] = selectEcog(ECOGDataset, trialsToneC, "dev onset", window);
            [~, chMeanToneD, ~] = selectEcog(ECOGDataset, trialsToneD, "dev onset", window);
            FigDevVSControl1(3) = plotRawWave(chMeanToneD - chMeanToneC, [], window, "FuzaTone:DEV-Control");
            FigDevVSControl = plotRawWave2(FigDevVSControl, chMeanToneD - chMeanToneC, [], window, "k");
            FigDevVSControl2(3) = plotTFACompare(chMeanToneD, chMeanToneC, fs0, fs, window, "FuzaTone:DEV-Control");
        end
        allAxes = findobj(FigDevVSControl1, "Type", "axes");
        yRange = scaleAxes(FigDevVSControl1);
        for aIndex = 1:length(allAxes)
            plot(allAxes(aIndex), [500, 500], yRange, "k--", "LineWidth", 0.6);
        end

        % save dev v.s. control data
        save(fullfile(SAVEPATH,strcat(posStr(posIndex), '_DevControlDevOnset.mat')), 'typeStr', 'pairStr', 'chMeanRegD', 'chMeanRegC', 'chMeanIrregD', 'chMeanIrregC', 'chMeanToneD', 'chMeanToneC', 'chStd', 'fs', 'fs0', 'window', 'stdType');


        scaleAxes([FigDevVSControl1, FigDevVSControl2, FigDevVSControl], "x", [-100, 300]);
        scaleAxes([FigDevVSControl1, FigDevVSControl], "y", [], [-35, 35], "max");
        scaleAxes(FigDevVSControl2, "c", [], [-10, 10]);
        % Layout
        plotLayout(FigDevVSControl1, posIndex);
        plotLayout(FigDevVSControl, posIndex);
        % saveFigures
        devControlPath = fullfile(ROOTPATH,'Dev-Control dev onset',  AREANAME{posIndex});
        if ~exist(devControlPath,"dir")
            mkdir(devControlPath)
        end
        for figN = 1 : length(FigDevVSControl1)
            saveas(FigDevVSControl1(figN),strcat(fullfile(devControlPath,typeStr{figN}), '_Waveform.jpg'));
            saveas(FigDevVSControl2(figN),strcat(fullfile(devControlPath,typeStr{figN}), '_TimeFrequency.jpg'));
        end
        saveas(FigDevVSControl,strcat(fullfile(devControlPath,'compare'), '_WaveformCompare.jpg'));


        %%
        close all;
    end
end