function [mergeRes, chIdx] = FDZDailyExtract(data, n)
mergeRes = [];
    for day = 1 : length(data)
        %% extract n or less trials from FDZData
        temp = data{day, 1}(randperm(length(data{day, 1})));
        extractData = temp(1 : min(n, length(temp)));
        mergeRes = [mergeRes; extractData];
    end
        
    chIdx = cellfun(@(x) any(x, 2), mergeRes, "UniformOutput", false)';
    chIdx = all(cell2mat(chIdx), 2);
    
    


    

