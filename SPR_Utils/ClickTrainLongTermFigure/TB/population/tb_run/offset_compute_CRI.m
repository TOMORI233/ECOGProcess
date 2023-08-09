%%  compute CRI/ORI and plot CRI/ORI topo
devType = unique([trialAll.devOrdr]);
t = linspace(Window(1), Window(2), diff(Window) /1000 * fs + 1)';
for dIndex = 1:length(devType)
    tIndex = [trialAll.devOrdr] == devType(dIndex);
    trials = trialAll(tIndex);
    trialsECOG = trialsECOG_Merge(tIndex);
    trialsECOG_S1 = trialsECOG_S1_Merge(tIndex);

    % compute CRI
    [temp, amp, rmsSpon] = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trialsECOG, 'UniformOutput', false);
    temp = changeCellRowNum(temp);
    amp = changeCellRowNum(amp);
    rmsSpon = changeCellRowNum(rmsSpon);
%     idxLeft = cellfun(@(x) exclude_via_STD(x, 2), temp, "UniformOutput", false);
% 
%     temp = cellfun(@(x, y) x(y), temp, idxLeft, "UniformOutput", false);
%     amp = cellfun(@(x, y) x(y), amp, idxLeft, "UniformOutput", false);
%     rmsSpon = cellfun(@(x, y) x(y), rmsSpon, idxLeft, "UniformOutput", false);
%    
    CRI(dIndex).info = stimStrs(dIndex);
    CRI(dIndex).mean = cellfun(@mean, temp);
    CRI(dIndex).se = cell2mat(cellfun(@(x) SE(x), temp, "UniformOutput", false));
    CRI(dIndex).raw = temp;
    CRI(dIndex).rsp = amp;
    CRI(dIndex).base = rmsSpon;

    CRMS(dIndex).mean = cellfun(@mean, CRI(dIndex).rsp); 
    CRMS(dIndex).se =  cellfun(@(x) std(x)/sqrt(length(x)), CRI(dIndex).rsp);
end
close all