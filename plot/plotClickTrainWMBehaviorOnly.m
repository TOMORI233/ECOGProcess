function [Fig, mAxe] = plotClickTrainWMBehaviorOnly(trials, color, legendStr, xticklabelStr,  Fig, mAxe)
narginchk(3, 6);
margins = [0.1, 0.1, 0.1, 0.1];
if nargin < 4
    xticklabelStr = {'4','4.01','4.03','4.05','4.07'};
end
if nargin < 5
    Fig = figure;
end

if nargin == 5
    error("The number of input params should be 1 or 3");
end


diffPairs = [[trials.stdOrdr]' [trials.devOrdr]'];
diffPairsUnique = unique(diffPairs, 'rows');

nPush = [];
nTotal = [];

maximizeFig(Fig);

for dIndex = 1:size(diffPairsUnique, 1)
    temp = trials(all(diffPairs == diffPairsUnique(dIndex, :), 2) & [trials.interrupt]' == false);
    nTotal = [nTotal, length(temp)];
    nPush = [nPush, length([temp.firstPush])];
    RT = cell2mat(cellfun(@(x, y) x - y, {temp.firstPush}, {temp.devOnset}, 'UniformOutput', false));

    if nargin < 6
        mAxe(dIndex + 1) = mSubplot(Fig, length(diffPairsUnique), 4, 4 * dIndex, [1, 1], [0.1, 0.1, 0.15, 0.15]);
    end

    scatter(mAxe(dIndex + 1), RT, 1:length(RT), 40, color, "filled");
    hold on;
    meanRT = mean(RT);
    yaxis = get(mAxe(dIndex + 1), "YLim");
    stem(mAxe(dIndex + 1), meanRT, yaxis(2), "Color", color, "LineStyle", "-", "LineWidth", 1.5);
    title(mAxe(dIndex + 1), [xticklabelStr{dIndex}, ' (Mean RT ', num2str(roundn(meanRT, -2)), ' ms)']);
    xlim(mAxe(dIndex + 1), [0, 800]);
    if dIndex == size(diffPairsUnique, 1)
        xlabel(mAxe(dIndex + 1), 'Reaction Time (ms)');
    end
end

if nargin < 6
    mAxe(1) = mSubplot(Fig, 2, 2, 1, [1, 1], margins);
end
pairIdx = (1:size(diffPairsUnique, 1))'; ratio = nPush ./ nTotal;
controlIdx = diffPairsUnique(:,1) == diffPairsUnique(:,2) ;

b = bar(mAxe(1), [pairIdx(controlIdx) pairIdx(~controlIdx)] , [ratio(controlIdx)' ratio(~controlIdx)'] );
b(1).FaceColor = [0 0 0]; b(1).BarWidth = 2;
b(2).FaceColor = [1 0 0]; b(2).BarWidth = 2;

hold on;
if length(diffPairsUnique) >= length(mAxe(1).XTick) || nargin < 5
    xticks(1:length(diffPairsUnique));
    xticklabels(xticklabelStr);
end
xlim([0 size(diffPairsUnique, 1) + 1]);
ylim([0 1]);
yticks(0:0.2:1);
xlabel("S1-S2 pairs");
ylabel("Push Ratio");
title('ClickTrain Working Memory Task');
legend(legendStr, "location", "northwest");

for index = 1:length(nPush)
    text(mAxe(1), index, nPush(index) / nTotal(index) + 0.05, [num2str(nPush(index)), '/', num2str(nTotal(index))]);
end

% chi2test with reg control
nNoPush = nTotal - nPush;
for index = 2 : length(pairIdx)
    temp = [nTotal(1), nNoPush(1); nTotal(index), nNoPush(index)];
    p(index) = chi2test(temp);
    text(mAxe(1), index, nPush(index) / nTotal(index) + 0.1, strcat("p=", num2str(p(index))));
end


return;
end