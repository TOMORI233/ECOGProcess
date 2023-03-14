    %% p-value of CRI and sponRes
        devType = unique([trialAll.devOrdr]);
    for dIndex = 1:length(devType)
        % compare change resp and spon resp
        rsp = CRI(dIndex).rsp;
        base = CRI(dIndex).base;
        [sponH, sponP] = cellfun(@(x, y) ttest(x, y), changeCellRowNum(rsp), changeCellRowNum(base), "UniformOutput", false);%         % compare CRI and 1
        
        if contains(MATPATH{mIndex}, "XX")
            sponH([2, 16,18, 25, 26, 27, 32]) = num2cell(zeros(7, 1));
        end
        compare.sponRsp(dIndex).info = stimStrs(dIndex);
        compare.sponRsp(dIndex).H = sponH;
        compare.sponRsp(dIndex).P = sponP;
        %         temp = CRI(dIndex).(strcat(monkeyStr(mIndex), "_raw"));
        %         OneArray = repmat({ones(length(temp{1}), 1) * CRITest(CRIMethod)}, length(temp), 1);
        %         [sponH{dIndex}, sponP{dIndex}] = cellfun(@(x, y) ttest2(x, y), temp, OneArray, "UniformOutput", false);

        %         % plot p-value topo
        %         topo = logg(pBase, cell2mat(sponP) / pBase);
        %         topo(isinf(topo)) = 5;
        %         topo(topo > 5) = 5;
        %         FigTopo= plotTopo_Raw(topo, [8, 8]);
        %         colormap(FigTopo, "jet");
        %         scaleAxes(FigTopo, "c", [-5 5]);
        %         pause(1);
        %         set(FigTopo, "outerposition", [300, 100, 800, 670]);
        %         %         title("p-value (log(log(0.05, p)) distribution of [0 300] response and baseline");
        %         print(FigTopo, strcat(FIGPATH, Protocol, "_", stimStrs(dIndex), "_pValue_Topo_Reg"), "-djpeg", "-r200");
        %         close(FigTopo);
    end
