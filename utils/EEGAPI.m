function epocs = EEGAPI(EEG)
%% protocol1 : hear to be familiar with sounds, 51-100
prot1Idx = ismember([EEG.event.type]',[51 : 100]');
epocs.prot1.onset = [EEG.event(prot1Idx).latency]' / EEG.srate;
epocs.prot1.data = [EEG.event(prot1Idx).type]';

%% protocol2 : behavior session start by subject
prot2Idx = ismember([EEG.event.type]',[101 : 150]');
epocs.prot2.onset = [EEG.event(prot2Idx).latency]' / EEG.srate;
epocs.prot2.data = [EEG.event(prot2Idx).type]';

%% protocol3 : passively hearing long-term click trains
prot3Idx = ismember([EEG.event.type]',[151 : 200]');
epocs.prot3.onset = [EEG.event(prot2Idx).latency]' / EEG.srate;
epocs.prot3.data = [EEG.event(prot2Idx).type]';

%% protocol4 : decoding session
prot4Idx = ismember([EEG.event.type]',[151 : 200]');
epocs.prot4.onset = [EEG.event(prot4Idx).latency]' / EEG.srate;
epocs.prot4.data = [EEG.event(prot4Idx).type]';

%% subject key press to start a trial
startIdx = ismember([EEG.event.type]', 1);
epocs.start.onset = [EEG.event(startIdx).latency]' / EEG.srate;
epocs.start.data = [EEG.event(startIdx).type]';

%% subject key press to respond "yes"
yesIdx = ismember([EEG.event.type]', 2);
epocs.yes.onset = [EEG.event(yesIdx).latency]' / EEG.srate;
epocs.yes.data = [EEG.event(yesIdx).type]';

%% subject key press to respond "no"
noIdx = ismember([EEG.event.type]', 3);
epocs.no.onset = [EEG.event(noIdx).latency]' / EEG.srate;
epocs.no.data = [EEG.event(noIdx).type]';
end