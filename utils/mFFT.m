function [f, Pow, P] = mFFT(signal, Fs)
rowN = size(signal, 1);
L = size(signal, 2);
fL = length(0:ceil(L/2));
Pow = zeros(rowN, fL);
P = zeros(rowN, fL);
for i = 1 : rowN
    signalTemp = signal(rowN, :);
    Y = fft(signalTemp);
    P2 = abs(Y/L);
    P1 = P2(1:ceil(L/2)+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = Fs*(0:ceil(L/2))/L;
    Pow(rowN, :) = pow2db(P1);
    P(rowN, :) = P1;
end
end

