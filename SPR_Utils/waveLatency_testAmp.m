function [H, P] = waveLatency_testAmp(wave, window, testWin, binsize, step, sponWin)
% Description: Split data by trials, window and segOption. Filter and
    %              resample data. Perform ICA on data.
    % Input:
    %     wave: wave should be the similar type as trialsECOG
    %     window: the window that corresponding to the size of trialsECOG
    %     testWin: window included to cultulate the amp train
    %     binsize: decide the size of wave used to calculate one sample of
    %              amp that used to construct the amp train.
    %     step: the resolution of the amp train
    %     sponWin: window included to decide significant amp sample points.

    % Output:
    %     comp: result of ICA (FieldTrip)


% if binsize ~= diff(sponWin)
%     error("sponWin should have the same size as binsize!");
% end

testWins = [(testWin(1): step : testWin(2) - binsize)', (testWin(1) + binsize: step : testWin(2))'];
wave = changeCellRowNum(wave); % wave is similar as trialsECOG

for bIndex = 1 : size(testWins, 1)
    [normAmp(:, bIndex), amp(:, bIndex), rmsSpon(:, bIndex)] = cellfun(@(x) waveAmp_Norm(x, window, testWins(bIndex, :), 1, sponWin), wave, "UniformOutput", false);
end

[H, P] = cellfun(@(x, y) ttest2(x, y), amp, rmsSpon, "uni", false);
H = cell2mat(H);
P = cell2mat(P);


end