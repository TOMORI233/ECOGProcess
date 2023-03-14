%% post-hoc CRI
CRIs = reshape(compare.CRI_SigMean(:, 2:end)', [], 1);
groups =  reshape(repmat(compare.CRI_SigMean(:, 1), 1, size(compare.CRI_SigMean(:, 2:end), 2))', [], 1);
[anovaP, ~, stats] = anova1(CRIs, groups, "off");
C = multcompare(stats, "Display", "off");
stimStrs = flip(stimStrs);
postHocRes = [stimStrs(C(:, 1:2)), C(:, 6), C(:, 6) < 0.05];
postHocRes = cell2struct(cellstr(postHocRes), ["G1", "G2", "p", "significant"], 2);