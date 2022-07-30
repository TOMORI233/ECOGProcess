function Res = deleteWrongTrial(trial, protocolName)
switch protocolName
    case "ClickTrainOddCompare"
        validPair = [1 1; 1 5; 6 6; 6 10; 19 19; 19 20];
    case "ClickTrainOddCompareTone"
        validPair = [1 1; 1 2; 4 4; 4 5; 6 6; 6 7; 9 9; 9 10; 21 21; 21 22; 23 23; 23 24];
    case "ClickTrainOddICIThr"
        validPair = [1 1; 1 2; 1 3;1 4; 1 5];
        
end
saveIndex = ismember([[trial.stdOrdr]' [trial.devOrdr]'], validPair, "rows");
Res = trial(saveIndex);

end