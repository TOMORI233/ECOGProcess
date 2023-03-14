function neighbor_channels = find_neighbor_channels(channels, topology)
% channels: 要找邻域的通道，一个向量，如[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, ...]
% topology: 通道的拓扑，如[8, 8]

n_row = topology(1);
n_col = topology(2);
n_channels = length(channels);

% 根据输入的通道数目，预先分配合适的邻域通道矩阵
if n_channels == 1
    neighbor_channels = {reshape(find_neighbors(channels, n_row, n_col), 1, [])};
else
    neighbor_channels = cell(n_channels, 1);
    for i = 1:n_channels
        neighbor_channels{i} = sort(reshape(find_neighbors(channels(i), n_row, n_col), 1, []))';
    end
end
end

function neighbors = find_neighbors(channel_idx, n_row, n_col)
% 查找单个通道的邻域通道索引
row_idx = ceil(channel_idx / n_col);
col_idx = channel_idx - (row_idx - 1) * n_col;
neighbor_idx = zeros(3, 3);
for j = 1:3
    for k = 1:3
        row = row_idx - 2 + j;
        col = col_idx - 2 + k;
        if row >= 1 && row <= n_row && col >= 1 && col <= n_col
            idx = (row - 1) * n_col + col;
            neighbor_idx(j, k) = idx;
        end
    end
end
neighbors = neighbor_idx(:)';
neighbors(neighbors == 0 | neighbors == channel_idx) = [];
end