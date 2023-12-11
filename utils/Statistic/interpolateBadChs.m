function trialsECOG = interpolateBadChs(trialsECOG, badCHs, neighbours)
    % Description: Interpolate data of bad channels by averaging neighbour channels
    % Input parameter [neighbours]: see mPrepareNeighbours.m

    narginchk(2, 3);

    if nargin < 3 || isempty(neighbours)
        % default: for ECoG recording of an 8*8 electrode array
        [~, neighbours] = mPrepareNeighbours;
    end

    % Replace bad chs by averaging neighbour chs
    for bIndex = 1:numel(badCHs)
        
        for tIndex = 1:length(trialsECOG)
            chsTemp = neighbours{badCHs(bIndex)};
            trialsECOG{tIndex}(badCHs(bIndex), :) = mean(trialsECOG{tIndex}(chsTemp(~ismember(chsTemp, badCHs)), :), 1);
        end

    end

    return;
end