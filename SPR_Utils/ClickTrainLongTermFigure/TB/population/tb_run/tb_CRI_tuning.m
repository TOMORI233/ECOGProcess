 %% CRI Tuning
    sigCh= find(cell2mat(S1H));
    nSigCh = find(~cell2mat(S1H));
    compare.OR_SigCHs = sigCh;
    compare.OR_noSigCHs = nSigCh;
% CRI
    tempMean = [CRI(compareIdx).mean]'; 
    tempSE = [CRI(compareIdx).se]';
    compare.CRI_Sig = [(1:length(compareIdx))', reshape([tempMean(:, sigCh); tempSE(:, sigCh)], length(compareIdx), [])];
    compare.CRI_SigMean = [(1:length(compareIdx))', tempMean(:, sigCh)];
    compare.CRI_noSig = [(1:length(compareIdx))', reshape([tempMean(:, nSigCh); tempSE(:, nSigCh)], length(compareIdx), [])];
    compare.CRI_noSigMean = [(1:length(compareIdx))', tempMean(:, nSigCh)];
    
    % ORI
    tempMean = [ORI(compareIdx).mean]'; 
    tempSE = [ORI(compareIdx).se]';
    compare.ORI_Sig = [(1:length(compareIdx))', reshape([tempMean(:, sigCh); tempSE(:, sigCh)], length(compareIdx), [])];
    compare.ORI_SigMean = [(1:length(compareIdx))', tempMean(:, sigCh)];
    compare.ORI_noSig = [(1:length(compareIdx))', reshape([tempMean(:, nSigCh); tempSE(:, nSigCh)], length(compareIdx), [])];
    compare.ORI_noSigMean = [(1:length(compareIdx))', tempMean(:, nSigCh)];


% RMS
% temp = cellfun(@(x) changeCellRowNum(x), {CRI(compareIdx).rsp}', "UniformOutput", false);
temp = {CRI(compareIdx).rsp}';
tempMean = cell2mat(cellfun(@(x) cellfun(@mean, x), temp, "UniformOutput", false)')';
tempSE =  cell2mat(cellfun(@(x) SE(x), [temp{:}], "UniformOutput", false))';
    compare.RMS_Sig = [(1:length(compareIdx))', reshape([tempMean(:, sigCh); tempSE(:, sigCh)], length(compareIdx), [])];
    compare.RMS_SigMean = [(1:length(compareIdx))', tempMean(:, sigCh)];
    compare.RMS_noSig = [(1:length(compareIdx))', reshape([tempMean(:, nSigCh); tempSE(:, nSigCh)], length(compareIdx), [])];
    compare.RMS_noSigMean = [(1:length(compareIdx))', tempMean(:, nSigCh)];
    