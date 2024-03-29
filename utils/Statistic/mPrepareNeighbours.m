function neighbours = mPrepareNeighbours(channels, topoSize)
    narginchk(0, 2);

    if nargin < 1
        channels = 1:64;
    end

    if nargin < 2
        topoSize = [8, 8]; % [nx, ny]
    end

    % neighbours
    A0 = reshape(channels, topoSize);
    A = padarray(A0, [1, 1]);
    neighbours = struct("label", cellfun(@(x) num2str(x), num2cell(channels'), 'UniformOutput', false), "neighblabel", cell(numel(A0), 1));
    for index = 1:numel(A0)
        [row, col] = find(A == A0(index));
        temp = A(row - 1:row + 1, col - 1:col + 1);
        temp(temp == 0 | temp == A0(index)) = [];
        neighbours(index).neighbch = temp;
        neighbours(index).neighblabel = arrayfun(@num2str, temp, "UniformOutput", false);
    end

    return;
end