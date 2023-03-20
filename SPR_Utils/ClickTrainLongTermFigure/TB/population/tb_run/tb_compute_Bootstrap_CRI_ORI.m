    %%  compute CRI/ORI and plot CRI/ORI topo
    devType = unique([trialAll.devOrdr]);
t = linspace(Window(1), Window(2), diff(Window) /1000 * fs + 1)';
    for dIndex = 1:length(devType)
        tIndex = [trialAll.devOrdr] == devType(dIndex);
        trials = trialAll(tIndex);
        trialsECOG = trialsECOG_Merge(tIndex);
        trialsECOG_S1 = trialsECOG_S1_Merge(tIndex);
        tic
        trialsBoot = mBootstrp(sum(tIndex), @mean, trialsECOG);
        trialsBoot_S1 = mBootstrp(sum(tIndex), @mean, trialsECOG_S1);
        toc
        % compute CRI
%       [temp, amp, rmsSpon] = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trialsECOG, 'UniformOutput', false);
        [temp, amp, rmsSpon] = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trialsBoot, 'UniformOutput', false);
        CRI_Boot(dIndex).info = stimStrs(dIndex);
        CRI_Boot(dIndex).mean = cellfun(@mean, changeCellRowNum(temp));
        CRI_Boot(dIndex).se = cellfun(@(x) std(x)/sqrt(length(x)), changeCellRowNum(temp));
        CRI_Boot(dIndex).raw = changeCellRowNum(temp);
        CRI_Boot(dIndex).rsp = changeCellRowNum(amp);
        CRI_Boot(dIndex).base = changeCellRowNum(rmsSpon);

        
        % compute ORI
        [temp, ampS1, rmsSponS1] = cellfun(@(x) waveAmp_Norm(x, Window, quantWin, CRIMethod, sponWin), trialsBoot_S1, 'UniformOutput', false);
        ORI_Boot(dIndex).info = stimStrs(dIndex);
        ORI_Boot(dIndex).mean = cellfun(@mean, changeCellRowNum(temp));
        ORI_Boot(dIndex).se = cellfun(@(x) std(x)/sqrt(length(x)), changeCellRowNum(temp));
        ORI_Boot(dIndex).raw = changeCellRowNum(temp);
        ORI_Boot(dIndex).rsp = changeCellRowNum(ampS1);
        ORI_Boot(dIndex).base = changeCellRowNum(rmsSponS1);
    end
close all