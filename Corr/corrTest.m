clear; clc; close all;

fs = 1e3;
t = 0:1/fs:1;
n_shift = (-100:100)';

res = zeros(length(n_shift), 1);

for index = 1:length(n_shift)
    y1 = sin(2*pi*10*t) + 0.5 * sin(2*pi*2*t) + 0.5 * rand(1, length(t));
    y2 = sin(2*pi*10*(t - index / fs)) + 0.5 * rand(1, length(t));

    if index == 1
        figure;
        plot(t, y1, 'r', 'DisplayName', 'y1');
        hold on;
        plot(t, y2, 'b', 'DisplayName', 'y2');
        legend;
    end

    res(index) = corrAnalysis(y1, y2);
end

% tb = table(n_shift, res);
% disp(tb);

figure;
plot(n_shift, res);
xlabel('lag');
ylabel('corr');
