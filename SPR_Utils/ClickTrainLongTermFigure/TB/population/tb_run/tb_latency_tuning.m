%% Latency Tuning
sigCh= find(cell2mat(compare.sponRsp(CR_Ref).H) & cell2mat(S1H));
nSigCh = find(~(cell2mat(compare.sponRsp(CR_Ref).H) & cell2mat(S1H)));

compare.CR_SigCHs = sigCh;
compare.CR_noSigCHs = nSigCh;
for wIndex = 1 : length(latency)
    % resample
    tempMean = [latency(wIndex).CR(compareIdx).mean]';
    tempSE = [latency(wIndex).CR(compareIdx).se]';
    compare.latency_CR(wIndex).Win = latency(wIndex).Win;
    compare.latency_CR(wIndex).NP = latency(wIndex).NP;
    compare.latency_CR(wIndex).Sig = [(1:length(compareIdx))', reshape([tempMean(:, sigCh); tempSE(:, sigCh)], length(compareIdx), [])];
    compare.latency_CR(wIndex).SigMean = [(1:length(compareIdx))', mean(tempMean(:, sigCh), 2)];
    compare.latency_CR(wIndex).noSig = [(1:length(compareIdx))', reshape([tempMean(:, nSigCh); tempSE(:, nSigCh)], length(compareIdx), [])];
    compare.latency_CR(wIndex).noSigMean = [(1:length(compareIdx))', mean(tempMean(:, nSigCh), 2)];
    % single
    tempMean = [latencySingle(wIndex).CR(compareIdx).mean]';
    tempSE = [latencySingle(wIndex).CR(compareIdx).se]';
    compare.latencySingle_CR(wIndex).Win = latency(wIndex).Win;
    compare.latencySingle_CR(wIndex).NP = latency(wIndex).NP;
    compare.latencySingle_CR(wIndex).Sig = [(1:length(compareIdx))', reshape([tempMean(:, sigCh); tempSE(:, sigCh)], length(compareIdx), [])];
    compare.latencySingle_CR(wIndex).SigMean = [(1:length(compareIdx))', mean(tempMean(:, sigCh), 2)];
    compare.latencySingle_CR(wIndex).noSig = [(1:length(compareIdx))', reshape([tempMean(:, nSigCh); tempSE(:, nSigCh)], length(compareIdx), [])];
    compare.latencySingle_CR(wIndex).noSigMean = [(1:length(compareIdx))', mean(tempMean(:, nSigCh), 2)];

%     tempMean = [latency(wIndex).OR(compareIdx).mean]';
%     tempSE = [latency(wIndex).OR(compareIdx).se]';
%     compare.latency_OR(wIndex).Win = latency(wIndex).Win;
%     compare.latency_OR(wIndex).NP = latency(wIndex).NP;
%     compare.latency_OR(wIndex).Sig = [(1:length(compareIdx))', reshape([tempMean(:, sigCh); tempSE(:, sigCh)], length(compareIdx), [])];
%     compare.latency_OR(wIndex).SigMean = [(1:length(compareIdx))', mean(tempMean(:, sigCh), 2)];
%     compare.latency_OR(wIndex).noSig = [(1:length(compareIdx))', reshape([tempMean(:, nSigCh); tempSE(:, nSigCh)], length(compareIdx), [])];
%     compare.latency_OR(wIndex).noSigMean = [(1:length(compareIdx))', mean(tempMean(:, nSigCh), 2)];
end