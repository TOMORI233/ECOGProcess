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

    case "successive_1_2"
        titleStr = ["1s successive", "2s successive"];
        stimStr = {'1s change Reg 4-4.06', '1s frozen Irreg 4-4.06', '1s rand Irreg 4-4.06', ...
            '2s change Reg 4-4.06', '2s frozen Irreg 4-4.06', '2s fix rand 4-4.06',};
        S1Duration = zeros(1, 6);
        cursor = [1, 1, 1, 0.5, 0.5, 0.5];
        winStart = -1000;
        Window = [winStart 11000];
        ICAWin = [-1000 11000];

    case "Basic_ICI4"
        titleStr = "4-4.06 RegIrreg";
        stimStr = {'4-4.06ms Reg','4.06-4ms Reg','4-4.06ms Irreg','4.06-4ms Irreg'};
        S1Duration = [5005, 5080.1, 5000.2, 5075.2] + 4;
        cursor = [250, 250, 250 ,250];
        winStart = -5500;
        Window = [winStart 3000];
        ICAWin = [-1500 1500];

    case "Basic_ICI8"
        titleStr = "8-8.12 RegIrreg";
        stimStr = {'8-8.12ms Reg','8.12-8ms Reg','8-8.12ms Irreg','8.12-8ms Irreg'};
        S1Duration = [5005, 5080.1, 5000.2, 5075.2] + 8;
        cursor = [125, 125, 125 ,125];
        winStart = -5500;
        Window = [winStart 3000];
        ICAWin = [-1500 1500];

    case "Basic_ICI20"
        titleStr = "20-20.3 RegIrreg";
        stimStr = {'20-20.3ms Reg','20.3-20ms Reg','20-20.3ms Irreg','20.3-20ms Irreg'};
        S1Duration = [5005, 5080.1, 5000.2, 5075.2] + 20;
        cursor = [50, 50, 50, 50];
        winStart = -5500;
        Window = [winStart 3000];
        ICAWin = [-1500 1500];

    case "Basic_ICI40"
        titleStr = "40-40.6 RegIrreg";
        stimStr = {'40-40.6ms Reg','40.6-40ms Reg','40-40.6ms Irreg','40.6-40ms Irreg'};
        S1Duration = [5005, 5080.1, 5000.2, 5075.2] + 40;
        cursor = [25, 25, 25 ,25];
        winStart = -5500;
        Window = [winStart 3000];
        ICAWin = [-1500 1500];

    case "Basic_ICI80"
        titleStr = "80-81.2 RegIrreg";
        stimStr = {'80-81.2ms Reg','81.2-80ms Reg','80-81.2ms Irreg','81.2-80ms Irreg'};
        S1Duration = [4965, 4958.2, 4935.7, 4969] + 80;
        cursor = [12.5, 12.5, 12.5 ,12.5];
        winStart = -5500;
        Window = [winStart 3000];
        ICAWin = [-1500 1500];

    case "Basic_ICIThr"
        titleStr = "4ms ICIThr";
        stimStr = {'4ms -4.01ms Reg','4ms -4.02ms Reg' ,'4ms -4.03ms Reg','4ms -4.04ms Reg'};
        S1Duration = [5005+4.01, 5005+4.02, 5005+4.03, 5005+4.04];
        cursor = [12.5, 12.5, 12.5 ,12.5];
        winStart = -5500;
        Window = [winStart 3000];
        ICAWin = [-1500 1500];

    case "Basic_IrregVar"
        titleStr = "4ms IrregVar";
        stimStr = {'normalize SD = 1/400','normalize SD = 1/200' ,'normalize SD = 1/100','normalize SD = 1/50'};
        S1Duration = [5000.2, 5000.2, 5000.2, 5000.2] + 4;
        cursor = [250, 250, 250 ,250];
        winStart = -5500;
        Window = [winStart 3000];
        ICAWin = [-1500 1500];
end