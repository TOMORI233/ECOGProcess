switch Protocol

    case "successive_0o1_0o2"
        titleStr = ["0.1s successive", "0.2s successive"];
        stimStr = {'0.1s change Reg 4-4.06', '0.1s frozen Irreg 4-4.06', '0.1s rand Irreg 4-4.06', ...
            '0.2s change Reg 4-4.06', '0.2s frozen Irreg 4-4.06', '0.2s rand Irreg 4-4.06',};
        S1Duration = zeros(1, 6);
        cursor = [10, 10, 10, 5, 5, 5];
        winStart = -1000;
        Window = [winStart 11000];
        ICAWin = [-1000 11000];


    case "successive_0o3_0o5"
        titleStr = ["0.3s successive", "0.5s successive"];
        stimStr = {'0.3s change Reg 4-4.06', '0.3s frozen Irreg 4-4.06', '0.3s rand Irreg 4-4.06', ...
            '0.5s change Reg 4-4.06', '0.5s frozen Irreg 4-4.06', '0.5s fix rand 4-4.06',};
        S1Duration = zeros(1, 6);
        cursor = [10/3, 10/3, 10/3, 2, 2, 2];
        winStart = -1000;
        Window = [winStart 11000];
        ICAWin = [-1000 11000];

end