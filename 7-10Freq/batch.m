clc; clear; close all force;

rootPathMat = 'D:\Education\Lab\Projects\ECOG\MAT Data\CC\7-10Freq Active\';
% rootPathMat = 'D:\Education\Lab\Projects\ECOG\MAT Data\XX\7-10Freq Active\';
ROOTPATH = "D:\Education\Lab\Projects\ECOG\Figures\7-10Freq\";
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
            singleFcn([rootPathMat, temp(fIndex).name, '\', MATFiles{mIndex}], ROOTPATH, 1);
        elseif strcmp(splitName{end}, 'PFC')
            singleFcn([rootPathMat, temp(fIndex).name, '\', MATFiles{mIndex}], ROOTPATH, 2);
        end
    end

end