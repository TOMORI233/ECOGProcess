switch Protocol
    case "Add_on_Basic_Var_50_2"
        titleStr = "4ms IrregVar";
        stimStr = {'normalize SD = 1/50','normalize SD = 1/25' ,'normalize SD = 1/10','normalize SD = 1/2'};
        S1Duration = [5000.2, 5000.2, 5000.2, 5000.2] + 4.06;
        cursor = [250, 250, 250 ,250];
        winStart = -5500;
        Window = [winStart 5500];
        ICAWin = [-1500 1500];
    case "Add_on_Basic_Oscillation_Tone_250_5000"
        titleStr = "Add_on_Oscillation_control";
        stimStr = {'250Hz_60ms','5000Hz_60ms','250Hz_30ms','5000Hz_30ms', '250Hz_control'};
        S1Duration = zeros(1, 4);
        cursor = [16.7, 16.7, 33.3, 33.3];
        winStart = -4000;
        Window = [winStart 12000];
        ICAWin = [-1000 10000];
        FFTWin = [1000 10000];
    case "Add_on_Basic_Oscillation_control_500_250_125_60_30"
        titleStr = "Add_on_Oscillation_control";
        stimStr = {'500ms','250ms','125ms','60ms', '30ms', 'control'};
        S1Duration = zeros(1, 6);
        cursor = [2, 4, 8, 16.7, 33.3, 0];
        winStart = -4000;
        Window = [winStart 12000];
        ICAWin = [-1000 10000];
        FFTWin = [1000 10000];
    case "Add_on_Basic_ICI4"
        titleStr = "Add_on_Basic_ICI4";
        stimStr = {'4-4.06ms Reg','4.06-4ms Reg','4-4.06ms Irreg','4.06-4ms Irreg'};
        S1Duration = [5004.8, 5008.4, 5000, 5000] + 4;
        winStart = -5500;
        Window = [winStart 5500];
        ICAWin = [-1000 1000];
    case "Add_on_Basic_Tone"
        titleStr = "Add_on_Basic_Tone";
        stimStr = {'250_246Hz','246_250Hz','250_200Hz','200_250Hz'};
        S1Duration = [5000, 5000, 5000, 5000];
        winStart = -5500;
        Window = [winStart 5500];
        ICAWin = [-1000 1000];
     case "Add_on_Basic_NormSqrt_ICI4"
        titleStr = "Add_on_Basic_NormSqrt_ICI4";
        stimStr = {'4-4.06ms Reg','4.06-4ms Reg','4-4.06ms Irreg','4.06-4ms Irreg'};
        S1Duration = [5004.8, 5008.4, 5003.2, 5000.5] + 4;
        winStart = -5500;
        Window = [winStart 2500];
        ICAWin = [-1000 1000];
     case "Add_on_Basic_NormSqrt_ICI8"
        titleStr = "Add_on_Basic_NormSqrt_ICI8";
        stimStr = {'8-8.12ms Reg','8.12-8ms Reg','8-8.12ms Irreg','8.12-8ms Irreg'};
        S1Duration = [5004.8, 5002.1, 5001.2, 4993] + 8;
        winStart = -5500;
        Window = [winStart 2500];
        ICAWin = [-1000 1000];
     case "Add_on_Basic_Duration_0o5_5"
        titleStr = "Duration0o5-5s_1s_4_4o06";
        stimStr = {'0o5s_1s', '1s_1s', '2s_1s', '3s_1s', '4s_1s', '5s_1s'};
        S1Duration = [500, 1000.1, 2004.2, 3004.2, 4004.3, 5008.4] + 4;
        winStart = -5000;
        Window = [winStart 2000];
        ICAWin = [-1000 1000];
        FFTWin = [1000 7000];
    case "Duration1-5s_1s_4o06_4"
        titleStr = "Duration1-5s_1s_4o06_4";
        stimStr = {'1s_1s', '2s_1s', '3s_1s', '4s_1s', '5s_1s'};
        S1Duration = [1000.1, 2004.2, 3004.2, 4004.3, 5008.4] + 4;
        winStart = -1000;
        Window = [winStart 7000];
        ICAWin = [-1000 7000];
        FFTWin = [1000 7000];
     case "Duration1-5s_1s_4_4o06"
        titleStr = "Duration1-5s_1s_4_4o06";
        stimStr = {'1s_1s', '2s_1s', '3s_1s', '4s_1s', '5s_1s'};
        S1Duration = [1001, 2001.9, 3002.9, 4003.9, 5004.8] + 4;
        winStart = -1000;
        Window = [winStart 7000];
        ICAWin = [-1000 1000];
        FFTWin = [1000 7000];
    case "Successive_Tone_250-246_240_200"
        titleStr = ["0.025s successive", "0.05s successive"];
        stimStr = {'0.025s 200Hz', '0.025s 240Hz', '0.025 246Hz', ...
            '0.05s 200Hz', '0.05s 240Hz', '0.05s 246Hz'};
        S1Duration = zeros(1, 6);
        cursor = [40, 40, 40, 20, 20, 20];
        winStart = -4000;
        Window = [winStart 14000];
        ICAWin = [-1000 10000];
        FFTWin = [1000 10000];
    case "Successive_0o025_0o05"
        titleStr = ["0.025s successive", "0.05s successive"];
        stimStr = {'0.025s change Reg 4-4.06', '0.025s frozen Irreg 4-4.06', '0.025 rand Irreg 4-4.06', ...
            '0.05s change Reg 4-4.06', '0.05s frozen Irreg 4-4.06', '0.05s rand Irreg 4-4.06'};
        S1Duration = zeros(1, 6);
        cursor = [40, 40, 40, 20, 20, 20];
        winStart = -4000;
        Window = [winStart 14000];
        ICAWin = [-1000 10000];
        FFTWin = [1000 10000];
    case "Successive_0o1_0o2"
        titleStr = ["0.1s successive", "0.2s successive"];
        stimStr = {'0.1s change Reg 4-4.06', '0.1s frozen Irreg 4-4.06', '0.1s rand Irreg 4-4.06', ...
            '0.2s change Reg 4-4.06', '0.2s frozen Irreg 4-4.06', '0.2s rand Irreg 4-4.06'};
        S1Duration = zeros(1, 6);
        cursor = [10, 10, 10, 5, 5, 5];
        winStart = -4000;
        Window = [winStart 14000];
        ICAWin = [-1000 10000];
        FFTWin = [1000 10000];

    case "Successive_0o3_0o5"
        titleStr = ["0.3s successive", "0.5s successive"];
        stimStr = {'0.3s change Reg 4-4.06', '0.3s frozen Irreg 4-4.06', '0.3s rand Irreg 4-4.06', ...
            '0.5s change Reg 4-4.06', '0.5s frozen Irreg 4-4.06', '0.5s rand Irreg 4-4.06'};
        S1Duration = zeros(1, 6);
        cursor = [10/3, 10/3, 10/3, 2, 2, 2];
        winStart = -4000;
        Window = [winStart 14000];
        ICAWin = [-1000 10000];
        FFTWin = [1000 10000];

    case "Successive_1_2"
        titleStr = ["1s successive", "2s successive"];
        stimStr = {'1s change Reg 4-4.06', '1s frozen Irreg 4-4.06', '1s rand Irreg 4-4.06', ...
            '2s change Reg 4-4.06', '2s frozen Irreg 4-4.06', '2s rand Irreg 4-4.06'};
        S1Duration = zeros(1, 6);
        cursor = [1, 1, 1, 0.5, 0.5, 0.5];
        winStart = -4000;
        Window = [winStart 14000];
        ICAWin = [-1000 10000];
        FFTWin = [1000 10000];
    case "Basic_NormSqrt"
        titleStr = "4-4.06 RegIrreg";
        stimStr = {'4-4.06ms Reg','4.06-4ms Reg','4-4.06ms Irreg','4.06-4ms Irreg'};
        S1Duration = [5008.8, 5005, 5012.5, 4998.5] + 4;
        cursor = [250, 250, 250 ,250];
        winStart = -5500;
        Window = [winStart 5500];
        ICAWin = [1000 1500];
    case "Basic_ICI4"
        titleStr = "4-4.06 RegIrreg";
        stimStr = {'4-4.06ms Reg','4.06-4ms Reg','4-4.06ms Irreg','4.06-4ms Irreg'};
        S1Duration = [5005, 5080.1, 5000.2, 5075.2] + 4;
        cursor = [250, 250, 250 ,250];
        winStart = -5500;
        Window = [winStart 5500];
        ICAWin = [1000 1500];
        FFTWin = [-4500 -500];

    case "Basic_ICI8"
        titleStr = "8-8.12 RegIrreg";
        stimStr = {'8-8.12ms Reg','8.12-8ms Reg','8-8.12ms Irreg','8.12-8ms Irreg'};
        S1Duration = [5005, 5080.1, 5000.2, 5075.2] + 8;
        cursor = [125, 125, 125 ,125];
        winStart = -5500;
        Window = [winStart 5500];
        ICAWin = [-1500 1500];
        FFTWin = [-4500 -500];

    case "Basic_ICI20"
        titleStr = "20-20.3 RegIrreg";
        stimStr = {'20-20.3ms Reg','20.3-20ms Reg','20-20.3ms Irreg','20.3-20ms Irreg'};
        S1Duration = [5005, 5080.1, 5000.2, 5075.2] + 20;
        cursor = [50, 50, 50, 50];
        winStart = -5500;
        Window = [winStart 5500];
        ICAWin = [-1500 1500];
        FFTWin = [-4500 -500];

    case "Basic_ICI40"
        titleStr = "40-40.6 RegIrreg";
        stimStr = {'40-40.6ms Reg','40.6-40ms Reg','40-40.6ms Irreg','40.6-40ms Irreg'};
        S1Duration = [5005, 5080.1, 5000.2, 5075.2] + 40;
        cursor = [25, 25, 25 ,25];
        winStart = -5500;
        Window = [winStart 5500];
        ICAWin = [-1500 1500];
        FFTWin = [-4500 -500];

    case "Basic_ICI80"
        titleStr = "80-81.2 RegIrreg";
        stimStr = {'80-81.2ms Reg','81.2-80ms Reg','80-81.2ms Irreg','81.2-80ms Irreg'};
        S1Duration = [4965, 4958.2, 4935.7, 4969] + 80;
        cursor = [12.5, 12.5, 12.5 ,12.5];
        winStart = -5500;
        Window = [winStart 5500];
        ICAWin = [-1500 1500];
        FFTWin = [-4500 -500];

    case "Basic_ICIThr"
        titleStr = "4ms ICIThr";
        stimStr = {'4ms -4.04ms Reg','4ms -4.02ms Reg' ,'4ms -4.03ms Reg','4ms -4.01ms Reg'};
        S1Duration = [5005+4.04, 5005+4.02, 5005+4.03, 5005+4.01];
        cursor = [12.5, 12.5, 12.5 ,12.5];
        winStart = -5500;
        Window = [winStart 5500];
        ICAWin = [-1500 1500];

    case "Basic_IrregVar"
        titleStr = "4ms IrregVar";
        stimStr = {'normalize SD = 1/400','normalize SD = 1/200' ,'normalize SD = 1/100','normalize SD = 1/50'};
        S1Duration = [5000.2, 5000.2, 5000.2, 5000.2] + 4;
        cursor = [250, 250, 250 ,250];
        winStart = -5500;
        Window = [winStart 5500];
        ICAWin = [-1500 1500];
end