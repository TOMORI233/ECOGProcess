
% badCH
trialsECOG_Merge = interpolateBadChs(trialsECOG_Merge,  badCHs);
trialsECOG_S1_Merge = interpolateBadChs(trialsECOG_S1_Merge, badCHs);

try
trialsECOG_Merge_Filtered = ECOGFilter(trialsECOG_Merge, fhp, flp, fs);
catch
end