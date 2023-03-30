function [trialsECoG, chIdx, idx] = excludeTrialsChs(trialsECoG, th, window, testWin)
    % Description: exclude trials away from mean level, and return index of
    %              bad channels
    % Input:
    %     trialsECoG: n*1 cell array of trial data (64*m matrix)
    %     th: trials whose proportion of sample points that the value is
    %         above th will be labeled as bad trial
    %     window: window that corresponds to size of trialsECoG
    %     testWin: the range should be in the window, for channel excluding
    % Output:
    %     chIdx: the index of bad channels
narginchk(2, 4);
temp = changeCellRowNum(trialsECoG);
chMean = cell2mat(cellfun(@mean, temp, "UniformOutput", false));

if nargin > 3
    t = linspace(window(1), window(2), size(chMean, 2));
    testChMean = chMean(:, t > testWin(1) & t < testWin(2));
elseif nargin < 3
    testChMean = chMean;
else
    error("please give the testWin to decide the range for excluding!");
end

testStd = std(testChMean, 1, 2);
chIdx = (1 : size(testChMean, 1))';
curDel = find(testStd > mean(testStd) + 3 * std(testStd));
deleteCh = [];
while length(deleteCh) ~= length(curDel)
    deleteCh = curDel;
    chIdx = ~ismember(1 : size(chMean, 1), deleteCh)';
    curDel = find(testStd > mean(testStd(chIdx)) + 3 * std(testStd(chIdx)));
end


temp = changeCellRowNum(trialsECoG);
temp = temp(chIdx);
trialsEEGTemp = changeCellRowNum(temp);
chMean = cell2mat(cellfun(@mean, temp, "UniformOutput", false));
chStd = cell2mat(cellfun(@std, temp, "UniformOutput", false));
idx = cellfun(@(x) sum(x > chMean + 3 * chStd | x < chMean - 3 * chStd, 2) / size(x, 2), trialsEEGTemp, "UniformOutput", false);
idxAmp = cellfun(@(x) sum(x > chMean + 8 * chStd | x < chMean - 8 * chStd, 2), trialsEEGTemp, "UniformOutput", false);

idx = cellfun(@(x, y) ~any(x > th | y > 10), idx, idxAmp);
if ~isempty(find(~idx, 1))
    disp(['Trial ', num2str(find(~idx)'), ' are excluded.']);
else
    disp('All pass');
end
trialsECoG = trialsECoG(idx);

return;
end
