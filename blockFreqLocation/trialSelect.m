block1Idx = mod([trialAll.trialNum]', 80) >= 1 & mod([trialAll.trialNum]', 80) <= 20;
block2Idx = mod([trialAll.trialNum]', 80) >= 21 & mod([trialAll.trialNum]', 80) <= 40;
block3Idx = mod([trialAll.trialNum]' - 1, 80) >= 40 & mod([trialAll.trialNum]', 80) <= 79;

block1IdxP = mod([trialAll.trialNum]', 80) >= 5 & mod([trialAll.trialNum]', 80) <= 20;
block2IdxP = mod([trialAll.trialNum]', 80) >= 25 & mod([trialAll.trialNum]', 80) <= 40;
block3IdxP = mod([trialAll.trialNum]' - 1, 80) >= 50 & mod([trialAll.trialNum]', 80) <= 79;

stdFreq = unique([trialAll([trialAll.oddballType]' == "STD").devFreq]);
stdLoc = unique([trialAll([trialAll.oddballType]' == "STD").devLoc]);

trialsBlkFreq = trialAll([trialAll.devLoc]' == stdLoc & block1Idx);
trialsRandFreq = trialAll([trialAll.devLoc]' == stdLoc & block3Idx);
trialsBlkLoc = trialAll([trialAll.devFreq]' == stdFreq & block2Idx);
trialsRandLoc = trialAll([trialAll.devFreq]' == stdFreq & block3Idx);

trialsBlkFreqP = trialAll([trialAll.devLoc]' == stdLoc & block1IdxP);
trialsBlkLocP = trialAll([trialAll.devFreq]' == stdFreq & block2Idx);
trialsRandP = trialAll([trialAll.oddballType]' ~= "INTERRUPT" & block3Idx);


devType = [trialAll.devType]';
dRatio = unique(devType(([trialAll.devType]' > 0)));

trialTypes.All = ["trialAll", "trialsBlkFreq", "trialsRandFreq", "trialsBlkLoc", "trialsRandLoc", ...
    "trialsBlkFreqP", "trialsBlkLocP", "trialsRandP"];

trialTypes.DM = ["trialsBlkFreq", "trialsRandFreq", "trialsBlkLoc", "trialsRandLoc"];
trialTypes.PE = ["trialsBlkFreq", "trialsRandFreq", "trialsBlkLoc", "trialsRandLoc"];
trialTypes.P = ["trialsBlkFreqP", "trialsBlkLocP", "trialsRandP"];
trialTypes.Push = ["trialsBlkFreq", "trialsRandFreq", "trialsBlkLoc", "trialsRandLoc"];
