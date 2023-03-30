 %% CRI Tuning
    sigCh= find(cell2mat(S1H));
    nSigCh = find(~cell2mat(S1H));
    compare.OR_SigCHs = sigCh;
    compare.OR_noSigCHs = nSigCh;
% CRI
    tempMean = [CRI_Boot(compareIdx).mean]'; 
    tempSE = [CRI_Boot(compareIdx).se]';
    compare.CRI_Boot_Sig = [(1:length(compareIdx))', reshape([tempMean(:, sigCh); tempSE(:, sigCh)], length(compareIdx), [])];
    compare.CRI_Boot_SigMean = [(1:length(compareIdx))', tempMean(:, sigCh)];
    compare.CRI_Boot_noSig = [(1:length(compareIdx))', reshape([tempMean(:, nSigCh); tempSE(:, nSigCh)], length(compareIdx), [])];
    compare.CRI_Boot_noSigMean = [(1:length(compareIdx))', tempMean(:, nSigCh)];
    
    % ORI
    tempMean = [ORI_Boot(compareIdx).mean]'; 
    tempSE = [ORI_Boot(compareIdx).se]';
    compare.ORI_Boot_Sig = [(1:length(compareIdx))', reshape([tempMean(:, sigCh); tempSE(:, sigCh)], length(compareIdx), [])];
    compare.ORI_Boot_SigMean = [(1:length(compareIdx))', tempMean(:, sigCh)];
    compare.ORI_Boot_noSig = [(1:length(compareIdx))', reshape([tempMean(:, nSigCh); tempSE(:, nSigCh)], length(compareIdx), [])];
    compare.ORI_Boot_noSigMean = [(1:length(compareIdx))', tempMean(:, nSigCh)];


% RMS
% temp = cellfun(@(x) changeCellRowNum(x), {CRI(compareIdx).rsp}', "UniformOutput", false);
temp = {CRI_Boot(compareIdx).rsp}';
tempMean = cell2mat(cellfun(@(x) cellfun(@mean, x), temp, "UniformOutput", false)')';
tempSE =  cell2mat(cellfun(@(x) SE(x), [temp{:}], "UniformOutput", false))';
    compare.RMS_Boot_Sig = [(1:length(compareIdx))', reshape([tempMean(:, sigCh); tempSE(:, sigCh)], length(compareIdx), [])];
    compare.RMS_Boot_SigMean = [(1:length(compareIdx))', tempMean(:, sigCh)];
    compare.RMS_Boot_noSig = [(1:length(compareIdx))', reshape([tempMean(:, nSigCh); tempSE(:, nSigCh)], length(compareIdx), [])];
    compare.RMS_Boot_noSigMean = [(1:length(compareIdx))', tempMean(:, nSigCh)];
    