switch Protocol
    case "Anesthesia_BaseICI_Ratio_Tone_Push_Spon"
        titleStr = "SFigure_Anesthesia_BaseICI_Ratio_Tone_Push_Spon";
        colors = ["#FF0000", "#FFA500", "#0000FF", "#000000", "#AAAAAA"];
        stimStrs = ["4-4o06", "8-8o12", "4-5", "250-200Hz", "4-4o5"];
        S1Duration = [0, 0, 0, 0, 0];
        winStart = -3000;
        Window = [winStart 1000];
        ICAWin = Window;
        FFTWin = [-2000, 0];
    case "Anesthesia_BaseICI_Ratio_Tone_Push"
        titleStr = "SFigure_Anesthesia_BaseICI_Ratio_Tone_Push";
        colors = ["#FF0000", "#FFA500", "#0000FF", "#000000", "#888888"];
        stimStrs = ["4-4o06", "8-8o12", "4-5", "250-200Hz", "4-4o5"];
        S1Duration = [2001.9,2001.9, 2001.9, 2000, 2001.9];
        winStart = -2500;
        Window = [winStart 3000];
        ICAWin = Window;
        FFTWin = [0 2000];
    case "Add_on_LocalChange_4ms_2s-1s_N01248"
        titleStr = "Add_on_LocalChange_4ms_2s";
        stimStrs = ["Control", "N1", "N2", "N4", "N8"];
        S1Duration = [2001.9,2001.9, 2001.9,2001.9, 2001.9];

        winStart = -2500;
        Window = [winStart 3000];
        ICAWin = Window;
        FFTWin = [0 2000];
    case "SFigure_Anesthesia_BaseICI_Ratio_Tone"
        titleStr = "SFigure_Anesthesia_BaseICI_Ratio_Tone";
        colors = ["#FF0000", "#FFA500", "#6A5ACD", "#0000FF", "#888888", "#000000"];

        stimStrs = ["4-4o06", "8-8o12", "4-4o5", "4-5", "250-200Hz", "5000-4000Hz"];
        S1Duration = [2001.9,2001.9, 2001.9,2001.9, 2000, 2000];

        winStart = -2500;
        Window = [winStart 3000];
        ICAWin = Window;
        FFTWin = [0 2000];
    case "TB_Anesthesia_BasicTone"
        titleStr = "TB_Anesthesia_BasicTone";
        stimStrs = ["4-4o06", "250-200Hz", "250-246Hz"];
        S1Duration = [2001.9,2000,2000];

        winStart = -2500;
        Window = [winStart 1500];
        ICAWin = Window;
        FFTWin = [0 2000];
    case "TB_Anesthesia_Ratio"
        titleStr = "TB_Anesthesia_Ratio";
        stimStrs = ["4-4o06", "4-4o5", "4-5"];
        S1Duration = [2001.9,2001.9,2001.9];

        winStart = -2500;
        Window = [winStart 1500];
        ICAWin = Window;
        FFTWin = [0 2000];
    case "TB_Anesthesia_Osci_Rate_30_ketamine"
        titleStr = "TB_Anesthesia_Osci_Rate_30_ketamine";
        stimStrs = ["250ms","120ms", "Tone250_246_120ms", "Tone250_200_120ms"];
        S1Duration = zeros(1, 4);
        correspFreq = 1000./[250, 120, 120 ,120];
        winStart = 0;
        Window = [winStart 10000];
        ICAWin = [0 10000];
        FFTWin = [0 10000];

    case "TB_Anesthesia_BaseICI_Awake"
        titleStr = "TB_Anesthesia_BaseICI_Awake";
        stimStr = ["4-4o06", "8-8o12", "16-16o24", "32-32o48"];
        S1Duration = [2001.9,2001.9,2000.6,2016];

        winStart = -2500;
        Window = [winStart 1500];
        ICAWin = Window;
        FFTWin = [0 2000];

    case "TB_Anesthesia_Osci_Rate_40_ketamine"
        titleStr = "TB_Anesthesia_Osci_Rate_40_ketamine";
        stimStr = ["120ms","60ms", "Tone250_246_60ms", "Tone250_200_60ms"];
        S1Duration = zeros(1, 4);
        correspFreq = 1000./[120, 60, 60 ,60];
        winStart = -1000;
        Window = [winStart 7000];
        ICAWin = [0 7000];
        FFTWin = [0 5500];

    case "Add_on_Reg_Rep1_TimeCourse"
        %% 1：1-2-3-4-5
        titleStr = "LocalChange_Dur";
        S1Duration = 0;
        winStart = -1000;
        Window = [winStart 7500];
        ICAWin = [0 5000];
        FFTWin = [0 5000];
        tTh = 0.1;
        chTh = 0.1;
    case "Add_on_Reg_Rep1_Dur"
        %% 1. 0.5s  2. 1s   3. 3s 4. 5s
        titleStr = "LocalChange_Dur";
        %         colors = ["#FF0000", "#FFA500", "#0000FF", "#000000", "#000000"];
        %         stimStrs = ["4ms", "8ms", "20ms", "40ms", "80ms"];
        S1Duration = [500.5, 1001, 3002.9, 5004.8];
        winStart = -1000;
        Window = [winStart 1500];
        ICAWin = [-1000 1500];
        tTh = 0.2;
        chTh = 0.2;
    case "DiffICI_Merge"
        %% 1. Reg4-4.06_2s-1s  2. Reg4-4.06-4_2s-1s   3. Reg4-4.06_5s-2s 4.Reg4-4.06-4_5s-2s
        titleStr = "DiffICI_Merge";
        colors = ["#FF0000", "#FFA500", "#0000FF", "#000000", "#000000"];
        stimStrs = ["4ms", "8ms", "20ms", "40ms", "80ms"];
        S1Duration = [5009, 5013, 5025, 5045, 5045];
        winStart = -5500;
        Window = [winStart 5500];
        ICAWin = [-1500 1500];
        FFTWin = [-4500 -500];
        tTh = 0.2;
        chTh = 0.2;
    case "Add_on_Reg_Insert_Rep1_mix"
        %% 1. Reg4-4.06_2s-1s  2. Reg4-4.06-4_2s-1s   3. Reg4-4.06_5s-2s 4.Reg4-4.06-4_5s-2s
        titleStr = "Add_on_TB_Reg_Insert_Rep1_mix";
        stimStr = ["Reg4_4o06-2s", "Reg4_4o06_4-2s", "Reg4_4o06-5s", "Reg4_4o06_4-5s"];
        S1Duration = [2001.9,2001.9, 5004.8,5004.8];
        winStart = -2500;
        Window = [winStart 1500];
        FFTWin = [0,1000];
        ICAWin = [-2500 1500];
        tTh = 0.2;
        chTh = 0.2;
    case "Add_on_Reg_Insert_5s-2s"
        %% 1. Reg4-4.06   2. Reg4-4   3. Reg4-4.06-4
        titleStr = "Add_on_TB_Reg_Insert_5s";
        stimStr = ["Reg4_4o06", "Reg4_4", "Reg4_4o06_4"];
        S1Duration = [5004.8,5004.8,5004.8];
        winStart = -5500;
        Window = [winStart 1500];
        FFTWin = [0,1500];
        ICAWin = [-5500 1500];
        tTh = 0.2;
        chTh = 0.2;
    case "Add_on_Reg_Insert_2s-1s"
        %% 1. Reg4-4.06   2. Reg4-4   3. Reg4-4.06-4
        titleStr = "Add_on_TB_Reg_Insert_2s";
        stimStr = ["Reg4_4o06", "Reg4_4", "Reg4_4o06_4"];
        S1Duration = [2001.9,2001.9,2001.9];
        winStart = -1800;
        Window = [winStart 1000];
        FFTWin = [0,1000];
        ICAWin = [-1000 800];
        tTh = 0.2;
        chTh = 0.2;
        %% TITS 框架：
        % 1. 发现offset(reg & Irreg， 10+ VS 1-8， 跟随， 纯音/噪声对照)
        % 2. 改变duration(时间整合需要时间， 纯音/噪声对照）
        % 3. 节律的建立和节律的打破
        % 4. 一个节律变成另外一个节律
    case "TITS_4_25_noise_3s_4s_Reg_Irreg_Rev"   % 1. wavelet 2. 1Hz oscillation 3. PFC
        %% 1. 3s-4s Base ICI: 4ms, 15ms, 20ms, 25ms   2. noise-regular(15ms)   3. 4ms Reg-15Reg,   4ms Irreg - 15Reg,  30 Irreg - 15Reg
        titleStr = "TITS_4_25_noise_3s_4s_Reg_Irreg_Rev";
        stimStr = ["4ms_Reg_Irreg", "4ms_Irreg_Reg", "15ms_Reg_Irreg", "15ms_Irreg_Reg", "20ms_Reg_Irreg", "20ms_Irreg_Reg", "25ms_Reg_Irreg", "25ms_Irreg_Reg", "noise_15ms_Reg"];
        S1Duration = [4003.9, 4000, 4005.4, 3982.2, 4001.8, 4000, 4001, 4009.3, 2994.4];
        winStart = -4500;
        Window = [winStart 4000];
        FFTWin = [500, 3500];
        ICAWin = [-2000 2000];
    case "TITS_15_30_3s_13s_Reg_Irreg_Rev"   % 1. wavelet 2. 1Hz oscillation 3. PFC
        %% 1. 3s-4s Base ICI: 4ms, 15ms, 20ms, 25ms   2. noise-regular(15ms)   3. 4ms Reg-15Reg,   4ms Irreg - 15Reg,  30 Irreg - 15Reg
        titleStr = "TITS_15_30_3s_13s_Reg_Irreg_Rev";
        stimStr = ["15ms_Reg_Irreg", "15ms_Irreg_Reg", "30ms_Reg_Irreg", "30ms_Irreg_Reg"];
        S1Duration = [3000.3, 2977.5, 3000.3, 2936.3];
        winStart = -3500;
        Window = [winStart 14000];
        FFTWin = [500, 3500];
        ICAWin = [-2000 2000];
    case "TITS_Offset_15_Reg_Irreg_Noise_DiffDur_500_1000ms"
        titleStr = "TITS_Offset_15_Reg_Irreg_Noise_DiffDur_500_1000ms";
        stimStr = ["Reg15_500ms", "Reg15_750ms", "Reg15_1000ms", ...
            "Irreg15_500ms", "Irreg15_750ms", "Irreg15_1000ms",...
            "Noise_500ms", "Noise_750ms", "Noise_1000ms"];
        S1Duration = [495.1, 750.1, 1005.1, 499.6, 748.5, 1011.2, 500, 750, 1000];
        winStart = -1500;
        Window = [winStart 1000];
        FFTWin = [-1500 -500];
        ICAWin = [-1000 1000];
    case "TITS_15_30_60_Reg_Irreg_Rev"  % 15ms ICI Reg & Irreg + noise : 250, 500, 1s, 2s, 4s;  15ms, 30ms, 60ms : Reg to Irreg / Irreg to Reg 2s-2s, reverse
        titleStr = "TITS_15_30_60_Reg_Irreg_Rev";
        stimStr = ["15ms_Reg_Irreg", "15ms_Irreg_Reg", "30ms_Reg_Irreg", "30ms_Irreg_Reg", "60ms_Reg_Irreg", "60ms_Irreg_Reg"];
        S1Duration = [2010.2, 1985.5, 2010.2, 2016.6, 2040.2, 2066.6];
        winStart = -2500;
        Window = [winStart 2500];
        FFTWin = [200, 1800];
        ICAWin = [-1000 1000];
    case "TITS_Offset_15_Reg_Irreg_Noise_DiffDur"
        titleStr = "TITS_Offset_15_Reg_Irreg_Noise_DiffDur";
        stimStr = ["Reg15_250ms", "Reg15_500ms", "Reg15_1000ms", "Reg15_2000ms", "Reg15_4000ms", ...
            "Irreg15_250ms", "Irreg15_500ms", "Irreg15_1000ms", "Irreg15_2000ms", "Irreg15_400ms",...
            "Noise_250ms", "Noise_500ms", "Noise_1000ms", "Noise_2000ms", "Noise_4000ms"];
        S1Duration = [255, 495.1, 1005.1, 1995.2, 4005.4, 240.7, 510.9, 996.6, 2008.6, 3999.3, 250, 500, 1000, 2000, 4000];
        winStart = -3500;
        Window = [winStart 1000];
        FFTWin = [-2500 -500];
        ICAWin = [-1000 1000];
    case "TITS_Offset_15_DiffRep_5_40"  % 15ms ICI Reg & Irreg + noise : 250, 500, 1s, 2s, 4s;  15ms, 30ms, 60ms : Reg to Irreg / Irreg to Reg 2s-2s, reverse
        titleStr = "TITS_Offset_15_DiffRep_5_40";
        stimStr = ["Reg15_Rep0", "Reg15_Rep5", "Reg15_Rep10", "Reg15_Rep20", "Reg15_Rep40", "Irreg15_Rep1", "Irreg15_Rep5", "Irreg15_Rep10", "Irreg15_Rep20", "Irreg15_Rep40"];
        S1Duration = [3000.3, 2998.7,  2996, 3007.6, 2987.4, 2991.4,  2993.1, 2989.9, 3004.9, 3008.3];
        changeTime = [3000.3, 2925.3, 2850.3, 2700.3, 2400.3, 2976.4, 2918.1, 2839.8, 2704.9, 2408.2];
        winStart = -3500;
        Window = [winStart 1500];
        FFTWin = [-2500 -500];
        ICAWin = [-1000 1000];
    case "TITS_Offset_30_DiffRep"
        titleStr = "TITS_Offset_30_DiffRep";
        stimStr = ["Reg30_Rep0", "Reg30_Rep3", "Reg30_Rep6", "Reg30_Rep9", "Reg30_Rep12", "Irreg30_Rep1", "Irreg30_Rep2", "Irreg30_Rep3", "Irreg30_Rep4", "Irreg30_Rep5"];
        S1Duration = [3000.3, 2998,  3004.5, 2998.7, 3001, 3017.7,  3003.5, 29873, 3006.5, 3004.9];
        changeTime = [3000.3, 2910.3, 2820.3, 2730.3, 2640.3, 2987.7, 2943.5, 2897.2, 2886.5, 2854.9];
        winStart = -3500;
        Window = [winStart 1500];
        FFTWin = [-2500 -500];
        ICAWin = [-1000 1000];
    case "TITS_Offset_15_DiffRep"  % more RegRep for Irreg
        titleStr = "TITS_Offset_15_DiffRep";
        stimStr = ["Reg15_Rep0", "Reg15_Rep3", "Reg15_Rep6", "Reg15_Rep9", "Reg15_Rep12", "Irreg15_Rep1", "Irreg15_Rep2", "Irreg15_Rep3", "Irreg15_Rep4", "Irreg15_Rep5"];
        S1Duration = [3000.3, 2993.4,  2998.8, 3004.9, 2996.6, 2991.4,  2997.8, 2997.4, 2999.8, 2993.1];
        changeTime = [3000.3, 2955.3, 2910.3, 2865.3, 2820.3, 2976.4, 2967.8, 2952.4, 2939.8, 2918.1];
        winStart = -3500;
        Window = [winStart 1500];
        FFTWin = [-2500 -500];
        ICAWin = [-1000 1000];
    case "TITS_Offset_60_24_26o4"
        titleStr = "TITS_Offset_60_24_26o4";
        stimStr = ["24_26o4Reg", "24_26o4Irreg", "60_24Reg", "60_24Irreg"];
        S1Duration = [3000.3, 2979.7,  3000.3, 2997.1];
        soundDur = [4954.6, 5971.3,  3000.3, 4944.4];
        cursor = [62.5, 62.5, 62.5 ,62.5];
        winStart = -3500;
        Window = [winStart 2500];
        FFTWin = [-2000 0];
        ICAWin = [-1000 1000];
    case "TITS_Offset_SPL"
        titleStr = "TITS_Offset_SPL";
        stimStr = ["Reg30_0o1", "Reg30_0o2", "Reg30_0o4", "Reg30_0o7", "Reg30_1", "Reg60_0o1", "Reg60_0o2", "Reg60_0o4", "Reg60_0o7", "Reg60_1", ];
        S1Duration = ones(1, 10) * 3000.5;
        cursor = [62.5, 62.5, 62.5 ,62.5];
        winStart = -3500;
        Window = [winStart 2500];
        FFTWin = [-2000 0];
        ICAWin = [-1000 1000];
    case "TITS_Offset_Reg_Irreg_15_120"
        titleStr = "TITS_Offset_Reg_Irreg_15_120";
        stimStr = ["Reg15", "Irreg15", "Reg30", "Irreg30", "Reg60", "Irreg60", "Reg120", "Irreg120"];
        S1Duration = [3000.3, 3000.1,  3000.3, 3018.8, 3000.3, 3010.1,  3000.1, 2976.8];

        cursor = [62.5, 62.5, 62.5 ,62.5];
        winStart = -3500;
        Window = [winStart 2500];
        FFTWin = [-2000 0];
        ICAWin = [-1000 1000];
    case "TITS_X_24_Reg_Irreg"
        titleStr = "TITS_X_24_Reg_Irreg";
        stimStr = ["36_24Reg", "36_24Irreg", "60_24Reg", "60_24Irreg"];
        S1Duration = [2988.3, 3047.3,  3000.3, 2963.4];
        cursor = [62.5, 62.5, 62.5 ,62.5];
        winStart = -3500;
        Window = [winStart 2500];
        FFTWin = [-2000 0];
        ICAWin = [-1000 1000];
    case "TITS_ToneFixed"  % prediction based 400-700,/ 400-700 Irreg 6s-4s
        titleStr = "TITS_ToneFixed";
        stimStr = ["24_60_0o1", "24_60_0o2", "24_60_0o4", "24_60_0o7", "24_60_1", "60_24_0o1", "60_24_0o2", "60_24_0o4", "60_24_0o7", "60_24_1"];
        %         S1Duration = [3024.3+48, 3024.3+52.8, 3024.3+72, 3024.3+96, 3024.3+192, 3024.3+384, 3024.3];
        S1Duration = ones(1, 10) * 3000.3;
        soundDur = [ones(1, 5) * 4920.5, ones(1, 5) * 4968.5];
        cursor = [62.5, 62.5, 62.5 ,62.5];
        winStart = -3500;
        Window = [winStart 4000];
        FFTWin = [-2000 0];
        ICAWin = [-1000 1000];
    case "TITS_400_700"  % prediction based 400-700,/ 400-700 Irreg 6s-4s
        titleStr = "TITS_400_700";
        stimStr = ["Reg_400_700", "Irreg_400_700", "Reg_400_700", "Irreg_400_700"];
        %         S1Duration = [3024.3+48, 3024.3+52.8, 3024.3+72, 3024.3+96, 3024.3+192, 3024.3+384, 3024.3];
        S1Duration = [6000.1, 5725.8, 6300.1, 6890.6];
        cursor = [62.5, 62.5, 62.5 ,62.5];
        winStart = -4500;
        Window = [winStart 4500];
        FFTWin = [300 1900];
        ICAWin = [-1000 1000];

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
    case "TITS_Offset_Irreg"  % mix Reg and Irreg 15 30 60 120
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
        S1Duration = [5004.8, 5008.4, 5000, 5075] + 4;
        soundDur = [10009.2, 10009.2, 10068.8, 10068.8];
        winStart = -5500;
        Window = [winStart 5500];
        ICAWin = [-1000 10000];
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