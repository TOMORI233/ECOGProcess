%% compare S1Res and spon
if strcmpi(Protocol, "DiffICI_Merge")
    trials_S1_Temp = trialsECOG_S1_Merge([trialAll.devOrdr]' == 1);
    [~, ampS1, rmsSponS1] = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trials_S1_Temp, 'UniformOutput', false);
else
    [~, ampS1, rmsSponS1] = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trialsECOG_S1_Merge, 'UniformOutput', false);
end
[S1H, S1P] = cellfun(@(x, y) ttest(x, y), changeCellRowNum(ampS1), changeCellRowNum(rmsSponS1), "UniformOutput", false);
S1H = cellfun(@(x) replaceVal(x, 0, @isnan), S1H, "UniformOutput", false );
compare.OR_SigCHs = find(cell2mat(S1H));
compare.OR_SigCHs = find(~cell2mat(S1H));