function [normAmp, amp, rmsSpon] = waveAmp_Norm(wave, window, testWin, method, sponWin)
% method: 1, rms; 2, area; 3, peak or trough; 4, mean
narginchk(3, 5);
if nargin < 4
    method = 1; % rms
    rmsSpon = 1;
    sponWin = [];
end

if nargin < 5 || isempty(sponWin)
    rmsSpon = 1;
    sponWin = [];
end
t = linspace(window(1), window(2), size(wave, 2));

if ~isempty(sponWin)
    tIndex = t > sponWin(1) & t < sponWin(2);
    temp = wave(:, tIndex);
    rmsSpon = rms(temp, 2);
end

tIndex = t > testWin(1) & t < testWin(2);
temp = wave(:, tIndex);
amp = rms(temp, 2);

% switch method
%     case 1 % rms
%         amp = rms(temp, 2);
%     case 2 % area
%         amp = sum(abs(temp), 2) / diff(window);
%     case 3 % peak
%         amp = max(temp, [], 2);
%     case 4 % trough
%         amp = min(temp, [], 2);
%     case 5 % mean
%         amp = mean(temp, 2);
% end


switch method
    case 1 % Resp_devided_by_Spon
        normAmp = amp./rmsSpon;
    case 2 % R_minus_S_devide_R_plus_S
        normAmp = (amp - rmsSpon) ./ rmsSpon;
end

