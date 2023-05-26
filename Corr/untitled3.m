combFF = [];
combFB = [];
idxF = find([trialAll.order] == 1);
idxB = find([trialAll.order] == 2);
for index1 = 1:length(idxF)
    for index2 = 1:length(idxF)
        if index2 > index1
            combFF = [combFF; idxF(index1), idxF(index2)];
        end
    end
end
for index1 = 1:length(idxF)
    for index2 = 1:length(idxB)
        if index2 > index1
            combFB = [combFB; idxF(index1), idxB(index2)];
        end
    end
end

tic
resFF_All = cell(size(combFF, 1), 1);
parfor index = 1:size(combFF, 1)
    resFF_All{index} = rowFcn(@(x, y) calCorrLag(x, y, nLagHalf), trialsECOG{combFF(index, 1)}, trialsECOG{combFF(index, 2)}, "UniformOutput", false);
end
toc

tic
resFrB_All = cell(size(combFB, 1), 1);
parfor index = 1:size(combFB, 1)
    resFrB_All{index} = rowFcn(@(x, y) calCorrLag(x, y, nLagHalf), trialsECOG{combFB(index, 1)}, flip(trialsECOG{combFB(index, 2)}, 2), "UniformOutput", false);
end
toc

meanFF = changeCellRowNum(cellfun(@(x) cell2mat(cellfun(@(y) mean(y, 1), x, "UniformOutput", false)), resFF_All, "UniformOutput", false));
meanFF = cellfun(@(x) mean(x, 1), meanFF, "UniformOutput", false);
figure;
for cIndex = 1:64
    mSubplot(8, 8, cIndex);
    plot(lags, meanFF{cIndex}, "Color", colors{1});
end
scaleAxes;