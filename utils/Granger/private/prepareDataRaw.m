function data = prepareDataRaw(trialsDataSeed, trialsDataTarget, fs, fRange)
narginchk(3, 4);

if nargin < 4
    fRange = [];
end

%% Wavelet transform
disp('Performing cwt on data...');
tic;
trialsData = cellfun(@(x, y) [x; y], trialsDataSeed, trialsDataTarget, "UniformOutput", false);
[nChs, nTime] = size(trialsData{1});
if exist(['cwtMultiAll', num2str(nTime), 'x', num2str(nChs), '_mex.mexw64'], 'file')
    disp('Using GPU...');
    cwtFcn = eval(['@cwtMultiAll', num2str(nTime), 'x', num2str(nChs), '_mex']);
    [cwtres, f, coi] = cellfun(@(x) cwtFcn(x', fs), trialsData, "UniformOutput", false);
    cwtres = cellfun(@gather, cwtres, "UniformOutput", false);
    f = gather(f{1});
    coi = gather(coi{1});
else
    disp('Using CPU...');
    cwtFcn = @cwtMultiAll;
    [cwtres, f, coi] = cellfun(@(x) cwtFcn(x', fs), trialsData, "UniformOutput", false);
    f = f{1};
    coi = coi{1};
end
toc;

if numel(fRange) == 2 && fRange(2) > fRange(1)
    idx = find(f <= fRange(2), 1):find(f >= fRange(1), 1, "last");
    if ~isempty(idx)
        f = f(idx);
        cwtres = cellfun(@(x) x(idx, :, :), cwtres, "UniformOutput", false);
    else
        error("Frequency range not found");
    end
end

% trans log-scaled [f] to linear-spaced and pad with zero
% cwt returns [f] as a descendent column vector
f = 10 * log(f);
c = 0 - f(end);
f = f + c;

t = (0:size(trialsData{1}, 2) - 1) / fs;

cwtres = permute(cat(4, cwtres{:}), [4, 3, 1, 2]); % rpt_chan_freq_time

data = [];
data.freq = f;
data.time = t;
data.label = [{'seed'}; cellstr(num2str((1:size(trialsDataTarget{1}, 1))'))];
data.dimord = 'rpt_chan_freq_time';
data.cumtapcnt = ones(length(t), length(f));
data.fourierspctrm = cwtres;
data.coi = coi;
data.c = c; % shift in [f]

return;
end