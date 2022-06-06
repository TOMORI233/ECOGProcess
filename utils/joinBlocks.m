function data = joinBlocks(opts, varargin)
    % Example:
    %     data1 = TDTbin2mat(BLOCKPATH1);
    %     data2 = TDTbin2mat(BLOCKPATH2);
    %     opts.sfNames = "LAuC";
    %     opts.efNames = ["num0", "push", "erro", "freq"];
    %     data = joinBlocks(opts, data1, data2);

    narginchk(3, inf);

    if nargin < 3
        error("Blocks to be joint should be at least 2");
    end

    run("joinBlocksConfig.m");
    opts = getOrFull(opts, jbDefaultOpts);
    sfNames = opts.sfNames;
    efNames = opts.efNames;

    %% Time correction
    duration = zeros(length(varargin), 1); % s
    duration(1) = size(varargin{1}.streams.(sfNames(1)).data, 2) / varargin{1}.streams.(sfNames(1)).fs;

    for dIndex = 2:length(varargin)
        duration(dIndex) = size(varargin{dIndex}.streams.(sfNames(1)).data, 2) / varargin{dIndex}.streams.(sfNames(1)).fs;
        
        for eIndex = 1:length(efNames)
            varargin{dIndex}.epocs.(efNames(eIndex)).onset = varargin{dIndex}.epocs.(efNames(eIndex)).onset + duration(dIndex - 1);
        end

    end

    %% Join blocks
    for sIndex = 1:length(sfNames)
        streams.(sfNames(sIndex)) = struct('channels', varargin{1}.streams.(sfNames(sIndex)).channels, ...
                                           'data', [], ...
                                           'fs', varargin{1}.streams.(sfNames(sIndex)).fs);
    end

    for eIndex = 1:length(efNames)
        epocs.(efNames(eIndex)).onset = [];
        epocs.(efNames(eIndex)).data = [];
    end

    for dIndex = 1:length(varargin)
        trialOnsetIdx = find(varargin{dIndex}.epocs.num0.data == 1);

        for eIndex = 1:length(efNames)

            if strcmp(efNames(eIndex), 'push') || strcmp(efNames(eIndex), 'erro')
                epocs.(efNames(eIndex)).onset = vertcat(epocs.(efNames(eIndex)).onset, varargin{dIndex}.epocs.(efNames(eIndex)).onset);
                epocs.(efNames(eIndex)).data = vertcat(epocs.(efNames(eIndex)).data, varargin{dIndex}.epocs.(efNames(eIndex)).data);
            else
                
                
                if dIndex == 1 % abort the last trial of the first block
                    epocs.(efNames(eIndex)).onset = vertcat(epocs.(efNames(eIndex)).onset, varargin{dIndex}.epocs.(efNames(eIndex)).onset(1:trialOnsetIdx(end) - 1));
                    epocs.(efNames(eIndex)).data = vertcat(epocs.(efNames(eIndex)).data, varargin{dIndex}.epocs.(efNames(eIndex)).data(1:trialOnsetIdx(end) - 1));
                elseif dIndex > 1 && dIndex < length(varargin) % abort the first and the last trials
                    epocs.(efNames(eIndex)).onset = vertcat(epocs.(efNames(eIndex)).onset, varargin{dIndex}.epocs.(efNames(eIndex)).onset(trialOnsetIdx(2):trialOnsetIdx(end) - 1));
                    epocs.(efNames(eIndex)).data = vertcat(epocs.(efNames(eIndex)).data, varargin{dIndex}.epocs.(efNames(eIndex)).data(trialOnsetIdx(2):trialOnsetIdx(end) - 1));
                else % abort the first trial of the last block
                    epocs.(efNames(eIndex)).onset = vertcat(epocs.(efNames(eIndex)).onset, varargin{dIndex}.epocs.(efNames(eIndex)).onset(trialOnsetIdx(2):end));
                    epocs.(efNames(eIndex)).data = vertcat(epocs.(efNames(eIndex)).data, varargin{dIndex}.epocs.(efNames(eIndex)).data(trialOnsetIdx(2):end));
                end

            end

        end

        for sIndex = 1:length(sfNames)
            streams.(sfNames(sIndex)).data = horzcat(streams.(sfNames(sIndex)).data, varargin{dIndex}.streams.(sfNames(sIndex)).data);
        end

    end

    data = struct('epocs', epocs, 'streams', streams);

    return;
end