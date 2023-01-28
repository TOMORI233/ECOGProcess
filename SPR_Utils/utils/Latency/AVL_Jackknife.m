function [avl_mean, avl_se, avl_jackknife] = AVL_Jackknife(data, time, chNP)

% Number of trials
n_trials = size(data,1);

% Preallocate memory for the jackknife replicates
avl_jackknife = zeros(n_trials, 1);

% Loop over the trials to compute the jackknife replicates
for i = 1:n_trials
    % Select all trials except the current trial
    data_jackknife = data;
    data_jackknife(i,:) = [];
    
    % Compute the AVL for the current jackknife replicate
    data_mean = mean(data_jackknife,1);
    if chNP > 0
        [~, idx] = mink(data_mean, 5);
        idx = min(idx);
    else
        [~, idx] = maxk(data_mean, 5);
        idx = min(idx);
    end
    avl_jackknife(i) = time(idx);
end

% Compute the mean avl
avl_mean = mean(avl_jackknife);

% % Compute the jackknife estimate of the variance
% avl_var = (n_trials-1) * var(avl_jackknife);

% Compute the jackknife estimate of the standard error
avl_se = std(avl_jackknife)/sqrt(length(avl_mean));

% Print the jackknife estimate of the standard error
% disp(['Jackknife estimate of the standard error of the AVL: ' num2str(avl_se) ' ms']);

end