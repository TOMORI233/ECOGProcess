function FigBehavior = BFLBehavior(trialAll)

run("trialSelect.m");

[FigBehavior, mAxe, ~, ~] = plotBehaviorOnly(trialsBlkFreq, "r", "block freq");
[FigBehavior, mAxe, ~, ~] = plotBehaviorOnly(trialsRandFreq, "m", "rand freq", FigBehavior, mAxe, "freq");
[FigBehavior, mAxe, ~, ~] = plotBehaviorOnly(trialsBlkLoc, "b", "block loc", FigBehavior, mAxe, "loc");
[FigBehavior, ~, ~, ~] = plotBehaviorOnly(trialsRandLoc, "k", "rand loc", FigBehavior, mAxe, "loc");

drawnow;
end