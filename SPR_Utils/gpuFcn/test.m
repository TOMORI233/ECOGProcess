fs = 500;
t = 1 : 5001;
wave = repmat(sin(2*pi*fs* t), 64, 1);
waveCell = repmat({wave}, 100, 1);
[a0, b0] = cwtMean(wave', fs, [0 10]);
[a, b] = cwtMean_mex(wave', fs, [0 10]);
x = gather(a);