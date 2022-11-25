function [Fig, tfOpts] = plotTFA_Mean(trialsECOG, fs0, window, fRange, gpuSize)
narginchk(3, 5);
if nargin < 4
    fRange = [0, -1];
end
if nargin < 5
    gpuSize = 5001;
end

if size(trialsECOG{1}, 2) > gpuSize
    [trialsECOG_DS, fd] = trialsDownsample(trialsECOG, fs0, fs0* gpuSize / size(trialsECOG{1}, 2));
elseif size(trialsECOG{1}, 2) < gpuSize
    [trialsECOG_DS, fd] = trialsUpsample(trialsECOG, fs0, fs0* gpuSize / size(trialsECOG{1}, 2));
end

t = linspace(window(1), window(2), size(trialsECOG_DS{1}, 2));
trialsECOG_DS = changeCellRowNum(trialsECOG_DS);

%%
CData = cell(length(trialsECOG_DS), 1);
[~, f, coi] = cwtMean(trialsECOG_DS{1}(1, :)', fd, fRange);


nChs = length(trialsECOG_DS);
nTrials = size(trialsECOG_DS{1}, 1);

disp("Do CWT By Trials...")
for cIndex = 1 : nChs
    CDataTemp = cell(nTrials, 1);
    data = trialsECOG_DS{cIndex};
    parfor tIndex = 1 : nTrials
        temp = cwtMean_mex(data(tIndex, :)', fd, fRange);
        CDataTemp{tIndex, 1} = gather(temp);
    end
    CData{cIndex, 1} = cell2mat(cellfun(@mean, changeCellRowNum(CDataTemp), "UniformOutput", false));
    disp(strcat("CH", num2str(cIndex), " DONE..."));
    clear CDataTemp;
end

tfOpts.f = f;
tfOpts.t = t;
tfOpts.coi = coi;
tfOpts.CData = CData;
disp("Plot CWT Mean Figure...")
Fig = plotTFMean(tfOpts);
disp("DONE!")

% scaleAxes(FigTFMean, "c", [0 10]);




