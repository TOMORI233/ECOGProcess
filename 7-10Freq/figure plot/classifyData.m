%% classify
windowC = [100, 300];
ch = 7;
idx0 = randperm(length(trialsECOG));
tIdx = fix((windowC(1) - windowPE(1)) / 1000 * fs) + 1:fix((windowC(2) - windowPE(1)) / 1000 * fs);
trainingData = cell2mat(cellfun(@(x) x(ch, tIdx), trialsECOG(1:fix(length(idx0) / 2)), "UniformOutput", false));
sampleData = cell2mat(cellfun(@(x) x(ch, tIdx), trialsECOG(fix(length(idx0) / 2) + 1:end), "UniformOutput", false));
group = dRatioAll';
trainingGroup = group(1:fix(length(idx0) / 2));
trainingGroup(trainingGroup ~= 1) = 0;

svmModel = fitcsvm(trainingData, trainingGroup);
CVSVMModel = crossval(svmModel);
classLoss = kfoldLoss(CVSVMModel)

[class,err,posterior,logp,coeff] = classify(sampleData, trainingData, dRatioAll(1:fix(length(idx0) / 2))', "diagLinear");
cm = confusionchart(dRatioAll(fix(length(idx0) / 2) + 1:end)', class);