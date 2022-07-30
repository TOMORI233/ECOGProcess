clear; clc; close all;
%% Parameter setting
blksActive = {'E:\ECoG\chouchou\cc20220617\Block-1';...
    'E:\ECoG\chouchou\cc20220630\Block-1';...
    'E:\ECoG\chouchou\cc20220701\Block-1';...
    'E:\ECoG\xiaoxiao\xx20220701\Block-3';...
    'E:\ECoG\xiaoxiao\xx20220705\Block-1';...
    'E:\ECoG\xiaoxiao\xx20220709\Block-1';...
    'E:\ECoG\xiaoxiao\xx20220714\Block-2';...
    'E:\ECoG\xiaoxiao\xx20220719\Block-1';...
    };

for blkN = 1 : length(blksActive)
    for posIndex = 1 : 2
        clearvars -except posIndex blksActive blkN SAVEPATH
        disp(strcat('processing...(', num2str((posIndex - 1) * length(blksActive) + blkN), '/', num2str(2 * length(blksActive)), ')'));
        SAVEPATH = 'E:\ECoG\matData\behavior\ClickTrainOddICIThr';
        posStr = ["LAuC", "LPFC"];
        reprocess = 1;
        params.posIndex = posIndex; % 1-AC, 2-PFC
        params.choiceWin = [100, 800];
        params.processFcn = @ActiveProcess_clickTrain1_9;
        fs = 500; % Hz, for downsampling

        %% process content
        processBehavior = 0;
        processPrediction = 1;
        processDeviant = 0;
        processDecisionMaking = 0;
        processMMN = 0;
        processDevControlDevOnset = 0;
        processDevControlPushOnset = 0;


        %% Processing
        activeOrPassive = 'Active';
        BLOCKPATH = blksActive{blkN};
        temp = string(split(BLOCKPATH, '\'));
        DateStr = temp(end - 1);
        AREANAME = {'AC', 'PFC'};
        Paradigm = "ClickTrainOddICIThr";
        SAVEPATH = fullfile(SAVEPATH , DateStr, activeOrPassive);


        if ~exist(fullfile(SAVEPATH,strcat(posStr(posIndex), '_rawData.mat')),"file") % check if rawData exist
            [trialAll, ECOGDataset] = ECOGPreprocess(BLOCKPATH, params);
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


        ROOTPATH = fullfile("E:\ECoG\ECoGBehaviorResult",Paradigm,DateStr);
        soundDuration = 200; % ms

        %% title & labels
        pairStr = {'4ms','4o03ms','4o06ms','4o09ms','4o12ms'};
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
            [FigBehavior, mAxe] = plotBehaviorOnly(trialAll, "k", "7-10");
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
                [trialsECOG, chMean{sIndex}, chStd{sIndex}] = joinSTD(trials, ECOGDataset, window);
                S2 = cellfun(@(x)  comp.unmixing * x, trialsECOG, "UniformOutput", false);
                chMeanICA{sIndex} = cell2mat(cellfun(@mean, changeCellRowNum(S2), "UniformOutput", false));
            end

            % save prediction data
            predictData = struct( "pairStr", pairStr', "fs", num2cell(ones(length(stdType), 1) * fs), "fs0", num2cell(ones(length(stdType), 1) * fs0), "window", ...
                array2VectorCell(repmat(window, length(stdType), 1)), "chMean", chMean, "chStd", chStd, ...
                "chMeanICA", chMeanICA, "trialsC", trialsC, "trialsW", trialsW);   
            save(fullfile(SAVEPATH,strcat(posStr(posIndex), '_predictData.mat')), 'predictData');
            clear chMean chStd  chMeanICA
        end

        %% deviant response
        if processDeviant
            window = [-2000, 2000]; % ms

            for dIndex = 1:length(devType)
                trials = trialAll([trialAll.devOrdr] == devType(dIndex) & [trialAll.interrupt] == false & [trialAll.correct] == true);
                if isempty(trials)
                    continue
                end
                [trialsECOG, chMean{sIndex}, chStd{sIndex}] = selectEcog(ECOGDataset, trials, "dev onset", window);
                S2 = cellfun(@(x)  comp.unmixing * x, trialsECOG, "UniformOutput", false);
                chMeanICA{dIndex} = cell2mat(cellfun(@mean, changeCellRowNum(S2), "UniformOutput", false));

            end

            % save deviant data
            save(fullfile(SAVEPATH,strcat(posStr(posIndex), '_deviantData.mat')), 'trials','typeStr', 'pairStr', 'chMean', 'chMeanICA', 'chStd', 'fs', 'fs0', 'window', 'stdType');
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
            save(fullfile(SAVEPATH,strcat(posStr(posIndex), '_decisionMakingData.mat')), 'trials','typeStr', 'pairStr', 'resultC', 'resultW' ,'chMeanStd', 'chMeanDev','chMeanStdICA', 'chMeanDevICA', 'chStd', 'fs', 'fs0', 'window', 'stdType');
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
    end
end