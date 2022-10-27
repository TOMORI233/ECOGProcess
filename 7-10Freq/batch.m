clc; clear; close all force;

ROOTPATH = "D:\Education\Lab\Projects\ECOG\Figures\7-10Freq\";
rootPathMat{1} = 'D:\Education\Lab\Projects\ECOG\MAT Data\CC\7-10Freq Active\';
rootPathMat{2} = 'D:\Education\Lab\Projects\ECOG\MAT Data\XX\7-10Freq Active\';

for rIndex = 1:2
    temp = dir(rootPathMat{rIndex});
    MATPATHs = [];
    
    for fIndex = 1:length(temp)
    
        if isequal(temp(fIndex).name, '.') || isequal(temp(fIndex).name, '..')
            continue;
        end
    
        MATFiles = what([rootPathMat{rIndex}, temp(fIndex).name]).mat;
    
        for mIndex = 1:length(MATFiles)
            [~, name] = fileparts(MATFiles{mIndex});
            splitName = split(name, '_');
    
            if strcmp(splitName{end}, 'AC')
                singleFcn([rootPathMat{rIndex}, temp(fIndex).name, '\', MATFiles{mIndex}], ROOTPATH, 1);
            elseif strcmp(splitName{end}, 'PFC')
                singleFcn([rootPathMat{rIndex}, temp(fIndex).name, '\', MATFiles{mIndex}], ROOTPATH, 2);
            end
        end
    
    end

end