function amp = waveAmp(wave, window, fs, method)
% method: 1, rms; 2, area; 3, peak or trough; 4, mean
narginchk(3, 4);
if nargin < 4
    method = 1; % rms
end
tIndex = (1 : size(wave, 2)) / fs >= window(1)/1000 & (1 : size(wave, 2)) / fs <= window(2)/1000;
temp = wave(:, tIndex);
switch method
    case 1 % rms
        amp = rms(temp, 2);
    case 2 % area
        amp = sum(abs(temp), 2) / diff(window);
    case 3 % peak
        amp = max(temp, [], 2);
    case 4 % trough
        amp = min(temp, [], 2);
    case 5 % mean
        amp = mean(temp, 2);
end
end
