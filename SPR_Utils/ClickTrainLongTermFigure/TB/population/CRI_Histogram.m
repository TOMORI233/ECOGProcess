DATA = compare;
H = DATA.H;


CRI.all.data = DATA.mean_scatter(1, 2:end)';
CRI.all.mean = mean(CRI.all.data);
CRI.all.se = std(CRI.all.data)/sqrt(length(CRI.all.data));

CRI.sig.data = CRI.all.data(H == 1);
CRI.sig.mean = mean(CRI.sig.data);
CRI.sig.se = std(CRI.sig.data)/sqrt(length(CRI.sig.data));

CRI.noSig.data = CRI.all.data(H == 0);
CRI.noSig.mean = mean(CRI.noSig.data);
CRI.noSig.se = std(CRI.noSig.data)/sqrt(length(CRI.noSig.data));
