function trialsECOG = interpolateBadChs(trialsECOG, badCHs, neighbours)
    % Description: Interpolate data of bad channels by averaging neighbour channels
    % Input parameter [neighbours]: see mPrepareNeighbours.m

    narginchk(2, 3);

    if nargin < 3 || isempty(neighbours)
        % default: for ECoG recording of an 8*8 electrode array
        neighbours = mPrepareNeighbours;
    end
    
    neighbch = {neighbours.neighbch}';

    % Replace bad chs by averaging neighbour chs
    for bIndex = 1:numel(badCHs)
        
        for tIndex = 1:length(trialsECOG)
            chsTemp = neighbch{badCHs(bIndex)};

            if isempty(chsTemp)
                warning(['No neighbours specified for channel ', num2str(tIndex), '. Skip']);
                continue;
            end

            if all(ismember(chsTemp, badCHs))
                error(['All neighbour channels are bad for channel ', num2str(badCHs(bIndex))]);
            end

            trialsECOG{tIndex}(badCHs(bIndex), :) = mean(trialsECOG{tIndex}(chsTemp(~ismember(chsTemp, badCHs)), :), 1);
        end

    end

    return;
end