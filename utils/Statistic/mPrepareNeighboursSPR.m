function [neighbours, neighboursInDouble] = mPrepareNeighboursSPR(channels, topoSize)
    narginchk(0, 2);

    if nargin < 1
        channels = 1:64;
    end

    if nargin < 2
        topoSize = [8, 8]; % [nx, ny]
    end

    % neighbours
    temp = find_neighbor_channels(channels, topoSize);
    neighbours = struct("label", cellfun(@(x) num2str(x), num2cell(channels), 'UniformOutput', false), "neighblabel", cell(1, numel(channels)));
    for index = 1:numel(neighbours)
        neighbours(index).neighblabel = mat2cell(temp, ones(size(temp, 1), 1));
    end

    neighboursInDouble = temp;

    return;
end