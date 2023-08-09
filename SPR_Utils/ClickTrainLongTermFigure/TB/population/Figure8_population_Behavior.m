%% Data loading
clear; clc; close all;
%% chouchou
BLOCKPATH{1} = 'E:\ECoG\chouchou\cc20220816\Block-1';
BLOCKPATH{2} = 'E:\ECoG\chouchou\cc20220817\Block-1';
BLOCKPATH{3} = 'E:\ECoG\chouchou\cc20220819\Block-4';
BLOCKPATH{4} = 'E:\ECoG\chouchou\cc20220822\Block-1';
BLOCKPATH{5} = 'E:\ECoG\chouchou\cc20220823\Block-1';
BLOCKPATH{6} = 'E:\ECoG\chouchou\cc20220824\Block-1';

% %% xiaoxiao
% 
% BLOCKPATH{1} = 'G:\ECoG\xiaoxiao\xx20221124\Block-1';
% BLOCKPATH{2} = 'G:\ECoG\xiaoxiao\xx20221128\Block-1';
% BLOCKPATH{3} = 'G:\ECoG\xiaoxiao\xx20221129\Block-1';
% BLOCKPATH{4} = 'G:\ECoG\xiaoxiao\xx20221216\Block-1';
% BLOCKPATH{5} = 'G:\ECoG\xiaoxiao\xx20221221\Block-1';

x = [1,2, 4,5, 7,8, 10,11];
stimArray = repmat(x, length(BLOCKPATH), 1);
pushRate = zeros(length(BLOCKPATH), length(x));
for bIndex = 1 : length(BLOCKPATH)
temp = TDTbin2mat(BLOCKPATH{bIndex}, 'TYPE', {'epocs'});
epocs = temp.epocs;

choiceWin = [100, 600]; % ms
% click train compare tone
pairStr = {'4-4.08RC','4-4.08RD', '4-4.08IC','4-4.08ID','250-250Hz','250-245Hz','250-250Hz','250-200Hz'};

trialAll = ActiveProcess_clickTrainWM(epocs, choiceWin);
trialAll = trialAll(2:end);
trialsNoInterrupt = trialAll([trialAll.interrupt] == false);
% trials = deleteWrongTrial(trialsNoInterrupt, "ClickTrainOddCompareTone");
trials = trialsNoInterrupt;



[Fig(bIndex), ~, nPush, nTrial] = plotClickTrainWMBehaviorOnly(trials, "k", {'control', 'dev'},pairStr);

pushRate(bIndex, :) = (nPush ./ nTrial);
drawnow;
end

pushRate = reshape([stimArray; pushRate], length(BLOCKPATH), []);

mean_PushRate = mean(pushRate, 1);
std_PushRate = std(pushRate, 1, 1);

stimStrs = ["Reg4", "Reg4-4.08", "Irreg4", "Irreg4-4.08", "Tone250", "Tone250-246", "Tone250", "Tone250-200"];
for i = 1 : 4
    [P(i,1), H(i,1)] = ranksum(pushRate(:, 4*i-2), pushRate(:, 4*i));
    G1(i,1) = stimStrs(2*i-1);
    G2(i,1) = stimStrs(2*i);
end
rankSumRes = cell2struct(cellstr([G1, G2, P, H]), ["G1", "G2", "P", "significant"], 2);
