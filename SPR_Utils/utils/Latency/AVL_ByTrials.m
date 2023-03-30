function [avl_mean, avl_se, avl_ByTrials] = AVL_ByTrials(data, t, testWin, sponWin, chNP, stdFrac, sigma, smthBin)
narginchk(6, 8);

tIndex = t >= testWin(1) & t <= testWin(2);
time = t(tIndex);
sponIndex = t >= sponWin(1) & t <= sponWin(2);
% Number of trials
n_trials = size(data,1);

% Preallocate memory for the jackknife replicates
avl_ByTrials = zeros(n_trials, 1);

% Loop over the trials to compute the jackknife replicates
for i = 1:n_trials
    % Select all trials except the current trial
    data_mean = data(i, :);
    if nargin > 7
    data_mean = mGaussionSmth(data_mean, sigma, smthBin, 2);
    end

%     data_mean = data_mean - mean(data_mean(sponIndex));
    

    if chNP > 0
        if ~isempty(stdFrac)
            data_mean(data_mean < stdFrac*std(data_mean(sponIndex))) = 0;
        end
        idx = findPeakTrough(data_mean(tIndex));
        idx = find(idx, 1);
    else
        if ~isempty(stdFrac)
            data_mean(data_mean > -stdFrac*std(data_mean(sponIndex))) = 0;
        end
        [~, idx] = findPeakTrough(data_mean(tIndex));
        idx = find(idx, 1);
    end
    if ~isempty(idx)
        avl_ByTrials(i) = time(idx);
    else
        avl_ByTrials(i) = testWin(2);
    end
   
end

% Compute the mean avl
avl_mean = mean(avl_ByTrials);

% % Compute the jackknife estimate of the variance
% avl_var = (n_trials-1) * var(avl_jackknife);

% Compute the jackknife estimate of the standard error
avl_se = std(avl_ByTrials)/sqrt(length(avl_ByTrials));

% Print the jackknife estimate of the standard error
% disp(['Jackknife estimate of the standard error of the AVL: ' num2str(avl_se) ' ms']);

end