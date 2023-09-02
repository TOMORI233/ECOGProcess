clc; clear; close all
%% XX
% dates = ["xx20230703", "xx20230707", "xx20230712"];
% date_block = [2, 3, 4, 5, 6, 7; ...
%               2, 3, 4, 5, 6, 7; ...
%               2, 3, 4, 5, 6, 8];
              
%% CC
dates = ["cc20230710", "cc20230714"];
date_block = [2, 3, 4, 5, 6, 7; ...
              2, 3, 4, 5, 6, 8];
              

for rIndex = 1 : length(dates)
    clearvars -except toPlot dates date_block rIndex
%% load path
dateStr = dates(rIndex);
rootPath = "E:\ECOG\corelDraw\ClickTrainLongTerm\Anesthesia";
Protocol = "Figure_Anesthesia_BaseICI_Ratio_Tone_Push";
awakePath = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-", num2str(date_block(rIndex, 1)), "_AC\Figures\");
ketamin_0o5_Path = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-", num2str(date_block(rIndex, 2)), "_AC\Figures\");
ketamin_1_Path = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-", num2str(date_block(rIndex, 3)), "_AC\Figures\");
ketamin_2_Path = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-", num2str(date_block(rIndex, 4)), "_AC\Figures\");
ketamin_4_Path = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-", num2str(date_block(rIndex, 5)), "_AC\Figures\");
ketamin_8_Path = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-", num2str(date_block(rIndex, 6)), "_AC\Figures\");
MATNAME = "cdrPlotFilter.mat";
data.Awake = load(strcat(awakePath, MATNAME));
if length(data.Awake) > 4
    data.Awake.RegRatio(5) = [];  data.Awake.RegRatioS1(5) = [];
end
data.Ket0o5 = load(strcat(ketamin_0o5_Path, MATNAME));
data.Ket1 = load(strcat(ketamin_1_Path, MATNAME));
data.Ket2 = load(strcat(ketamin_2_Path, MATNAME));
data.Ket4 = load(strcat(ketamin_4_Path, MATNAME));
data.Ket8 = load(strcat(ketamin_8_Path, MATNAME));

%% 日期信息
toPlot(rIndex).date = dates(rIndex);

%% 同一刺激不同深度
states = string(fields(data));
stimStrs = ["REG4_4o06", "REG8_8o12", "REG4_5", "TONE250_200"];
for CH = 1 : 64
    for dIndex = 1 : length(stimStrs)
        for sIndex = 1 : length(states)
            Window = data.(states(sIndex)).Window;
            t = linspace(Window(1), Window(2), size(data.(states(sIndex)).RegRatio(dIndex).chMean, 2));
            toPlot(rIndex).diffDepth(CH).(stimStrs(dIndex))(:, 2*sIndex - 1) = t';
            toPlot(rIndex).diffDepth(CH).(stimStrs(dIndex))(:, 2*sIndex) = data.(states(sIndex)).RegRatio(dIndex).chMean(CH, :)';
        end
    end
end

%% 同一深度不同刺激
states = string(fields(data));
stimStrs = ["REG4_4o06", "REG8_8o12", "REG4_5", "TONE250_200"];
for CH = 1 : 64
    for dIndex = 1 : length(stimStrs)
        for sIndex = 1 : length(states)
            Window = data.(states(sIndex)).Window;
            t = linspace(Window(1), Window(2), size(data.(states(sIndex)).RegRatio(dIndex).chMean, 2));
            toPlot(rIndex).diffStim(CH).(states(sIndex))(:, 2*dIndex - 1) = t';
            toPlot(rIndex).diffStim(CH).(states(sIndex))(:, 2*dIndex) = data.(states(sIndex)).RegRatio(dIndex).chMean(CH, :)';
        end
    end
end


