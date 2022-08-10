function trial = changeOrderStr(trial, protocolName)

switch protocolName
    case "ClickTrainOddCompareTone"
        idx{1} = find([trial.stdOrdr] == 1 & [trial.devOrdr] == 1);
        idx{2} = find([trial.stdOrdr] == 1 & [trial.devOrdr] == 5);
        idx{3} = find([trial.stdOrdr] == 2 & [trial.devOrdr] == 2);
        idx{4} = find([trial.stdOrdr] == 2 & [trial.devOrdr] == 4);
        idx{5} = find([trial.stdOrdr] == 6 & [trial.devOrdr] == 6);
        idx{6} = find([trial.stdOrdr] == 6 & [trial.devOrdr] == 10);
        idx{7} = find([trial.stdOrdr] == 7 & [trial.devOrdr] == 7);
        idx{8} = find([trial.stdOrdr] == 7 & [trial.devOrdr] == 9);
        newOrder(1, :) = [1 1];
        newOrder(2, :) = [4 5];
        newOrder(3, :) = [4 4];
        newOrder(4, :) = [1 2];
        newOrder(5, :) = [6 6];
        newOrder(6, :) = [9 10];
        newOrder(7, :) = [9 9];
        newOrder(8, :) = [6 7];
        for n = 1 : length(idx)
            for m = 1 : length(idx{n})
            trial(idx{n}(m)).stdOrdr = newOrder(n, 1);
            trial(idx{n}(m)).devOrdr = newOrder(n, 2);
            end
        end
end
        

        
end