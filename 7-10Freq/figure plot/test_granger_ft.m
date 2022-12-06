clear; clc;
% always start with the same random numbers to make the figures reproducible
rng default
rng(50)

cfg             = [];
cfg.ntrials     = 500;
cfg.triallength = 1;
cfg.fsample     = 200;
cfg.nsignal     = 3;
cfg.method      = 'ar';

cfg.params(:,:,1) = [ 0.8    0    0 ;
                        0  0.9  0.5 ;
                      0.4    0  0.5];

cfg.params(:,:,2) = [-0.5    0    0 ;
                        0 -0.8    0 ;
                        0    0 -0.2];

cfg.noisecov      = [ 0.3    0    0 ;
                        0    1    0 ;
                        0    0  0.2];

data              = ft_connectivitysimulation(cfg);

%% browse data
cfg = [];
cfg.viewmode = 'vertical';  % you can also specify 'butterfly'
figure;
ft_databrowser(cfg, data);

%% multivariate autoregressive model
cfg         = [];
cfg.order   = 5;
cfg.toolbox = 'bsmart';
mdata       = ft_mvaranalysis(cfg, data);

%% Parametric computation of the spectral transfer function
cfg        = [];
cfg.method = 'mvar';
mfreq      = ft_freqanalysis(cfg, mdata);

%% Non-parametric computation of the cross-spectral density matrix
cfg           = [];
cfg.method    = 'mtmfft';
cfg.taper     = 'dpss';
cfg.output    = 'fourier';
cfg.tapsmofrq = 2;
freq          = ft_freqanalysis(cfg, data);

%% connectivity
cfg           = [];
cfg.method    = 'coh';
coh           = ft_connectivityanalysis(cfg, freq);
cohm          = ft_connectivityanalysis(cfg, mfreq);

cfg           = [];
cfg.parameter = 'cohspctrm';
cfg.zlim      = [0 1];
figure;
ft_connectivityplot(cfg, coh, cohm);

%% granger
cfg           = [];
cfg.method    = 'granger';
granger       = ft_connectivityanalysis(cfg, mfreq);

cfg           = [];
cfg.parameter = 'grangerspctrm';
cfg.zlim      = [0 1];
figure;
ft_connectivityplot(cfg, granger);

figure
for row=1:3
for col=1:3
  subplot(3,3,(row-1)*3+col);
  plot(granger.freq, squeeze(granger.grangerspctrm(row,col,:)))
  ylim([0 1])
end
end
