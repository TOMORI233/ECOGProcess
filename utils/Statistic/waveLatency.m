function latency = waveLatency(wave, window, fs, ratio) 
    tIndex = (1 : size(wave, 2)) / fs >= window(1)/1000 & (1 : size(wave, 2)) / fs <= window(2)/1000;
    temp = cumsum(abs(wave(:, tIndex)), 2);
    for i = 1 : size(wave, 1)
        [~, ~, latency(i, 1)] = findZeroPoint(temp(i, :) - temp(i, end) * ratio);
    end
    latency = latency / fs * 1000 + window(1);
end