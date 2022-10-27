function [P, H] = mAnova1(trialData, labels, alpha, sigVal)
% Description: conduct anova1 sample by sample
% Input:
%     trialData: m*n array with m trials by n sample points from a certain channel or IC
%     label: corresponding to m trials
%     alpha: confidence interval, if p-value is lower than alpha, the
% Output:
%     P: p-value of each sample point
%     H: p < alpha, then H = 1, else, H = 0;
narginchk(2, 4);
if nargin < 3
    alpha = 0.05;
    sigVal = 1;
end

if nargin < 4
    sigVal = 1;
end

P = zeros(size(trialData, 2), 1);
H = ones(size(trialData, 2), 1) * -100;
for sN = 1 : size(trialData, 2)
    P(sN, 1) = anova1(trialData(:,sN), labels, "off");
    clc;
    disp(strcat("conducting anova1 ---- ", num2str(sN), "/", num2str(size(trialData, 2)), "----"));
end
clc;
disp(strcat("---- done! ----"));
H((P < alpha), 1) = sigVal;
end

    