function [ff, PMean, P]  = trialsECOGFFT(trialsECoG, fs, tIdx, chIdx, method)
narginchk(2, 5)
if nargin < 3
    tIdx = 1 : size(trialsECoG{1}, 2);
    chIdx = 1 : size(trialsECoG{1}, 1);
    method = 2;
end

if nargin < 4
    chIdx = 1 : size(trialsECoG{1}, 1);
    method = 2;
end

if nargin < 5
    method = 2;
end

if isempty(chIdx)
    chIdx = 1 : size(trialsECoG{1}, 1);
end

temp = changeCellRowNum(trialsECoG);


mParpool = gcp;

chTemp = cellfun(@(x) array2VectorCell(x), temp, "uni", false);
P = cell(length(chTemp), 1);
for ch = 1 : length(chTemp)
if isequal(method, 1) || strcmpi(method, "power")
                    [f, P{ch, 1}, ~] = cellfun(@(x) mFFT_Pow(x(tIdx), fs), chTemp{ch, 1}, 'UniformOutput', false);
%         F(ch) = parfeval(mParpool, @cellfun, 2, @(x) mFFT_Pow(x(tIdx), fs), chTemp{ch, 1}, 'UniformOutput', false);
%         P{ch, 1} = F.OutputArguments{2};
elseif isequal(method, 2) || strcmpi(method, "magnitude")% magnitude
                    [f, ~,  P{ch, 1}] = cellfun(@(x) mFFT_Base(x(tIdx), fs), chTemp{ch, 1}, 'UniformOutput', false);
%         F(ch) = parfeval(mParpool, @cellfun, 3, @(x) mFFT_Base(x(tIdx), fs), chTemp{ch, 1}, 'UniformOutput', false);
%         while isempty(F.OutputArguments)
%             pause(0.1);
%         end       
end
end
% wait(F);
% P = cellfun(@(x) cell2mat(x{3}), {F.OutputArguments}, "uni", false)';
% ff = F(1).OutputArguments{1}{1};

P = cellfun(@(x) cell2mat(x), P, "uni", false);
ff = f{1};
PMean = cell2mat(cellfun(@(x) smoothdata(mean(x),'gaussian', 1), P, "uni", false));
end





