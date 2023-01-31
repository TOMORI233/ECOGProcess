function IsPos = decideNP(data, time, fraction, Method)
if strcmpi(Method, "Raw")
    data = num2cell(data, 2);
    PosIsGreater = cellfun(@(x) AreaAboveThr(x, time, fraction), data, "UniformOutput", false);
    if sum(cell2mat(PosIsGreater)) > length(PosIsGreater)
       IsPos = true;
    else
        IsPos = false;
    end
elseif strcmpi(Method, "Mean")
    data = mean(data, 1);
    IsPos = AreaAboveThr(data, time, fraction);
end
end