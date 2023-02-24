function trialsECOG = interpolateBadChs(trialsECOG, badCHs)
    % Replace bad chs by averaging neighbour chs
    channels = 1:size(trialsECOG{1}, 1);
    [~, neighbours] = mPrepareNeighbours(channels);
    for bIndex = 1:numel(badCHs)
        for tIndex = 1:length(trialsECOG)
            chsTemp = neighbours{badCHs(bIndex)};
            trialsECOG{tIndex}(badCHs(bIndex), :) = mean(trialsECOG{tIndex}(chsTemp(~ismember(chsTemp, badCHs)), :), 1);
        end
    end

    return;
end