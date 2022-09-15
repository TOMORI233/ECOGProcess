%% validate ICA result
temp = dir('E:\ECoG\matData\chouchou\ClickTrainLongTermMerge/**/*ICARes.mat');
icaResDataPath = cellfun(@(x) fullfile(x{1},x{2}),array2VectorCell([{temp.folder}' {temp.name}']),'uni',false);

for i = 1 : length(icaResDataPath)
    load(icaResDataPath{i});
    if contains(icaResDataPath{i}, 'offsetScreen')
        window = [0 7000];
    else
        window = [0 11000];
    end
    disp(strcat('processing...(', num2str(i), '/', num2str(length(icaResDataPath)), ')'));
    for j = 1 : length(ICARes)
        ICARes(j).t = linspace(window(1), window(2), size(ICARes(j).chMean, 2)) - ICARes(j).S1Duration(j);
        ICARes(j).fs0 = size(ICARes(j).chMean, 2)/(diff(window)/1000);
        ICARes(j).S1Duration = ICARes(j).S1Duration(j);
    end
    save(icaResDataPath{i}, 'ICARes');
end
regexp
%% validate Raw result
[rawResDataPath, temp] = getSubfoldPath('E:\ECoG\matData\xiaoxiao','Res.mat');
for i = 1 : length(rawResDataPath)
    clear data Res ICARes RawRes
    data = load(rawResDataPath{i});
    Paradigm = split(temp(i).folder, '_');
    Paradigm = Paradigm{2};
    matName = split(temp(i).name, '_');
    resStr = strrep(matName{2}, '.mat', '');
    if contains(rawResDataPath{i}, 'offsetScreen')
        window = [0 7000];
    else
        window = [0 11000];
    end
    run("validS1Duration.m");
    disp(strcat('processing...(', num2str(i), '/', num2str(length(rawResDataPath)), ')'));
    fieldname = fields(data);
    Res = data.(fieldname{1});
    for j = 1 : length(Res)
            Res(j).t = linspace(window(1), window(2), size(Res(j).chMean, 2)) - S1Duration(j);
            Res(j).S1Duration = S1Duration(j);
        Res(j).fs0 = size(Res(j).chMean, 2)/(diff(window)/1000);
    end
    eval([resStr '= Res;']);
    save(rawResDataPath{i}, resStr);
end
