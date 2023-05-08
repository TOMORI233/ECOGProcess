function [resultSTD, chMean, chStd, window] = joinSTD(trials, dataset, varargin)
    % Description: average wave of std sounds in trials with different std number
    % Input:
    %     trials: n*1 struct containing trial data
    %     dataset:
    %         1. trialsECOG: n*1 cell with each element of nChs*m data
    %         2. ECOGDataset: TDT dataset
    %     fs: raw sample rate, in Hz
    %     reserveTail: reserve data during [ISI * nStdMax, window(end)]
    % Output:
    %     resultSTD: unique(nStd)*1 cell, re-weighted wave of trials with std number >= nStd(i)
    %     chMean: joint mean wave of trials of all std number
    %     chStd: std
    %     window: [-2500, ISI * max(nStd) + 2000], in ms
    % Example:
    %     [resultSTD, chMean, chStd, window] = joinSTD(trials, trialsECOG, fs);
    %     [resultSTD, chMean, chStd, window] = joinSTD(trials, ECOGDataset);

    mIp = inputParser;
    mIp.addRequired('trials', @isstruct);
    mIp.addRequired('dataset', @(x) isstruct(x) || iscell(x));
    mIp.addOptional("fs", [], @(x) validateattributes(x, {'numeric'}, {'numel', 1, 'positive'}));
    mIp.addParameter("reserveTail", false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    mIp.parse(trials, dataset, varargin{:});

    fs = mIp.Results.fs;
    reserveTail = mIp.Results.reserveTail;

    ISI = fix(mean(cellfun(@(x, y) (x(end) - x(1)) / y, {trials.soundOnsetSeq}, {trials.stdNum})));
    stdNumAll = unique([trials.stdNum]);
    resultSTD = cell(length(stdNumAll), 1);
    window = [-3000, ISI * max(stdNumAll) + 2000];

    switch class(dataset)
        case 'cell'
            trialsECOG = dataset;

            if isempty(fs)
                error('Required input fs is empty!');
            end

        case 'struct'
            fs = dataset.fs;
            trialsECOG = selectEcog(dataset, trials, "trial onset", window);
        otherwise
            error("Invalid syntax");
    end
    
    for sIndex = 1:length(stdNumAll)
    
        if sIndex == 1
            windowSTD = [window(1), ISI * stdNumAll(sIndex)];
        else
            windowSTD = [ISI * (stdNumAll(sIndex) - 1), ISI * stdNumAll(sIndex)];
        end

        if reserveTail && sIndex == length(stdNumAll)
            windowSTD = [ISI * (stdNumAll(sIndex) - 1), window(end)];
        end
    
        temp = trialsECOG([trials.stdNum] >= stdNumAll(sIndex));
        weightSTD = zeros(1, size(temp{1}, 2));
        weightSTD(floor((windowSTD(1) - window(1)) * fs / 1000 + 1):floor((windowSTD(2) - window(1)) * fs / 1000)) = 1 / length(temp);
        
        if length(temp) > 1
            resultSTD{sIndex} = cell2mat(cellfun(@sum, changeCellRowNum(cellfun(@(x) x .* weightSTD, temp, "UniformOutput", false)), "UniformOutput", false));
        else
            resultSTD{sIndex} = temp{1};
        end

    end

    chMean = resultSTD{1};
    
    for index = 2:length(resultSTD)
        chMean = chMean + resultSTD{index};
    end
    
    chMean = double(chMean);
    chStd = zeros(size(chMean, 1), size(chMean, 2));

    return;
end