%% 不同麻醉深度的频谱能量
Protocol = "Figure_Anesthesia_BaseICI_Ratio_Tone_Push_Spon";
awakePath = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-2_AC\Figures\");
ketamin_0o5_Path = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-3_AC\Figures\");
ketamin_1_Path = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-4_AC\Figures\");
ketamin_2_Path = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-5_AC\Figures\");
ketamin_4_Path = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-6_AC\Figures\");
ketamin_8_Path = strcat(rootPath,"\", Protocol, "\", dateStr, "_Block-7_AC\Figures\");
MATNAME = "cdrPlot.mat";
data.Awake = load(strcat(awakePath, MATNAME));
data.Ket0o5 = load(strcat(ketamin_0o5_Path, MATNAME));
data.Ket1 = load(strcat(ketamin_1_Path, MATNAME));
data.Ket2 = load(strcat(ketamin_2_Path, MATNAME));
data.Ket4 = load(strcat(ketamin_4_Path, MATNAME));
data.Ket8 = load(strcat(ketamin_8_Path, MATNAME));



%% 同一刺激不同深度
states = string(fields(data));
for CH = 1 : 64
    for sIndex = 1 : length(states)
        ff = data.(states(sIndex)).ff;
        toPlot(rIndex).sponFFT(CH).diffDepth(:, 2*sIndex - 1) = ff';
        toPlot(rIndex).sponFFT(CH).diffDepth(:, 2*sIndex) = data.(states(sIndex)).PMean(CH, :)';
    end
end


%% 切换反应和频谱的相关性
for CH = 1 : length(toPlot(rIndex).diffDepth)
CR_Wave = toPlot(rIndex).diffDepth(CH).REG4_4o06;
sponFFT = toPlot(rIndex).sponFFT(CH).diffDepth;

% CR
t = CR_Wave(:, 1);
CRIWave = CR_Wave(:, 2:2:end);
tIndex = t>0 & t<200;
% CRI = max(abs(CRIWave(tIndex, :)));
CRI = rms(CRIWave(tIndex, :), 1);

% OR
tIndex = t>0-2001.9 & t<200-2001.9;
% ORI = max(abs(CRIWave(tIndex, :)));
ORI(:, CH) = rms(CRIWave(tIndex, :), 1)';

% fft
ff = sponFFT(:, 1);
fftRes = sponFFT(:, 2:2:end);
fIndex = (ff>30 & ff<45) | (ff>55 & ff<100);
fftVal = mean(fftRes(fIndex, :), 1);

% cr_fft_correlation
Corr{CH, 1} = [fftVal', CRI'];



end

%% 删掉坏道
 cif contains(dateStr, "cc")
    chArray = cell2mat(table2cell(readtable("E:\ECoG\麻醉通道选择CC.xlsx")));
elseif contains(dateStr, "xx")
    chArray = cell2mat(table2cell(readtable("E:\ECoG\麻醉通道选择XX.xlsx")));
end
chSel = find(all(chArray, 2));
Corr = Corr(chSel);
Corr = cell2mat(Corr');
Corr = Corr./repmat(Corr(1, :), size(Corr, 1), 1);
% Corr = changeCellRowNum(Corr);
Corr2 = cell2mat(rowFcn(@(x) reshape(x, 2, []), Corr, "UniformOutput", false))';
CorrMean = [mean(Corr2, 1); SE(Corr2, 1)];

toPlot(rIndex).Corr = Corr;
toPlot(rIndex).Corr2 = Corr2;
toPlot(rIndex).CorrMean = CorrMean;
toPlot(rIndex).gamma = Corr(:, 1:2:end);
toPlot(rIndex).CR = Corr(:, 2:2:end);
toPlot(rIndex).gammaMean = [mean(toPlot(rIndex).gamma, 2), SE(toPlot(rIndex).gamma, 2)];
toPlot(rIndex).CRMean = [mean(toPlot(rIndex).CR, 2), SE(toPlot(rIndex).CR, 2)];
end

meanCorr.Corr = cell2mat(cellfun(@mean, changeCellRowNum({toPlot.Corr}'), "UniformOutput", false));
meanCorr.Corr2 = cell2mat(cellfun(@mean, changeCellRowNum({toPlot.Corr2}'), "UniformOutput", false));
