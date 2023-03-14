%%  compute latency

if contains(MATPATH{mIndex}, "XX")
    latencySet(2).NP = [-1*ones(24, 1); ones(40, 1)];
else
    latencySet(2).NP = -1*ones(64, 1);
end

devType = unique([trialAll.devOrdr]);
t = linspace(Window(1), Window(2), diff(Window) /1000 * fs + 1)';
disp("computing latency...")
tic
for dIndex = 1:length(devType)
    tIndex = [trialAll.devOrdr] == devType(dIndex);
    trials = trialAll(tIndex);
    trialsECOG = trialsECOG_Merge(tIndex);
    trialsECOG_S1 = trialsECOG_S1_Merge(tIndex);

    % multi latency windows
    for wIndex = 1:length(latencySet)
        latency(wIndex).Win = latencySet(wIndex).Win;
        latency(wIndex).NP = latencySet(wIndex).NP;
        % compute change response latency

        latency_T = findWithinInterval(t, latencyWin);
        trialsTemp = cellfun(@(x) findWithinWindow(x, t, latencyWin), trialsECOG, "UniformOutput", false);
        [latency_mean, latency_se, latency_raw]  = Latency_Resample(trialsTemp, latencyWin, latency(wIndex).NP , latencySet(wIndex).Win, sponWin, sigma, smthBin, "Method", "AVL_Boostrap");

        latency(wIndex).CR(dIndex).info = stimStrs(dIndex);
        latency(wIndex).CR(dIndex).mean = latency_mean;
        latency(wIndex).CR(dIndex).se = latency_se;
        latency(wIndex).CR(dIndex).raw = latency_raw;
%        compute change response latency-sinlge
        [latency_mean, latency_se, latency_raw]  = Latency_Resample(trialsTemp, latencyWin, latency(wIndex).NP , latencySet(wIndex).Win, sponWin, sigma, smthBin, "Method", "AVL_Single");

        latencySingle(wIndex).CR(dIndex).info = stimStrs(dIndex);
        latencySingle(wIndex).CR(dIndex).mean = latency_mean;
        latencySingle(wIndex).CR(dIndex).se = latency_se;
        latencySingle(wIndex).CR(dIndex).raw = latency_raw;

        %                     % compute onset response latency
        %                     latency(wIndex).OR(dIndex).info = stimStrs(dIndex);
        %                     trialsTemp = cellfun(@(x) findWithinWindow(x, t, latencyWin), trialsECOG_S1, "UniformOutput", false);
        %                     [latency_mean, latency_se, latency_raw]  = Latency_Resample(trialsTemp, latencyWin, latency(wIndex).NP , latencySet(wIndex).Win, sponWin, sigma, smthBin, "Method", "AVL_Boostrap");
        %                     latency(wIndex).OR(dIndex).mean = latency_mean;
        %                     latency(wIndex).OR(dIndex).se = latency_se;
        %                     latency(wIndex).OR(dIndex).raw = latency_raw;
    end
end
toc
