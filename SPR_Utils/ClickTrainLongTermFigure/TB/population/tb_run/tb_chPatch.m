
%% Patch
temp = changeCellRowNum(trialsECOG_Merge);
temp = temp(ECOGSitePatch(AREANAME));
trialsECOG_Merge = changeCellRowNum(temp);

temp = changeCellRowNum(trialsECOG_S1_Merge);
temp = temp(ECOGSitePatch(AREANAME));
trialsECOG_S1_Merge = changeCellRowNum(temp);


