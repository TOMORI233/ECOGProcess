function [path, temp] = getSubfoldPath(rootpath, fileOrFolder, keyword)
narginchk(2, 3);
if nargin < 3
    keyword = [];
end

temp = dir(strcat(rootpath, '\**\*' ,fileOrFolder));
temp2 = cellfun(@(x) fullfile(x{1},x{2}),array2VectorCell([{temp.folder}' {temp.name}']),'uni',false);
if ~isempty(keyword)
    [path, resLogic] = regexpKeyword(temp2, keyword);
    temp = temp(resLogic);
else
    path = temp2;
end
end


function res = array2VectorCell(data)
[m n] = size(data);
for i = 1:m
    res{i,1} = data(i,:);
end
end


function [res,resLogic] = regexpKeyword(data,keyword)
str = data;
pat = ".*"; %初始化正则表达式
if ~iscell(keyword)
    keyword = {keyword};
end
for keyN = 1:length(keyword) %根据keyword的长度设置循环次数
    pat = strcat(pat, keyword{keyN}, ".*"); % 获得完整的正则表达式
end
resLogic = ~cellfun(@isempty,regexp(str,pat,'match'));
if size(resLogic,2) ~= size(str,2)
    resLogic = resLogic';
end

res = data(resLogic);%返回符合要求的字符串索引对应的所有信息
end