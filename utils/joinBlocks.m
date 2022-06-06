function data = joinBlocks(opts, varargin)
    narginchk(3, inf);

    if nargin < 3
        error("Blocks to be joint should be at least 2");
    end

    duration = zeros(length(varargin), 1); % s
    opts.sfName = getOr(opts, "sfName", 'LAuC');
    duration(1) = size(varargin{1}.streams.(opts.sfName).data, 2) / varargin{1}.streams.(opts.sfName).fs;

    for dIndex = 2:length(varargin)
        duration(dIndex) = size(varargin{dIndex}.streams.(opts.sfName).data, 2) / varargin{dIndex}.streams.(opts.sfName).fs;

        fNames = getOr(opts, "efNames", fieldnames(varargin{dIndex}.epocs));

        for index = 1:size(fNames, 1)
            varargin{dIndex}.epocs.(fNames{index}).onset = varargin{dIndex}.epocs.(fNames{index}).onset + duration(dIndex - 1);
        end

    end

    for index = 1:size(fNames, 1)
        epocs.(fNames{index}).onset = [];
        epocs.(fNames{index}).data = [];
    end

    streams.(opts.sfName) = struct('channels', varargin{1}.streams.(opts.sfName).channels, 'data', [], 'fs', varargin{1}.streams.(opts.sfName).fs);

    for dIndex = 1:length(varargin)
        fNames = getOr(opts, "efNames", fieldnames(varargin{dIndex}.epocs));

        for index = 1:size(fNames, 1)

            if strcmp(fNames{index}, 'push') || strcmp(fNames{index}, 'erro')
                epocs.(fNames{index}).onset = vertcat(epocs.(fNames{index}).onset, varargin{dIndex}.epocs.(fNames{index}).onset);
                epocs.(fNames{index}).data = vertcat(epocs.(fNames{index}).data, varargin{dIndex}.epocs.(fNames{index}).data);
            else

                if dIndex == 1 % abort the last trial of the first block
                    epocs.(fNames{index}).onset = vertcat(epocs.(fNames{index}).onset, varargin{dIndex}.epocs.(fNames{index}).onset(1:end - 1));
                    epocs.(fNames{index}).data = vertcat(epocs.(fNames{index}).data, varargin{dIndex}.epocs.(fNames{index}).data(1:end - 1));
                elseif dIndex > 1 && dIndex < length(varargin) % abort the first and the last trials
                    epocs.(fNames{index}).onset = vertcat(epocs.(fNames{index}).onset, varargin{dIndex}.epocs.(fNames{index}).onset(2:end - 1));
                    epocs.(fNames{index}).data = vertcat(epocs.(fNames{index}).data, varargin{dIndex}.epocs.(fNames{index}).data(2:end - 1));
                else % abort the first trial of the last block
                    epocs.(fNames{index}).onset = vertcat(epocs.(fNames{index}).onset, varargin{dIndex}.epocs.(fNames{index}).onset(2:end));
                    epocs.(fNames{index}).data = vertcat(epocs.(fNames{index}).data, varargin{dIndex}.epocs.(fNames{index}).data(2:end));
                end

            end

        end

        streams.(opts.sfName).data = horzcat(streams.(opts.sfName).data, varargin{dIndex}.streams.(opts.sfName).data);
    end

    data = struct('epocs', epocs, 'streams', streams);

    return;
end