function data = rhd2mat(DATAPATH, TDTPATH)

[amplifier_data, frequency_parameters] = load_Intan_RHD2000_file(DATAPATH);
rhdData.streams.LAuC.data = amplifier_data;
rhdData.streams.LAuC.channels = 1:256;
rhdData.streams.LAuC.fs = frequency_parameters.amplifier_sample_rate; 

data = TDTbin2mat(TDTPATH);
data.streams = rhdData.streams;
end

