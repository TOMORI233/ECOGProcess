function res = changeCellRowNum(data)
    a = size(data{1}, 1);
    temp = cell2mat(data);
    res = cell(a, 1);
    
    for index = 1:a
        res{index} = temp(index:a:size(temp, 1), :);
    end

    return;
end