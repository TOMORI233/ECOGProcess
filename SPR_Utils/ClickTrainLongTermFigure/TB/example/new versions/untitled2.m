% 指定.tsv文件的路径
filename = 'I:\neuroPixels\TDTTank\Rat2_SPR\Rat2SPR20230708\Merge1\th9_7\cluster_info.tsv';

% 打开.tsv文件进行读取
fileID = fopen(filename, 'r');

% 读取.tsv文件的内容
fieldNames = textscan(fileID, '%s%s%s%s%s%s%s%s%s%s%s', 'HeaderLines', 0);
dataArray = textscan(fileID, '%f%f%f%s%f%f%f%f%f%f', 'HeaderLines', 1);


% 关闭文件
fclose(fileID);

% 将读取到的数据转换为n*10的数组
array = cell2mat(dataArray);