clear; clc; close all;
%% Parameter setting
blksActive = {...
    'E:\ECoG\xiaoxiao\xx20220730\Block-1';...
    'E:\ECoG\xiaoxiao\xx20220801\Block-1';...
    'E:\ECoG\xiaoxiao\xx20220804\Block-1';...
    'E:\ECoG\chouchou\cc20220804\Block-1';...
    'E:\ECoG\xiaoxiao\xx20220805\Block-1';...
    'E:\ECoG\xiaoxiao\xx20220806\Block-1';...
    'E:\ECoG\chouchou\cc20220806\Block-2';...
    'E:\ECoG\chouchou\cc20220809\Block-3';...
    };
% blksActive = {'E:\ECoG\chouchou\cc20220604\Block-1'};

for blkN = 1 : length(blksActive)
    for posIndex = 1 : 2
        clearvars -except posIndex blksActive blkN SAVEPATH
        disp(strcat('processing...(', num2str((posIndex - 1) * length(blksActive) + blkN), '/', num2str(2 * length(blksActive)), ')'));
        SAVEPATH = 'E:\ECoG\matData\behavior\ClickTrainOddCompareTone\Active';
        posStr = ["LAuC", "LPFC"];
        reprocess = 0;
        params.posIndex = posIndex; % 1-AC, 2-PFC
        params.choiceWin = [100, 800];
        params.processFcn = @ActiveProcess_clickTrainWM;
        fs = 500; % Hz, for downsampling
        flp = inf;
        fhp = 0;

        %% process content
        processBehavior = 0;
        processPrediction = 1;
        processDeviant = 0;
        processDecisionMaking = 0;
        processMMN = 1;
        processDevControlDevOnset = 0;
        processDevControlPushOnset = 0;


        %% Processing
        BLOCKPATH = blksActive{blkN};
        temp = string(split(BLOCKPATH, '\'));
        DateStr = temp(end - 1);
        AREANAME = {'AC', 'PFC'};
        Paradigm = 'ClickTrainOddCompareTone';
        SAVEPATH = fullfile(SAVEPATH , DateStr);


        if ~exist(fullfile(SAVEPATH,strcat(posStr(posIndex), '_rawData.mat')),"file") % check if rawData exist
            [trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH, params);
%             ECOGDataset = mResample2(ECOGDataset, fs, fhp, flp);% filtered, dowmsampled, zoomed
            trialAll = deleteWrongTrial(trialAll, Paradigm);
            mkdir(SAVEPATH);
            save(fullfile(SAVEPATH,strcat(posStr(posIndex), '_rawData.mat')), 'ECOGDataset', 'trialAll', '-mat');
        elseif   reprocess
            load(fullfile(SAVEPATH,strcat(posStr(posIndex), '_rawData.mat')));
        else
            continue
        end

        clear comp

        if ~exist(fullfile(SAVEPATH,strcat(posStr(posIndex), '_icaComp.mat')),"file") % check if rawData exist
            window  = [-2000, 2000];
            comp = mICA(ECOGDataset, trialAll, window, "dev onset", fs);
            t1 = [-2000, -1500, -1000, -500, 0];
            t2 = t1 + 300;
            comp = realignIC(comp, window, t1, t2);
            save(fullfile(SAVEPATH,strcat(posStr(posIndex), '_icaComp.mat')),  'comp', '-mat');
        else
            load(fullfile(SAVEPATH,strcat(posStr(posIndex), '_icaComp.mat')));
        end
        if ~isempty(ECOGDataset)
            fs0 = ECOGDataset.fs;
        end

        %% Data saving params


        ROOTPATH = fullfile('E:\ECoG\ECoGBehaviorResult',Paradigm,DateStr);
        soundDuration = 200; % ms

        %% title & labels
        % pairStr = {'4-4.06RC','4-4.06RD','4-4.06IC','4-4.06ID','4-4.06InC','4-4.06InD','40-40.6RC','40-40.6RD','Tone-C','Tone-D'};
        pairStr = {'4-4.16RC','4-4.16RD','4-5RC','4-5RD','4-4.16IC','4-4.16ID','4-5IC','4-5ID','250-250Hz','250-240Hz','250-250Hz','250-200Hz'};
        typeStr = {'4-4o16Regular','4-5Regular','4-4o06Irregular','4-5Irregular','250-240HzTone','250-200HzTone'};

        posStr = ["LAuC", "LPFC"];


        %% Behavior processing
        clear trialsNoInterrupt trials
        trialAll = trialAll(2:end);
        trialsNoInterrupt = trialAll([trialAll.interrupt] == false);
        ISI = fix(mean(cellfun(@(x, y) (x(end) - x(1)) / y, {trialsNoInterrupt.soundOnsetSeq}, {trialsNoInterrupt.stdNum})));
        diffPairs = [[trialsNoInterrupt.stdOrdr]' [trialsNoInterrupt.devOrdr]'];
        diffPairsUnique = unique(diffPairs, 'rows');
        stdType = unique(diffPairsUnique(:,1));
        devType = unique(diffPairsUnique(:,2));

        %% Plot behavior result
        if processBehavior
            trials = trialsNoInterrupt;
            [FigBehavior, mAxe] = plotClickTrainWMBehaviorOnly(trials, "k", {'control', 'dev'},pairStr);
            % saveFigures
            behavPath = fullfile(ROOTPATH,'behaviorResult');
            if ~exist(behavPath,"dir")
                mkdir(behavPath)
            end
            saveas(FigBehavior,strcat(behavPath, '_',  AREANAME{posIndex}, 'behavResult.jpg'));

        end
        %% Prediction
        if processPrediction
            window = [-2500, 6000]; % ms
            for sIndex = 1 : length(stdType)
                trials = trialAll([trialAll.stdOrdr] == stdType(sIndex) & [trialAll.interrupt] == false);
                trialsC = trials([trials.correct]);
                trialsW = trials(~[trials.correct]);
                [trialsECOG, chMean{sIndex, 1}, chStd{sIndex, 1}] = joinSTD(trials, ECOGDataset, window);
                S2 = cellfun(@(x)  comp.unmixing * x, trialsECOG, "UniformOutput", false);
                chMeanICA{sIndex, 1} = cell2mat(cellfun(@mean, changeCellRowNum(S2), "UniformOutput", false));
            end

            predictData = struct("typeStr", typeStr', "fs", num2cell(ones(length(stdType), 1) * fs), "fs0", num2cell(ones(length(stdType), 1) * fs0), "window", ...
                array2VectorCell(repmat(window, length(stdType), 1)), "chMean", chMean, "chStd", chStd, ...
                "chMeanICA", chMeanICA, "trialsC", trialsC, "trialsW", trialsW);
            % save prediction data
            save(fullfile(SAVEPATH,strcat(posStr(posIndex), '_predictData.mat')), 'predictData');
            clear chMean chStd  chMeanICA trialsC trialsW trials
        end

        %% deviant response
        if processDeviant
            window = [-2000, 2000]; % ms

            for dIndex = 1:length(devType)
                trials = trialAll([trialAll.devOrdr] == devType(dIndex) & [trialAll.interrupt] == false & [trialAll.correct] == true);
                if isempty(trials)
                    continue
                end
                [trialsECOG, chMean{sIndex}, chStd{Index}] = selectEcog(ECOGDataset, trials, "dev onset", window);
                S2 = cellfun(@(x)  comp.unmixing * x, trialsECOG, "UniformOutput", false);
                chMeanICA{dIndex,1 } = cell2mat(cellfun(@mean, changeCellRowNum(S2), "UniformOutput", false));

            end

            % save deviant data
            save(fullfile(SAVEPATH,strcat(posStr(posIndex), '_deviantData.mat')), 'trials','typeStr', 'pairStr', 'chMean', 'chStd', 'fs', 'fs0', 'window', 'stdType');
            clear chMean chStd  chMeanICA
        end


        %% Decision making
        if processDecisionMaking
            window = [-2000, 2000];
            % resultC = [];
            % resultW = [];

            for dIndex = 1 : length(devType)
                trials = trialAll([trialAll.devOrdr] == devType(dIndex));
                [result, ~, ~] = selectEcog(ECOGDataset, trials, "dev onset", window);

                % raw result
                result = changeCellRowNum(cellfun(@zscore, changeCellRowNum(result), "UniformOutput", false));
                resultC{dIndex, 1} = result([trials.correct] == true);
                resultW{dIndex, 1} = result([trials.correct] == false & [trials.interrupt] == false);
                if length(resultW{dIndex, 1})<0.1*length(trials) || length(resultC{dIndex, 1})<0.1*length(trials)
                    continue
                else
                    chMeanStd{dIndex, 1} = cell2mat(cellfun(@mean, changeCellRowNum(resultC{dIndex, 1}), "UniformOutput", false));
                    chMeanDev{dIndex, 1} = cell2mat(cellfun(@mean, changeCellRowNum(resultW{dIndex, 1}), "UniformOutput", false));
                end

                % ica icaResult
                icaResult = cellfun(@(x)  comp.unmixing * x, result, "UniformOutput", false);
                icaResult = changeCellRowNum(cellfun(@zscore, changeCellRowNum(icaResult), "UniformOutput", false));
                icaResultC{dIndex, 1} = icaResult([trials.correct] == true);
                icaResultW{dIndex, 1} = icaResult([trials.correct] == false & [trials.interrupt] == false);
                if length(icaResultW{dIndex, 1})<0.1*length(trials) || length(icaResultC{dIndex, 1})<0.1*length(trials)
                    continue
                else
                    chMeanStdICA{dIndex, 1} = cell2mat(cellfun(@mean, changeCellRowNum(icaResultC{dIndex, 1}), "UniformOutput", false));
                    chMeanDevICA{dIndex, 1} = cell2mat(cellfun(@mean, changeCellRowNum(icaResultW{dIndex, 1}), "UniformOutput", false));
                end


            end

            % save deviant data
            save(fullfile(SAVEPATH,strcat(posStr(posIndex), '_decisionMakingData.mat')), 'trials','typeStr', 'pairStr', 'resultC', 'resultW' ,'chMeanStd', 'chMeanDev', 'fs', 'fs0', 'window', 'stdType');
            clear chMeanStdICA chMeanDevICA icaResultC icaResultW resultW resultC chMeanStd chMeanDev icaResult result
        end


        %% MMN
        if processMMN
            window = [-2000, 2000];
            for dIndex = 1 : length(devType)
                trialsC{dIndex, 1} = trialAll([trialAll.correct] == true & [trialAll.devOrdr] == devType(dIndex));
                trialsW{dIndex, 1} = trialAll([trialAll.correct] == false & [trialAll.interrupt] == false & [trialAll.devOrdr] == devType(dIndex));
                trialsAll{dIndex, 1} = trialAll([trialAll.devOrdr] == devType(dIndex));

                [trialsECOGDEVC, chMeanDEVC{dIndex, 1}, ~] = selectEcog(ECOGDataset, trialsC{dIndex, 1}, "dev onset", window);
                S2 = cellfun(@(x)  comp.unmixing * x, trialsECOGDEVC, "UniformOutput", false);
                chMeanDEVCICA{dIndex, 1} = cell2mat(cellfun(@mean, changeCellRowNum(S2), "UniformOutput", false));

                [trialsECOGSTDC, chMeanLastSTDC{dIndex, 1}, ~] = selectEcog(ECOGDataset, trialsC{dIndex, 1}, "last std", window);
                S2 = cellfun(@(x)  comp.unmixing * x, trialsECOGSTDC, "UniformOutput", false);
                chMeanLastSTDCICA{dIndex, 1} = cell2mat(cellfun(@mean, changeCellRowNum(S2), "UniformOutput", false));

                [trialsECOGDEVW, chMeanDEVW{dIndex, 1}, ~] = selectEcog(ECOGDataset, trialsW{dIndex, 1}, "dev onset", window);
                S2 = cellfun(@(x)  comp.unmixing * x, trialsECOGDEVW, "UniformOutput", false);
                chMeanDEVWICA{dIndex, 1} = cell2mat(cellfun(@mean, changeCellRowNum(S2), "UniformOutput", false));

                [trialsECOGSTDW, chMeanLastSTDW{dIndex, 1}, ~] = selectEcog(ECOGDataset, trialsW{dIndex, 1}, "last std", window);
                S2 = cellfun(@(x)  comp.unmixing * x, trialsECOGSTDW, "UniformOutput", false);
                chMeanLastSTDWICA{dIndex, 1} = cell2mat(cellfun(@mean, changeCellRowNum(S2), "UniformOutput", false));

                [trialsECOGDEV, chMeanDEV{dIndex, 1}, ~] = selectEcog(ECOGDataset, trialsAll{dIndex, 1}, "dev onset", window);
                S2 = cellfun(@(x)  comp.unmixing * x, trialsECOGDEV, "UniformOutput", false);
                chMeanDEVICA{dIndex, 1} = cell2mat(cellfun(@mean, changeCellRowNum(S2), "UniformOutput", false));

                [trialsECOGSTD, chMeanLastSTD{dIndex, 1}, ~] = selectEcog(ECOGDataset, trialsAll{dIndex, 1}, "last std", window);
                S2 = cellfun(@(x)  comp.unmixing * x, trialsECOGSTD, "UniformOutput", false);
                chMeanLastSTDICA{dIndex, 1} = cell2mat(cellfun(@mean, changeCellRowNum(S2), "UniformOutput", false));
            end

            MMNData = struct("pairStr", pairStr', "fs", num2cell(ones(length(devType), 1) * fs), "fs0", num2cell(ones(length(devType), 1) * fs0), "window", ...
                array2VectorCell(repmat(window, length(devType), 1)), "chMeanDEV", chMeanDEV, "chMeanLastSTD", chMeanLastSTD, "chMeanDEVC", chMeanDEVC, ...
                "chMeanLastSTDC", chMeanLastSTDC, "chMeanDEVW", chMeanDEVW, "chMeanLastSTDW", chMeanLastSTDW, ...
                "chMeanDEVICA", chMeanDEVICA, "chMeanLastSTDICA", chMeanLastSTDICA, "chMeanDEVCICA", chMeanDEVCICA, ...
                "chMeanLastSTDCICA", chMeanLastSTDCICA, "chMeanDEVWICA", chMeanDEVWICA, "chMeanLastSTDWICA", chMeanLastSTDWICA, ...
                "trialsC", trialsC, "trialsW", trialsW);

            % save MMN data
            save(fullfile(SAVEPATH,strcat(posStr(posIndex), '_MMNData.mat')), "MMNData");
            clear trialsC trialsW trialsAll chMeanDEVC chMeanDEVCICA chMeanLastSTDC chMeanLastSTDCICA chMeanDEVW chMeanDEVWICA chMeanLastSTDW chMeanLastSTDWICA chMeanDEV chMeanDEVICA chMeanLastSTD chMeanLastSTDICA
        end


        %% dev V.S. control, push onset
        if processDevControlPushOnset
            window = [-2000, 2000];
            dIndex = 2;
            trialsRegD = trialAll([trialAll.stdOrdr] == stdType(1) & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV" & [trialAll.correct]);
            trialsIrregD = trialAll([trialAll.stdOrdr] == stdType(2) & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV" & [trialAll.correct]);
            trialsToneD = trialAll([trialAll.stdOrdr] == stdType(3) & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV" & [trialAll.correct]);
            if isempty(trialsRegD)
                chMeanRegD = [];
            else
                [~, chMeanRegD, ~] = selectEcog(ECOGDataset, trialsRegD, "push onset", window);
            end

            if isempty(trialsIrregD)
                chMeanIrregD = [];
            else
                [~, chMeanIrregD, ~] = selectEcog(ECOGDataset, trialsIrregD, "push onset", window);
            end

            if isempty(trialsToneD)
                chMeanToneD = [];
            else
                [~, chMeanToneD, ~] = selectEcog(ECOGDataset, trialsToneD, "push onset", window);
            end
            % save dev v.s. control data
            save(fullfile(SAVEPATH,strcat(posStr(posIndex), '_DevControlPush.mat')), 'typeStr', 'pairStr', 'chMeanRegD', 'chMeanIrregD', 'chMeanToneD', 'chStd', 'fs', 'fs0', 'window', 'stdType');
            clear   chMeanRegD      chMeanIrregD    chMeanToneD
        end


        %% dev V.S. control, dev onset
        if processDevControlDevOnset
            window = [-2000, 2000];
            trialsRegC = trialAll([trialAll.stdOrdr] == stdType(1) & [trialAll.interrupt] == false & [trialAll.oddballType] == "STD" );
            trialsIrregC = trialAll([trialAll.stdOrdr] == stdType(2) & [trialAll.interrupt] == false & [trialAll.oddballType] == "STD");
            trialsToneC = trialAll([trialAll.stdOrdr] == stdType(3) & [trialAll.interrupt] == false & [trialAll.oddballType] == "STD");

            trialsRegD = trialAll([trialAll.stdOrdr] == stdType(1) & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV" );
            trialsIrregD = trialAll([trialAll.stdOrdr] == stdType(2) & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV");
            trialsToneD = trialAll([trialAll.stdOrdr] == stdType(3) & [trialAll.interrupt] == false & [trialAll.oddballType] == "DEV");

            [~, chMeanRegC, ~] = selectEcog(ECOGDataset, trialsRegC, "dev onset", window);
            [~, chMeanRegD, ~] = selectEcog(ECOGDataset, trialsRegD, "dev onset", window);
            [~, chMeanIrregC, ~] = selectEcog(ECOGDataset, trialsIrregC, "dev onset", window);
            [~, chMeanIrregD, ~] = selectEcog(ECOGDataset, trialsIrregD, "dev onset", window);
            [~, chMeanToneC, ~] = selectEcog(ECOGDataset, trialsToneC, "dev onset", window);
            [~, chMeanToneD, ~] = selectEcog(ECOGDataset, trialsToneD, "dev onset", window);

            % save dev v.s. control data
            save(fullfile(SAVEPATH,strcat(posStr(posIndex), '_DevControlDevOnset.mat')), 'typeStr', 'pairStr', 'chMeanRegD', 'chMeanRegC', 'chMeanIrregD', 'chMeanIrregC', 'chMeanToneD', 'chMeanToneC', 'chStd', 'fs', 'fs0', 'window', 'stdType');
        end
    end
end