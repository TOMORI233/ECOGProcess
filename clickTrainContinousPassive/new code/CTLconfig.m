switch Protocol
    case "TITS_160_400"  % prediction based 400-700,/ 400-700 Irreg 6s-4s
        titleStr = "TITS_160_400";
        stimStr = ["Reg_160_400", "Reg_400_160"];
        %         S1Duration = [3024.3+48, 3024.3+52.8, 3024.3+72, 3024.3+96, 3024.3+192, 3024.3+384, 3024.3];
        S1Duration = [4000, 4001];
        cursor = [62.5, 62.5, 62.5 ,62.5];
        winStart = -4500;
        Window = [winStart 4500];
        FFTWin = [300 1900];
        ICAWin = [-1000 1000];
    case "TITS_Reg_Irreg"  % No reg in irreg / check distribution of clicks
        titleStr = "TITS_Reg_Irreg";
        stimStr = ["36_24Reg", "36_24Irreg", "60_24Reg", "60_24Irreg"];
        %         S1Duration = [3024.3+48, 3024.3+52.8, 3024.3+72, 3024.3+96, 3024.3+192, 3024.3+384, 3024.3];
        S1Duration = [2988.3, 3008.3,  3000.3, 2961.8];
        cursor = [62.5, 62.5, 62.5 ,62.5];
        winStart = -3500;
        Window = [winStart 2500];
        FFTWin = [300 1900];
        ICAWin = [-1000 1000];
    case "TITS_Tone"  % fix Tone Amp to 10, click train SPL 
        titleStr = "TITS_Tone";
        % S1: 24_60, S2: 60_24
        stimStr = ["S1_Amp1", "S1_Amp2", "S1_Amp4", "S1_Amp7", "S1_Amp10", "S2_Amp1", "S2_Amp2", "S2_Amp3", "S2_Amp4", "S2_Amp5"];
        %         S1Duration = [3024.3+48, 3024.3+52.8, 3024.3+72, 3024.3+96, 3024.3+192, 3024.3+384, 3024.3];
        S1Duration = ones(1, 10) * 3000.3;
        cursor = [62.5, 62.5, 62.5 ,62.5];
        winStart = -3500;
        Window = [winStart 4000];
        FFTWin = [300 1900];
        ICAWin = [-1000 1000];
    case "TITS_Offset_Irreg"  % mix Reg and Irreg 40, 60, 80,  100, 120
        titleStr = "TITS_Offset_Irreg";
        stimStr = ["60", "80", "100", "120", "140", "160"];
        %         S1Duration = [2900.1, 2880.1, 2800, 2880, 2880.2, 2800.1, 2860.1, 2880.1, 2860];
        S1Duration = zeros(1, 6);
        S1Dur = [3039.6, 3034.4, 3049.1, 3072.8, 2947.3, 2907.2];
        winStart = -500;
        Window = [winStart 4000];
        FFTWin = [0 2000];
        ICAWin = [0 2000];
    case "Rhythm_Offset" % 降低单个click声强，24ms ICI，能不能没有跟随但有offset
        titleStr = "Rhythm_Offset";
        stimStr = ["100", "120", "140", "160", "180", "200", "220", "240", "260"];

        S1Duration = zeros(1, 9);
        S1Dur = [2800.1, 2760.1, 2660.1];
        winStart = -500;
        Window = [winStart 3500];
        FFTWin = [0 2000];
        ICAWin = [0 2000];
    case "Rhythm_Ratio_Rev"
        titleStr = "Rhythm_Ratio_Rev";
        stimStr = ["26o4_24", "36_24", "48_24", "39o6_36", "54_36", "72_36", "72_48"];
        %         S1Duration = [3024.3+48, 3024.3+52.8, 3024.3+72, 3024.3+96, 3024.3+192, 3024.3+384, 3024.3];
        S1Duration = [3010.6, 3088.3, 3024.3, 3010.2, 3024.3, 3024.3, 3024.3];
        cursor = [62.5, 62.5, 62.5 ,62.5];
        winStart = -3500;
        Window = [winStart 2500];
        FFTWin = [300 1900];
        ICAWin = [-1000 1000];
    case "Rhythm_Ratio_ICI48"
        titleStr = "Rhythm_Ratio_ICI48";
        stimStr = {'control', '1o1', '1o5', '2', '3', '8', 'offset'};
        %         S1Duration = [3024.3+48, 3024.3+52.8, 3024.3+72, 3024.3+96, 3024.3+192, 3024.3+384, 3024.3];
        S1Duration = [3024.3, 3024.3, 3024.3, 3024.3, 3024.3, 3024.3, 3024.3-48];
        cursor = [62.5, 62.5, 62.5 ,62.5];
        winStart = -3500;
        Window = [winStart 2500];
        FFTWin = [300 1900];
        ICAWin = [-1000 1000];
    case "Rhythm_Ratio_ICI36"
        titleStr = "Rhythm_Ratio_ICI36";
        stimStr = {'control', '1o1', '1o5', '2', '3', '8', 'offset'};
        S1Duration = [2988.3, 2988.3, 2988.3, 2988.3, 2988.3, 2988.3, 2988.3-36];
        cursor = [62.5, 62.5, 62.5 ,62.5];
        winStart = -3500;
        Window = [winStart 2500];
        FFTWin = [300 1900];
        ICAWin = [-1000 1000];
    case "Rhythm_Ratio_ICI24"
        titleStr = "Rhythm_Ratio_ICI24";
        stimStr = {'control', '1o1', '1o5', '2', '3', '8', 'offset'};
        S1Duration = [3000.3, 3000.3, 3000.3, 3000.3, 3000.3, 3000.3, 3000.3-24];
        cursor = [62.5, 62.5, 62.5 ,62.5];
        winStart = -3500;
        Window = [winStart 2500];
        FFTWin = [300 1900];
        ICAWin = [-1000 1000];
    case "Species_Ratio_ICI20"
        titleStr = "Species_Ratio_ICI20";
        stimStr = {'control', '1o005', '1o01', '1o015', '1o1', '1.5'};
        S1Duration = [3001.4+20, 3001.4+20.1, 3001.4+20.2, 3001.4+20.3, 3001.4+22, 3001.4+30];
        cursor = [62.5, 62.5, 62.5 ,62.5];
        winStart = -3500;
        Window = [winStart 1500];
        FFTWin = [0 1000];
        ICAWin = [-1000 1000];
    case "Species_Ratio_ICI16"
        titleStr = "Species_Ratio_ICI16";
        stimStr = {'control', '1o005', '1o01', '1o015', '1o1', '1.5'};
        S1Duration = [3009+16, 3009+16.08, 3009+16.16, 3009+16.24, 3009+17.6, 3009+24];
        cursor = [62.5, 62.5, 62.5 ,62.5];
        winStart = -3500;
        Window = [winStart 1500];
        FFTWin = [0 1000];
        ICAWin = [-1000 1000];
    case "Species_Ratio_ICI12"
        titleStr = "Species_Ratio_ICI12";
        stimStr = {'control', '1o005', '1o01', '1o015', '1o1', '1.5'};
        S1Duration = [3003+12, 3003+12.06, 3003+12.12, 3003+12.18, 3003+13.2, 3003+18];
        cursor = [83.33, 83.33, 83.33 ,83.33];
        winStart = -3500;
        Window = [winStart 1500];
        FFTWin = [0 1000];
        ICAWin = [-1000 1000];
    case "Species_Ratio_ICI8"
        titleStr = "Species_Ratio_ICI8";
        stimStr = {'control', '1o005', '1o01', '1o015', '1o1', '1.5'};
        S1Duration = [3002.9+8, 3002.9+8.04, 3002.9+8.08, 3002.9+8.12, 3002.9+8.8, 3002.9+12];
        cursor = [125, 125, 125 ,125];
        winStart = -3500;
        Window = [winStart 1500];
        FFTWin = [0 1000];
        ICAWin = [-1000 1000];
    case "Species_Ratio_ICI4"
        titleStr = "Species_Ratio_ICI4";
        stimStr = {'control', '1o005', '1o01', '1o015', '1o1', '1.5'};
        S1Duration = [3002.9+4, 3002.9+4.02, 3002.9+4.04, 3002.9+4.06, 3002.9+4.4, 3002.9+6];
        cursor = [250, 250, 250 ,250];
        winStart = -3500;
        Window = [winStart 1500];
        FFTWin = [0 1000];
        ICAWin = [-1000 1000];
    case "Species_Ratio_ICI2"
        titleStr = "Species_Ratio_ICI2";
        stimStr = {'control', '1o005', '1o01', '1o015', '1o1', '1.5'};
        S1Duration = [3010.6+2, 3010.6+2.01, 3010.6+2.02, 3010.6+2.03, 3010.6+2.2, 3010.6+3];
        cursor = [200, 200, 200 ,200];
        winStart = -3500;
        Window = [winStart 1500];
        FFTWin = [0 1000];
        ICAWin = [-1000 1000];
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