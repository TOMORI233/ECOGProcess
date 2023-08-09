function data = rhd2mat(DATAPATH, TDTPATH)

[amplifier_data, frequency_parameters, board_dig_in_data] = load_Intan_RHD2000_file(DATAPATH);
rhdData.streams.LAuC.data = amplifier_data/1e6;
rhdData.streams.LAuC.channels = 1:256;
rhdData.streams.LAuC.fs = frequency_parameters.amplifier_sample_rate; 
trigTime = find([0, diff(board_dig_in_data(3, :))] == 1)/frequency_parameters.amplifier_sample_rate;

data = TDTbin2mat(TDTPATH);

tdtTrigger =  data.epocs.num0.onset;
diffTrigger = mean(trigTime(1 : length(tdtTrigger))' - tdtTrigger);
data.epocs.num0.onset = tdtTrigger + diffTrigger;
data.epocs.ordr.onset = tdtTrigger + diffTrigger;
data.streams = rhdData.streams;
end

