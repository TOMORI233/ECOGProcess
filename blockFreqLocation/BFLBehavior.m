function FigBehavior = BFLBehavior(trialAll)

block1Idx = mod([trialAll.trialNum]', 80) >= 1 & mod([trialAll.trialNum]', 80) <= 20;
block2Idx = mod([trialAll.trialNum]', 80) >= 21 & mod([trialAll.trialNum]', 80) <= 40;
block3Idx = mod([trialAll.trialNum]' - 1, 80) >= 40 & mod([trialAll.trialNum]', 80) <= 79;
stdFreq = unique([trialAll([trialAll.oddballType]' == "STD").devFreq]);
stdLoc = unique([trialAll([trialAll.oddballType]' == "STD").devLoc]);
trialsBlkFreq = trialAll([trialAll.devLoc]' == stdLoc & block1Idx);
trialsRandFreq = trialAll([trialAll.devLoc]' == stdLoc & block3Idx);
trialsBlkLoc = trialAll([trialAll.devFreq]' == stdFreq & block2Idx);
trialsRandLoc = trialAll([trialAll.devFreq]' == stdFreq & block3Idx);

[FigBehavior, mAxe, ~, ~] = plotBehaviorOnly(trialsBlkFreq, "r", "block freq");
[FigBehavior, mAxe, ~, ~] = plotBehaviorOnly(trialsRandFreq, "m", "rand freq", FigBehavior, mAxe, "freq");
[FigBehavior, mAxe, ~, ~] = plotBehaviorOnly(trialsBlkLoc, "b", "block loc", FigBehavior, mAxe, "loc");
[FigBehavior, ~, ~, ~] = plotBehaviorOnly(trialsRandLoc, "k", "rand loc", FigBehavior, mAxe, "loc");

drawnow;
end