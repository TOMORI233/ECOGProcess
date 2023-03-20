%% post-hoc CRI
CRIs = reshape(compare.CRI_SigMean(:, 2:end)', [], 1);
groups =  reshape(repmat(compare.CRI_SigMean(:, 1), 1, size(compare.CRI_SigMean(:, 2:end), 2))', [], 1);
anovaP(1).Info = "CRI";
[anovaP(1).Res, ~, stats] = anova1(CRIs, groups, "off");
C = multcompare(stats, "Display", "off");
if matches(Protocol, ["DiffICI_Merge", "Basic_IrregVar"])
    stimStrs = flip(stimStrs);
elseif matches(Protocol, "Basic_ICIThr")
    stimStrs = stimStrs([1, 3, 2, 4]);
end
postHocRes(1).Info = "CRI";
temp = [stimStrs(C(:, 1:2)), C(:, 6), C(:, 6) < 0.05];
postHocRes(1).Res = cell2struct(cellstr(temp), ["G1", "G2", "p", "significant"], 2);

%% post-hoc latency
latencys = reshape(compare.latency_CR(2).Sig(:, 2:2:end)', [], 1);
groups =  reshape(repmat(compare.latency_CR(2).Sig(:, 1), 1, size(compare.latency_CR(2).Sig(:, 2:2:end), 2))', [], 1);
anovaP(2).Info = "latency";
[anovaP(2).Res, ~, stats] = anova1(latencys, groups, "off");
C = multcompare(stats, "Display", "off");

postHocRes(2).Info = "latency";
temp = [stimStrs(C(:, 1:2)), C(:, 6), C(:, 6) < 0.05];
postHocRes(2).Res = cell2struct(cellstr(temp), ["G1", "G2", "p", "significant"], 2);

%% post-hoc RMS
RMSs = reshape(compare.RMS_Boot_SigMean(:, 2:end)', [], 1);
groups =  reshape(repmat(compare.RMS_Boot_SigMean(:, 1), 1, size(compare.RMS_Boot_SigMean(:, 2:end), 2))', [], 1);
anovaP(3).Info = "RMS_Boot";
[anovaP(3).Res, ~, stats] = anova1(RMSs, groups, "off");
C = multcompare(stats, "Display", "off");
if matches(Protocol, ["DiffICI_Merge", "Basic_IrregVar"])
    stimStrs = flip(stimStrs);
elseif matches(Protocol, "Basic_ICIThr")
    stimStrs = stimStrs([1, 3, 2, 4]);
end
postHocRes(3).Info = "RMS_Boot";
temp = [stimStrs(C(:, 1:2)), C(:, 6), C(:, 6) < 0.05];
postHocRes(3).Res = cell2struct(cellstr(temp), ["G1", "G2", "p", "significant"], 2);