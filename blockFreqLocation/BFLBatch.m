clc; clear; close all force;

% rootPathMat = 'E:\ECoG\MAT Data\XX\BlkFreqLoc Active\';
rootPathMat = 'E:\ECoG\MAT Data\CC\BlkFreqLoc Active\';
ROOTPATH = "E:\ECoG\Figures\BlkFreqLoc\";
temp = dir(rootPathMat);
MATPATHs = [];

for fIndex = 1:length(temp)

    if isequal(temp(fIndex).name, '.') || isequal(temp(fIndex).name, '..')
        continue;
    end
    
    if fIndex == 4
        continue;
    end

    MATFiles = what([rootPathMat, temp(fIndex).name]).mat;

    for mIndex = 1:length(MATFiles)
        [~, name] = fileparts(MATFiles{mIndex});
        splitName = split(name, '_');

        if strcmp(splitName{end}, 'AC')
            BFLSingleFcn([rootPathMat, temp(fIndex).name, '\', MATFiles{mIndex}], ROOTPATH, 1, true);
        elseif strcmp(splitName{end}, 'PFC')
            BFLSingleFcn([rootPathMat, temp(fIndex).name, '\', MATFiles{mIndex}], ROOTPATH, 2, true);
        end
        close all;
    end

end