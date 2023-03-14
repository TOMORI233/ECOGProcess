function [fal_mean, fal_se, fal_jackknife] = FAL_Jackknife(data, t, testWin, sponWin, chNP, fraction, thrFrac, sigma, smthBin )
narginchk(5, 9);

if nargin < 6
    % Define the fraction for the FAL (e.g., 0.5 for 50% of the area under the curve)
    fraction = 0.5;
end
if nargin < 7
    thrFrac = 0.3;
end
tIndex = t >= testWin(1) & t <= testWin(2);
sponIndex = t >= sponWin(1) & t <= sponWin(2);
% Number of trials
n_trials = size(data,1);

% Preallocate memory for the jackknife replicates
fal_jackknife = zeros(n_trials, 1);

% Loop over the trials to compute the jackknife replicates
for i = 1:n_trials
    % Select all trials except the current trial
    data_jackknife = data;
    data_jackknife(i,:) = [];

    % Compute the FAL for the current jackknife replicate
    if n_trials > 1
        data_mean = mean(data_jackknife,1);
    else
        data_mean = data;
    end

    [~, area_under_curve, data_mean] = AreaAboveThr(data_mean, time, chNP, thrFrac);
    %     area_under_curve = trapz(time, data_mean);

    area_fraction = cumtrapz(time, data_mean);
    [~, idx] = find(area_fraction >= area_under_curve*fraction, 1, "first");
    fal_jackknife(i) = time(idx);
end

% Compute the mean fal
fal_mean = mean(fal_jackknife);

% % Compute the jackknife estimate of the variance
% fal_var = (n_trials-1) * var(fal_jackknife);

% Compute the jackknife estimate of the standard error
fal_se = std(fal_jackknife)/sqrt(length(fal_mean));

% Print the jackknife estimate of the standard error
% disp(['Jackknife estimate of the standard error of the FAL: ' num2str(fal_se) ' ms']);
