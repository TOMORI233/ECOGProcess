function [avl_mean, avl_se, avl_ByTrials] = AVL_ByTrials2(data, t, testWin, sponWin, chNP, stdFrac, sigma, smthBin)
narginchk(6, 8);

tIndex = t >= testWin(1) & t <= testWin(2);
time = t(tIndex);
sponIndex = t >= sponWin(1) & t <= sponWin(2);
% Number of trials


% Loop over the trials to compute the jackknife replicates
if nargin > 7
    data_mean = mGaussionSmth(data, sigma, smthBin, 2);
end

%     data_mean = data_mean - mean(data_mean(sponIndex));


if chNP > 0
    if ~isempty(stdFrac)
        data_mean(data_mean < stdFrac*std(data_mean(:, sponIndex), 1, 2)) = 0;
    end
    [~, idx] = rowFcn(@(x) findpeaks(x(tIndex)), data_mean, "UniformOutput", false);
    idx = cell2mat(cellfun(@(x) min([x, length(time)]), idx, "UniformOutput", false));
else
    if ~isempty(stdFrac)
        data_mean(data_mean > -stdFrac*std(data_mean(:, sponIndex), 1, 2)) = 0;
    end
    [~, idx] = rowFcn(@(x) findpeaks(x(tIndex)), -1*data_mean, "UniformOutput", false);
    idx = cell2mat(cellfun(@(x) min([x, length(time)]), idx, "UniformOutput", false));
end

avl_ByTrials = time(idx);





% Compute the mean avl
avl_mean = mean(avl_ByTrials);

% % Compute the jackknife estimate of the variance
% avl_var = (n_trials-1) * var(avl_jackknife);

% Compute the jackknife estimate of the standard error
avl_se = std(avl_ByTrials)/sqrt(length(avl_ByTrials));

% Print the jackknife estimate of the standard error
% disp(['Jackknife estimate of the standard error of the AVL: ' num2str(avl_se) ' ms']);

end