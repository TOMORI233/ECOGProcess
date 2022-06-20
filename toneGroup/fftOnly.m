clear all; clc
BLOCKPATH = 'E:\ECoG\chouchou\cc20220614\Block-6';
margins = [0.05 0.05 0.05 0.05 ];
lineToPlot = [0 1 4 10 25 50];
%% reg
window = [0 10]*80; % sec
binSize = 40; % sec
silence = 10; % sec
tBlocks = [(window(1): binSize*2: window(2)- 2*binSize)' (window(1): binSize*2: window(2)- 2*binSize)' + binSize];
tBlocks(:, 1) =  tBlocks(:, 1) + 15;
tBlocks(:, 2) =  tBlocks(:, 2) - silence;
for tB = 1:size(tBlocks,1) 
data1 = TDTbin2mat(BLOCKPATH, 'T1', tBlocks(tB, 1), 'T2', tBlocks(tB, 2));
for ch = 1 : 64
    [fft_data_AC{ch}(tB,:), fft_freq] = TDTfft(data1.streams.LAuC,ch,'PLOT',false,'RESOLUTION', 0.125);
    [fft_data_PFC{ch}(tB,:), fft_freq] = TDTfft(data1.streams.LPFC,ch,'PLOT',false,'RESOLUTION', 0.125);

end
end

fft_AC = cellfun(@(x) mean(double(x)), fft_data_AC', 'uni', false);
fft_PFC = cellfun(@(x) mean(double(x)), fft_data_PFC', 'uni', false);

[~, ~, Fig] = TDTfft(data1.streams.LAuC,1);
allAxes = findobj(Fig, "Type", "axes");
for i = 0 : 19
plot(allAxes(3), [i*500 i*500], allAxes(3).YLim, 'k--'); hold on;
end

%% rand
tBlocks = [(window(1): binSize*2: window(2)- 2*binSize)' + binSize  (window(1): binSize*2: window(2)- 2*binSize)' + 2 *binSize];
tBlocks(:, 1) =  tBlocks(:, 1) + 15;
tBlocks(:, 2) =  tBlocks(:, 2) - silence;
for tB = 1:size(tBlocks,1) 
data1 = TDTbin2mat(BLOCKPATH, 'T1', tBlocks(tB, 1), 'T2', tBlocks(tB, 2));
for ch = 1 : 64
    [fft_data_AC2{ch}(tB,:), fft_freq] = TDTfft(data1.streams.LAuC,ch,'PLOT',false,'RESOLUTION', 0.125);
    [fft_data_PFC2{ch}(tB,:), fft_freq] = TDTfft(data1.streams.LPFC,ch,'PLOT',false,'RESOLUTION', 0.125);
end
end

fft_AC2 = cellfun(@(x) mean(double(x)), fft_data_AC2', 'uni', false);
fft_PFC2 = cellfun(@(x) mean(double(x)), fft_data_PFC2', 'uni', false);
%%
Fig1 = figure;
for ch = 1 : 64
    Axes = mSubplotSPR(Fig1, 8,8,ch, margins);
    fft_data = 20*log10(fft_AC{ch});
    plot(fft_freq, fft_data, 'r-'); hold on
    fft_data2 = 20*log10(fft_AC2{ch});
    plot(fft_freq, fft_data2, 'b-'); hold on
    title(['AC CH' num2str(ch)]);
    xlabel('Frequency (Hz)')
    ylabel('dBV')

    y_axis = [-1 1];
    if max(abs(fft_data)) > 0 && all(isfinite(fft_data))
        y_axis = [min(fft_data)*1.05 max(fft_data)/1.05];
    end
    freq_axis = [0 fft_freq(end)];
    axis([freq_axis y_axis]);
    set(gca,'xtick',[0 1 4 10 25 50]);
    set(gca,'xticklabel',[0 1 4 10 25 50]);
    for k = 1 : length(lineToPlot)
        plot([lineToPlot(k) lineToPlot(k)],Axes.YLim,'k--'); hold on
    end
    xlim([0 5]);
    ylim([-140 Axes.YLim(2)]);
end


Fig2 = figure;
for ch = 1 : 64
    Axes = mSubplotSPR(Fig2, 8,8,ch, margins);
%     fft_data = 20*log10(fft_PFC{ch});
    plot(fft_freq, fft_data,'r-'); hold on
    fft_data2 = 20*log10(fft_PFC2{ch});
    plot(fft_freq, fft_data2,'b-'); hold on
    title(['PFC CH' num2str(ch)]);
    xlabel('Frequency (Hz)')
    ylabel('dBV')

    y_axis = [-1 1];
    if max(abs(fft_data)) > 0 && all(isfinite(fft_data))
        y_axis = [min(fft_data)*1.05 max(fft_data)/1.05];
    end
    freq_axis = [0 fft_freq(end)];
    axis([freq_axis y_axis]);
    set(gca,'xtick',[0 1 4 10 25 50]);
    set(gca,'xticklabel',[0 1 4 10 25 50]);
    for k = 1 : length(lineToPlot)
        plot([lineToPlot(k) lineToPlot(k)],Axes.YLim,'k--'); hold on
    end
    xlim([0 5]);
    ylim([-140 Axes.YLim(2)]);




end



