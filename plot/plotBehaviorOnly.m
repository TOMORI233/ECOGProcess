function Fig = plotBehaviorOnly(trialAll)
    trialsNoInterrupt = trialAll([trialAll.interrupt] == false);
    fAll = unique([trialAll.devFreq]);
    fAll(fAll == 0) = [];
    nPush = [];
    nTotal = [];
    
    Fig = figure;
    maximizeFig(Fig);
    margins = [0.1, 0.1, 0.1, 0.1];
    
    for fIndex = 1:length(fAll)
        temp = trialsNoInterrupt([trialsNoInterrupt.devFreq] == fAll(fIndex));
        nTotal = [nTotal, length(temp)];
        nPush = [nPush, length([temp.firstPush])]; 
        RT = cell2mat({temp.firstPush} - {temp.devOnset});
        mAxe = mSubplot(Fig, length(fAll), 4, 4 * fIndex, [1, 1], [0.1, 0.1, 0.15, 0.15]);
        plot(RT, 1:length(RT), 'r.', "MarkerSize", 10);
        hold on;
        meanRT = mean(RT);
        yaxis = get(mAxe, "YLim");
        stem(meanRT, yaxis(2), "b-", "LineWidth", 1.5);
        title(['fDEV = ', num2str(fAll(fIndex)), ' ms (Mean RT ', num2str(roundn(meanRT, -2)), ' ms)']);
        xlim([0, 800]);
        xlabel('Reaction Time (ms)');
    end
    
    mSubplot(Fig, 2, 2, 1, [1, 1], margins);
    diffLevel = roundn(fAll' / fAll(1), -2);
    plot(nPush ./ nTotal, "b-", "LineWidth", 2);
    
    for index = 1:length(nPush)
        text(index, nPush(index) / nTotal(index), [num2str(nPush(index)), '/', num2str(nTotal(index))]);
    end
    
    ylim([0 1]);
    xticks(1:length(diffLevel));
    xticklabels(diffLevel);
    xlabel("Dev Freq / Std Freq");
    ylabel("Push Ratio");
    yticks(0:0.2:1);
    title(['Frequency Oddball Task (standard freq = ', num2str(fAll(1)), ' Hz)']);

    return;
end