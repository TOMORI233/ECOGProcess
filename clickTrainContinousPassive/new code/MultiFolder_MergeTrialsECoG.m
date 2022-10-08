clc; clear; close all force;


rootPathMat = 'E:\ECoG\MAT Data\XX\ClickTrainLongTerm\successive_0o1_0o2\';
ROOTPATH = "E:\ECOG\Figures\ClickTrainLongTerm\successive_0o1_0o2\";

% rootPathMat = 'E:\ECoG\MAT Data\CC\ClickTrainLongTerm\successive_0o3_0o5\';
% ROOTPATH = "E:\ECOG\Figures\ClickTrainLongTerm\successive_0o3_0o5\";
temp = dir(rootPathMat);
MATPATHs = [];

for fIndex = 1:length(temp)

    if isequal(temp(fIndex).name, '.') || isequal(temp(fIndex).name, '..')
        continue;
    end

    MATFiles = what([rootPathMat, temp(fIndex).name]).mat;

    for mIndex = 1:length(MATFiles)
        [~, name] = fileparts(MATFiles{mIndex});
        splitName = split(name, '_');

        if strcmp(splitName{end}, 'AC')
            CTLSingleFcn([rootPathMat, temp(fIndex).name, '\', MATFiles{mIndex}], 1);
        elseif strcmp(splitName{end}, 'PFC')
            CTLSingleFcn([rootPathMat, temp(fIndex).name, '\', MATFiles{mIndex}], 2);
        end
        close all;
    end

end