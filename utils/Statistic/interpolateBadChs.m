function trialsECOG = interpolateBadChs(trialsECOG, badCHs, topoSize)
    narginchk(2, 3);

    if nargin < 3
        topoSize = [8, 8]; % [nx, ny]
    end

    % Replace bad chs by averaging neighbour chs
    channels = 1:size(trialsECOG{1}, 1);
    [~, neighbours] = mPrepareNeighbours(channels, topoSize);
    for bIndex = 1:numel(badCHs)
        for tIndex = 1:length(trialsECOG)
            chsTemp = neighbours{badCHs(bIndex)};
            trialsECOG{tIndex}(badCHs(bIndex), :) = mean(trialsECOG{tIndex}(chsTemp(~ismember(chsTemp, badCHs)), :), 1);
        end
    end

    return;
end