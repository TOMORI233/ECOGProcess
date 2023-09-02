function [f, Pow, P] = mFFT_Base(signal, Fs, fRange)
narginchk(2,3);
rowN = size(signal, 1);
L = size(signal, 2);
fL = length(0:ceil(L/2));
Pow = zeros(rowN, fL);
P = zeros(rowN, fL);
for i = 1 : rowN
    signalTemp = signal(i, :);
    Y = fft(signalTemp);
    P2 = abs(Y/L);
    P1 = P2(1:ceil(L/2)+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = Fs*(0 : ceil(L/2))/L;
    P(i, :) = P1(1 : ceil(L/2) + 1);
    Pow(i, :) = pow2db(P(i, :));
end
if nargin > 2
    Pow = findWithinWindow(Pow, f, fRange);
    P = findWithinWindow(P, f, fRange);
    f = findWithinInterval(f', fRange);
end
end