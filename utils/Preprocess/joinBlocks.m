function [data, segTimePoint] = joinBlocks(opts, varargin)
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
abortHeadTail = getOr(opts, 'abortHeadTail', 1);
behavOnly = getOr(opts, 'behavOnly', 0);
sfNames = opts.sfNames;
efNames = opts.efNames;

%% Time correction
duration = zeros(length(varargin), 1); % s
if behavOnly
    duration(1) = varargin{1}.time_ranges(2);
else
    duration(1) = size(varargin{1}.streams.(sfNames(1)).data, 2) / varargin{1}.streams.(sfNames(1)).fs;
end
segTimePoint = [0 duration(1)];
for dIndex = 2:length(varargin)
    if behavOnly
        duration(dIndex) = duration(dIndex - 1) + varargin{dIndex}.time_ranges(2);
    else
        duration(dIndex) = duration(dIndex - 1) + size(varargin{dIndex}.streams.(sfNames(1)).data, 2) / varargin{dIndex}.streams.(sfNames(1)).fs;
    end

    segTimePoint = [segTimePoint; [duration(dIndex -1)  duration(dIndex)] ];

    for eIndex = 1:length(efNames)
        try
            varargin{dIndex}.epocs.(efNames(eIndex)).onset = varargin{dIndex}.epocs.(efNames(eIndex)).onset + segTimePoint(dIndex - 1, 2);
        catch e
            disp(e.message);
        end
    end

end

%% Join blocks
if ~behavOnly
    for sIndex = 1:length(sfNames)
        streams.(sfNames(sIndex)) = struct('channels', varargin{1}.streams.(sfNames(sIndex)).channels, ...
            'data', [], ...
            'fs', varargin{1}.streams.(sfNames(sIndex)).fs);
    end
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
            if abortHeadTail % abort first or last trial
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
            else
                epocs.(efNames(eIndex)).onset = vertcat(epocs.(efNames(eIndex)).onset, varargin{dIndex}.epocs.(efNames(eIndex)).onset);
                epocs.(efNames(eIndex)).data = vertcat(epocs.(efNames(eIndex)).data, varargin{dIndex}.epocs.(efNames(eIndex)).data);
            end
        end

    end
    if ~behavOnly
        for sIndex = 1:length(sfNames)
            streams.(sfNames(sIndex)).data = horzcat(streams.(sfNames(sIndex)).data, varargin{dIndex}.streams.(sfNames(sIndex)).data);
        end
    else
        streams = [];
    end
end

data = struct('epocs', epocs, 'streams', streams);

return;
end