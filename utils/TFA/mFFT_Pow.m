function [f, Pow, P] = mFFT_Pow(signal, Fs)
rowN = size(signal, 1);
L = size(signal, 2);
fL = length(0:ceil(L/2));
Pow = zeros(rowN, fL);
P = zeros(rowN, fL);
for i = 1 : rowN
    signalTemp = signal(i, :);
    Y = fft(signalTemp);
%     temp = fftshift(Y); 
    power = abs(Y).^2/L; 
    f = Fs*(0 : ceil(L/2))/L;
    P(i, :) = power(1 : ceil(L/2) + 1);
    Pow(i, :) = pow2db(P(i, :));
    
end
end

