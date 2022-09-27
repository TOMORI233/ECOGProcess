clc; clear;
% BLOCKPATH = {'D:\ECoG\xiaoxiao\xx20220831\Block-5';...
%     'D:\ECoG\xiaoxiao\xx20220903\Block-1';...
%     'D:\ECoG\xiaoxiao\xx20220905\Block-1';...
%     'D:\ECoG\xiaoxiao\xx20220906\Block-6';...
%     'D:\ECoG\xiaoxiao\xx20220907\Block-1';...
%     };
BLOCKPATH = {
%     'D:\ECoG\chouchou\cc20220901\Block-1';...
%     'D:\ECoG\chouchou\cc20220903\Block-1';...
    'D:\ECoG\chouchou\cc20220905\Block-1';...
    'D:\ECoG\chouchou\cc20220907\Block-1';...
%     'D:\ECoG\chouchou\cc20220912\Block-1';...
    };
choiceWin = [100, 800]; % ms
trialAll = [];
for blks = 1 : length(BLOCKPATH)
    temp = TDTbin2mat(BLOCKPATH{blks}, 'TYPE', {'epocs'});
    epocs = temp.epocs;
    trials = ActiveProcess_freqLoc(epocs, choiceWin);
    trialAll = [trialAll; trials];
end

block1Idx = mod([trialAll.trialNum]', 80) >= 1 & mod([trialAll.trialNum]', 80) <= 20;
block2Idx = mod([trialAll.trialNum]', 80) >= 21 & mod([trialAll.trialNum]', 80) <= 40;
block3Idx = mod([trialAll.trialNum]' - 1, 80) >= 40 & mod([trialAll.trialNum]', 80) <= 79;

stdFreq = unique([trialAll([trialAll.oddballType]' == "STD").devFreq]);
stdLoc = unique([trialAll([trialAll.oddballType]' == "STD").devLoc]);
trialsBlkFreq = trialAll([trialAll.devLoc]' == stdLoc & block1Idx);
trialsRandFreq = trialAll([trialAll.devLoc]' == stdLoc & block3Idx);
trialsBlkLoc = trialAll([trialAll.devFreq]' == stdFreq & block2Idx);
trialsRandLoc = trialAll([trialAll.devFreq]' == stdFreq & block3Idx);
[Fig, mAxe, blkFreqPush, blkFreqTotal] = plotBehaviorOnly(trialsBlkFreq, "r", "block freq");
[Fig, mAxe, randFreqPush, randFreqTotal] = plotBehaviorOnly(trialsRandFreq, "m", "rand freq", Fig, mAxe, "freq");
[Fig, mAxe, blkLocPush, blkLocTotal] = plotBehaviorOnly(trialsBlkLoc, "b", "block loc", Fig, mAxe, "loc");
[Fig, mAxe, randLocPush, randLocTotal] = plotBehaviorOnly(trialsRandLoc, "k", "rand loc", Fig, mAxe, "loc");

%% chi2test between block and random for freq deviant and loc deviant seperately
for diff = 1 : length(randLocTotal)
    pFreq(diff) = chi2test([blkFreqPush(diff), blkFreqTotal(diff) - blkFreqPush(diff); randFreqPush(diff), randFreqTotal(diff) - randFreqPush(diff)]);
    pLoc(diff) = chi2test([blkLocPush(diff), blkLocTotal(diff) - blkLocPush(diff); randLocPush(diff), randLocTotal(diff) - randLocPush(diff)]);
end

